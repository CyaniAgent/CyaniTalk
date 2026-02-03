import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import '../domain/note.dart';
import '../domain/messaging_message.dart';
import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/constants.dart';
import '../../rust/frb_generated.dart';

part 'rust_misskey_streaming_service.g.dart';

@Riverpod(keepAlive: true)
class RustMisskeyStreamingService extends _$RustMisskeyStreamingService {
  RustMisskeyClient? _rustClient;
  Timer? _reconnectTimer;
  Timer? _eventPollingTimer;

  // Track connected account to avoid redundant reconnections
  String? _connectedAccountId;

  // Stream for broadcasting received notes
  final _noteStreamController = StreamController<NoteEvent>.broadcast();
  Stream<NoteEvent> get noteStream => _noteStreamController.stream;

  // Stream for broadcasting received messages
  final _messageStreamController = StreamController<MessagingMessage>.broadcast();
  Stream<MessagingMessage> get messageStream => _messageStreamController.stream;

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
    });
  }

  void _connect(Account account) async {
    if (_connectedAccountId == account.id && _rustClient != null) return;

    _disconnect();
    _connectedAccountId = account.id;
    _activeTimelineSubscriptions.clear();

    try {
      logger.info('RustMisskeyStreaming: Connecting to ${account.host}');

      // Create Rust client instance
      _rustClient = RustMisskeyClient(
        host: account.host,
        token: account.token,
      );

      // Connect to streaming
      await _rustClient.connectStreaming();

      // Subscribe to main channel
      await _rustClient.subscribeToMain();

      // Start polling for events
      _startEventPolling();

      logger.info('RustMisskeyStreaming: Connected successfully');
    } catch (e) {
      logger.error('RustMisskeyStreaming Connection failed: $e');
      _scheduleReconnect(account);
    }
  }

  void _disconnect() async {
    _reconnectTimer?.cancel();
    _eventPollingTimer?.cancel();
    
    try {
      if (_rustClient != null) {
        await _rustClient.disconnectStreaming();
        _rustClient = null;
      }
    } catch (e) {
      logger.error('RustMisskeyStreaming Disconnection error: $e');
    }
    
    _connectedAccountId = null;
    logger.info('RustMisskeyStreaming: Disconnected');
  }

  void _startEventPolling() {
    _eventPollingTimer?.cancel();
    
    // Poll for events every 50ms
    _eventPollingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _pollForEvents();
    });
  }

  void _pollForEvents() {
    if (_rustClient == null) return;

    try {
      // Poll for events from the Rust client
      final event = _rustClient!.pollStreamingEvent();
      if (event != null) {
        _handleStreamEvent(event);
      }
    } catch (e) {
      logger.error('RustMisskeyStreaming: Error polling events: $e');
    }
  }

  void _handleStreamEvent(dynamic event) {
    // The event structure should match what we defined in Rust
    final eventType = event['eventType'] ?? '';
    final body = event['body'] ?? {};
    final channelId = event['channelId'] ?? '';

    logger.debug('RustMisskeyStreaming: Received event: $eventType from channel: $channelId');

    if (eventType == 'note' && body != null) {
      try {
        final note = Note.fromJson(body as Map<String, dynamic>);
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
      } catch (e) {
        logger.error('RustMisskeyStreaming: Error processing note event: $e');
      }
    } else if (eventType == 'chatMessage' && body != null) {
      try {
        final message = MessagingMessage.fromJson(
          body as Map<String, dynamic>,
        );
        _messageStreamController.add(message);
      } catch (e) {
        logger.error('RustMisskeyStreaming: Error processing chatMessage event: $e');
      }
    } else if (eventType == 'noteDeleted') {
      logger.info('RustMisskeyStreaming: Received noteDeleted event: $body');

      // Try different possible field names for the note ID
      final noteId = body['deletedId'] as String? ??
          body['id'] as String? ??
          body['noteId'] as String?;

      if (noteId != null) {
        _noteStreamController.add(
          NoteEvent(noteId: noteId, isDelete: true),
        );
        logger.info('RustMisskeyStreaming: Emitted deletion event for note: $noteId');
      } else {
        logger.warning(
          'RustMisskeyStreaming: noteDeleted event missing ID field. Event body: $body',
        );
      }
    }
  }

  void _scheduleReconnect(Account account) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_connectedAccountId == account.id) {
        _connect(account);
      }
    });
  }

  void subscribeToTimeline(String timelineType) async {
    if (_rustClient == null) return;

    // Map internal type to Misskey channel name
    final channelName = switch (timelineType) {
      'Home' => 'homeTimeline',
      'Local' => 'localTimeline',
      'Social' => 'hybridTimeline', // Social is usually hybrid in Misskey terms
      'Global' => 'globalTimeline',
      _ => 'homeTimeline',
    };

    if (_activeTimelineSubscriptions.contains(channelName)) return;

    try {
      await _rustClient.subscribeToTimeline(timelineType);
      _activeTimelineSubscriptions.add(channelName);
      logger.info('RustMisskeyStreaming: Subscribed to $channelName channel');
    } catch (e) {
      logger.error('RustMisskeyStreaming: Error subscribing to $channelName: $e');
    }
  }

  void sendMessage(Map<String, dynamic> data) async {
    if (_rustClient != null) {
      try {
        await _rustClient.sendStreamingMessage(jsonEncode(data));
      } catch (e) {
        logger.error('RustMisskeyStreaming: Error sending message: $e');
      }
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