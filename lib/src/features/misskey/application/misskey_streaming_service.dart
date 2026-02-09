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

@Riverpod(keepAlive: true)
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

  Future<void> _connect() async {
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
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      _channel = IOWebSocketChannel.connect(
        uri,
        customClient: client,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Mobile; rv:109.0) Gecko/20100101 Firefox/115.0 CyaniTalk/${Constants.appVersion}',
        },
      );

      _updateStatus(StreamingStatus.connected);
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          logger.warning('MisskeyStreaming: Connection closed by server');
          _updateStatus(StreamingStatus.disconnected);
          _handleDisconnect(account);
        },
        onError: (error) {
          logger.error('MisskeyStreaming: Connection error: $error');
          _updateStatus(StreamingStatus.error);
          _handleDisconnect(account);
        },
      );

      _startHeartbeat();
      _subscribeToMain();
    } catch (e) {
      logger.error('MisskeyStreaming Connection failed: $e');
      _updateStatus(StreamingStatus.error);
      _handleDisconnect(account);
    }
  }

  void _handleDisconnect(Account account) {
    _reconnectTimer?.cancel();
    // Exponential backoff
    final delay = Duration(seconds: (2 + _reconnectAttempts * 2).clamp(2, 30));
    _reconnectAttempts++;

    logger.info(
      'MisskeyStreaming: Scheduling reconnect in ${delay.inSeconds}s (Attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, () {
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
        // Misskey usually doesn't need heartbeats if using WebSocket PING/PONG,
        // but explicit messages help with some proxies.
        // For Misskey, just sending a "h" is sometimes used by web clients.
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
    if (_channel == null) return;

    // Map internal type to Misskey channel name
    final channelName = switch (timelineType) {
      'Home' => 'homeTimeline',
      'Local' => 'localTimeline',
      'Social' => 'hybridTimeline',
      'Global' => 'globalTimeline',
      _ => 'homeTimeline',
    };

    if (_activeTimelineSubscriptions.contains(channelName)) return;

    final msg = jsonEncode({
      'type': 'connect',
      'body': {'channel': channelName, 'id': 'timeline-$channelName'},
    });

    _channel!.sink.add(msg);
    _activeTimelineSubscriptions.add(channelName);
    logger.info('MisskeyStreaming: Subscribed to $channelName channel');
  }

  void _handleMessage(dynamic message) {
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
