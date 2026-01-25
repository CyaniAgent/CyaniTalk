import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';

part 'misskey_streaming_service.g.dart';

@Riverpod(keepAlive: true)
class MisskeyStreamingService extends _$MisskeyStreamingService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  
  // Track connected account to avoid redundant reconnections
  String? _connectedAccountId;

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
    final initialAccount = ref.read(selectedMisskeyAccountProvider).asData?.value;
    if (initialAccount != null) {
      _connect(initialAccount);
    }

    ref.onDispose(() {
      _disconnect();
    });
  }

  void _connect(Account account) {
    if (_connectedAccountId == account.id && _channel != null) return;
    
    _disconnect();
    _connectedAccountId = account.id;

    final uri = Uri.parse('wss://${account.host}/streaming?i=${account.token}');
    debugPrint('MisskeyStreaming: Connecting to $uri');

    try {
      _channel = WebSocketChannel.connect(uri);
      
      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('MisskeyStreaming Error: $error');
          _scheduleReconnect(account);
        },
        onDone: () {
          debugPrint('MisskeyStreaming Connection closed');
          if (_connectedAccountId == account.id) {
            _scheduleReconnect(account);
          }
        },
      );

      // Connect to the main channel
      _subscribeToMain();
    } catch (e) {
      debugPrint('MisskeyStreaming Connection failed: $e');
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
    debugPrint('MisskeyStreaming: Disconnected');
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
      }
    });
    
    _channel!.sink.add(msg);
    debugPrint('MisskeyStreaming: Subscribed to main channel');
  }

  void _handleMessage(dynamic message) {
    // For now, just log the message to verify connection
    // In the future, this will dispatch events to other services (notifications, timeline, etc.)
    debugPrint('MisskeyStreaming Received: $message');
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }
}
