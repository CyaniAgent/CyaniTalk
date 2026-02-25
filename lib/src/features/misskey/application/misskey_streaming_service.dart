import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../domain/note.dart';
import '../domain/note_event.dart';
import '../domain/messaging_message.dart';

import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/constants.dart';
import '../../../core/services/streaming/streaming_service_interface.dart';

part 'misskey_streaming_service.g.dart';

@Riverpod()
class MisskeyStreamingService extends _$MisskeyStreamingService
    implements IMisskeyStreamingService {
  WebSocketChannel? _channel;
  final _noteController = StreamController<NoteEvent>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageController = StreamController<MessagingMessage>.broadcast();
  final _statusController = StreamController<StreamingStatus>.broadcast();

  final Set<String> _activeTimelineSubscriptions = {};
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  StreamingStatus _status = StreamingStatus.disconnected;

  @override
  Stream<NoteEvent> get noteStream => _noteController.stream;

  @override
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  @override
  Stream<MessagingMessage> get messageStream => _messageController.stream;

  @override
  Stream<StreamingStatus> get statusStream => _statusController.stream;

  StreamingStatus get status => _status;

  void _updateStatus(StreamingStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
    logger.info('MisskeyStreaming: Status updated to $newStatus');
  }

  @override
  void build() {
    // Listen to account changes
    ref.listen(selectedMisskeyAccountProvider, (previous, next) {
      if (!ref.mounted) return;

      final account = next.asData?.value;
      if (account != null) {
        _connect();
      } else {
        _disconnect();
      }
    });

    // Initial connection check
    final initialAccount = ref
        .read(selectedMisskeyAccountProvider)
        .asData
        ?.value;
    if (initialAccount != null) {
      _connect();
    }

    ref.onDispose(() {
      _cleanup();
      _noteController.close();
      _messageController.close();
      _notificationController.close();
      _statusController.close();
    });
  }

  void _cleanup() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _activeTimelineSubscriptions.clear();
  }

  @override
  void dispose() {
    _cleanup();
  }

  @override
  void reconnect() {
    logger.info('MisskeyStreaming: Manually triggering reconnect...');
    // Store current subscriptions to restore them after connection
    final subscriptionsToRestore = Set<String>.from(_activeTimelineSubscriptions);
    _connect().then((_) {
      for (final channelName in subscriptionsToRestore) {
        _subscribeToChannel(channelName);
      }
    });
  }

  Future<void> _connect() async {
    if (!ref.mounted) return;

    final account = ref.read(selectedMisskeyAccountProvider).value;
    if (account == null) {
      _updateStatus(StreamingStatus.disconnected);
      return;
    }

    _cleanup();
    _updateStatus(StreamingStatus.connecting);

    final uri = Uri.parse('wss://${account.host}/streaming?i=${account.token}');
    logger.info('MisskeyStreaming: Connecting to $uri');

    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      // 增加连接超时到 30s，防止后台被挂起时超时
      client.connectionTimeout = const Duration(seconds: 30); 
      // 显式设置闲置超时
      client.idleTimeout = const Duration(seconds: 120);

      // 使用局部变量防止竞态条件
      final channel = IOWebSocketChannel.connect(
        uri,
        customClient: client,
        headers: {
          'User-Agent': Constants.getUserAgent(),
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
        pingInterval: const Duration(seconds: 20), // 启用内置心跳
      );
      _channel = channel;

      // 显式等待并监听流，以捕获连接初始阶段的异常
      await channel.ready; 

      if (_channel != channel) {
        logger.warning('MisskeyStreaming: Connection established but channel was swapped. Closing old one.');
        channel.sink.close();
        return;
      }

      _updateStatus(StreamingStatus.connected);
      _reconnectAttempts = 0;

      channel.stream.listen(
        _handleMessage,
        onDone: () {
          logger.warning('MisskeyStreaming: Connection closed');
          _updateStatus(StreamingStatus.disconnected);
          _handleDisconnect(account);
        },
        onError: (error) {
          logger.error('MisskeyStreaming: Stream error: $error');
          // 针对 Windows "semaphore timeout" 或 "handshake" 错误加强日志
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('121') || errorStr.contains('semaphore')) {
            logger.error('MisskeyStreaming: Detected Windows Semaphore Timeout (Error 121)');
          } else if (errorStr.contains('handshake') || errorStr.contains('terminated')) {
            logger.error('MisskeyStreaming: Detected SSL Handshake Failure');
          }
          _updateStatus(StreamingStatus.error);
          _handleDisconnect(account);
        },
      );

      _startHeartbeat();
      _subscribeToMain();
    } catch (e) {
      logger.error('MisskeyStreaming Connection failed (Catch): $e');
      _updateStatus(StreamingStatus.error);
      _handleDisconnect(account);
    }
  }

  void _handleDisconnect(Account account) {
    _reconnectTimer?.cancel();
    
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logger.error('MisskeyStreaming: Maximum reconnection attempts reached ($_maxReconnectAttempts). Stopping automatic retry.');
      _updateStatus(StreamingStatus.error);
      return;
    }

    // 指数避退重连
    final delay = Duration(seconds: (1 << _reconnectAttempts));
    _reconnectAttempts++;

    logger.info(
      'MisskeyStreaming: Scheduling reconnect in ${delay.inSeconds}s (Attempt $_reconnectAttempts/$_maxReconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, () {
      if (!ref.mounted) return;

      final currentAccount = ref.read(selectedMisskeyAccountProvider).value;
      if (currentAccount?.id == account.id) {
        _connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_status == StreamingStatus.connected && _channel != null) {
        try {
          // Misskey 官方网页客户端通常会发送一个简单的 "h" 作为应用层心跳
          // 这在通过一些会超时断开连接的代理（如 Nginx/Cloudflare）时非常有效
          _channel!.sink.add('h');
          logger.debug('MisskeyStreaming: Sent app-level heartbeat ("h")');
        } catch (e) {
          logger.error('MisskeyStreaming: Heartbeat failed: $e');
        }
      }
    });
  }

  Future<void> _disconnect() async {
    _cleanup();
    _updateStatus(StreamingStatus.disconnected);
  }

  void _subscribeToMain() {
    if (_channel == null) return;

    final msg = jsonEncode({
      'type': 'connect',
      'body': {
        'channel': 'main',
        'id': 'main-${DateTime.now().millisecondsSinceEpoch}',
      },
    });

    _channel!.sink.add(msg);
    logger.info('MisskeyStreaming: Subscribed to main channel');
  }

  @override
  void subscribeToTimeline(String timelineType) {
    // Map internal type to Misskey channel name
    final channelName = switch (timelineType) {
      'Home' => 'homeTimeline',
      'Local' => 'localTimeline',
      'Social' => 'hybridTimeline',
      'Global' => 'globalTimeline',
      _ => 'homeTimeline',
    };

    _subscribeToChannel(channelName);
  }

  void _subscribeToChannel(String channelName) {
    if (_channel == null) return;

    final msg = jsonEncode({
      'type': 'connect',
      'body': {'channel': channelName, 'id': 'timeline-$channelName'},
    });

    _channel!.sink.add(msg);
    _activeTimelineSubscriptions.add(channelName);
    logger.info('MisskeyStreaming: Subscribed to $channelName channel');
  }

  void _handleMessage(dynamic message) {
    // 忽略心跳响应
    if (message == 'h' || message == 'pong') return;
    
    logger.debug('MisskeyStreaming Received: $message');

    try {
      final Map<String, dynamic> data = jsonDecode(message as String);
      final type = data['type'];
      final body = data['body'];

      if (type == 'channel' && body != null) {
        final channelId = body['id'] as String;
        final eventType = body['type'];
        final eventBody = body['body'];

        if (eventType == 'note' && eventBody != null) {
          final note = Note.fromJson(eventBody as Map<String, dynamic>);
          String? timelineType;

          if (channelId.startsWith('timeline-')) {
            final misskeyChannel = channelId.substring(9);
            timelineType = switch (misskeyChannel) {
              'homeTimeline' => 'Home',
              'localTimeline' => 'Local',
              'hybridTimeline' => 'Social',
              'globalTimeline' => 'Global',
              _ => null,
            };
          }

          if (timelineType != null) {
            _noteController.add(
              NoteEvent(note: note, timelineType: timelineType),
            );
          }
        } else if (eventType == 'notification' && eventBody != null) {
          _notificationController.add(eventBody as Map<String, dynamic>);
        } else if ((eventType == 'chatMessage' ||
                eventType == 'messagingMessage') &&
            eventBody != null) {
          final message = MessagingMessage.fromJson(
            eventBody as Map<String, dynamic>,
          );
          _messageController.add(message);
        } else if (eventType == 'noteDeleted') {
          final noteId =
              eventBody?['deletedId'] as String? ??
              eventBody?['id'] as String? ??
              eventBody?['noteId'] as String?;

          if (noteId != null) {
            _noteController.add(NoteEvent(noteId: noteId, isDelete: true));
          }
        }
      }
    } catch (e) {
      logger.error('MisskeyStreaming: Error parsing message: $e');
    }
  }

  @override
  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }
}
