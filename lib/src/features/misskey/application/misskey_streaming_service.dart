import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../domain/note.dart';
import '../domain/messaging_message.dart';

import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/constants.dart';

part 'misskey_streaming_service.g.dart';

@Riverpod(keepAlive: true)
class MisskeyStreamingService extends _$MisskeyStreamingService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  // Track connected account to avoid redundant reconnections
  String? _connectedAccountId;

  // Stream for broadcasting received notes
  final _noteStreamController = StreamController<NoteEvent>.broadcast();
  Stream<NoteEvent> get noteStream => _noteStreamController.stream;

  // Stream for broadcasting received messages
  final _messageStreamController = StreamController<MessagingMessage>.broadcast();
  Stream<MessagingMessage> get messageStream => _messageStreamController.stream;

  // Stream for broadcasting received notifications
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;

  // Track active timeline subscriptions to avoid duplicates
  final Set<String> _activeTimelineSubscriptions = {};

  @override
  void build() {
    // Listen to account changes
    ref.listen(selectedMisskeyAccountProvider, (previous, next) {
      final account = next.asData?.value;
      if (account != null) {
        _connect(account);
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
      _connect(initialAccount);
    }

    ref.onDispose(() {
      _disconnect();
      _noteStreamController.close();
      _messageStreamController.close();
      _notificationStreamController.close();
    });
  }

  void _connect(Account account) {
    if (_connectedAccountId == account.id && _channel != null) return;

    _disconnect();
    _connectedAccountId = account.id;
    _activeTimelineSubscriptions.clear();

    final uri = Uri.parse('wss://${account.host}/streaming?i=${account.token}');
    logger.info('MisskeyStreaming: Connecting to $uri');

    try {
      // 使用自定义 HttpClient 以绕过证书校验问题
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      _channel = IOWebSocketChannel.connect(
        uri,
        customClient: client,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Mobile; rv:109.0) Gecko/20100101 Firefox/115.0 CyaniTalk/${Constants.appVersion}',
        },
      );

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          logger.error('MisskeyStreaming Error: $error');
          _scheduleReconnect(account);
        },
        onDone: () {
          logger.info('MisskeyStreaming Connection closed');
          if (_connectedAccountId == account.id) {
            _scheduleReconnect(account);
          }
        },
      );

      // Connect to the main channel
      _subscribeToMain();
    } catch (e) {
      logger.error('MisskeyStreaming Connection failed: $e');
      _scheduleReconnect(account);
    }
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _connectedAccountId = null;
    logger.info('MisskeyStreaming: Disconnected');
  }

  void _scheduleReconnect(Account account) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_connectedAccountId == account.id) {
        _connect(account);
      }
    });
  }

  void _subscribeToMain() {
    if (_channel == null) return;

    final msg = jsonEncode({
      'type': 'connect',
      'body': {
        'channel': 'main',
        'id': 'main-channel-${DateTime.now().millisecondsSinceEpoch}',
      },
    });

    _channel!.sink.add(msg);
    logger.info('MisskeyStreaming: Subscribed to main channel');
  }

  void subscribeToTimeline(String timelineType) {
    if (_channel == null) return;

    // Map internal type to Misskey channel name
    final channelName = switch (timelineType) {
      'Home' => 'homeTimeline',
      'Local' => 'localTimeline',
      'Social' => 'hybridTimeline', // Social is usually hybrid in Misskey terms
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
            _noteStreamController.add(
              NoteEvent(note: note, timelineType: timelineType),
            );
          }
        } else if (eventType == 'notification' && eventBody != null) {
          _notificationStreamController.add(eventBody as Map<String, dynamic>);
        } else if (eventType == 'chatMessage' && eventBody != null) {
          final message = MessagingMessage.fromJson(
            eventBody as Map<String, dynamic>,
          );
          _messageStreamController.add(message);
        } else if (eventType == 'noteDeleted') {
          logger.info(
            'MisskeyStreaming: Received noteDeleted event: $eventBody',
          );

          // Try different possible field names for the note ID
          final noteId =
              eventBody?['deletedId'] as String? ??
              eventBody?['id'] as String? ??
              eventBody?['noteId'] as String?;

          if (noteId != null) {
            _noteStreamController.add(
              NoteEvent(noteId: noteId, isDelete: true),
            );
            logger.info(
              'MisskeyStreaming: Emitted deletion event for note: $noteId',
            );
          } else {
            logger.warning(
              'MisskeyStreaming: noteDeleted event missing ID field. Event body: $eventBody',
            );
          }
        }
      }
    } catch (e) {
      logger.error('MisskeyStreaming: Error parsing message: $e');
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }
}

class NoteEvent {
  final Note? note;
  final String? timelineType;
  final String? noteId;
  final bool isDelete;

  NoteEvent({this.note, this.timelineType, this.noteId, this.isDelete = false});
}
