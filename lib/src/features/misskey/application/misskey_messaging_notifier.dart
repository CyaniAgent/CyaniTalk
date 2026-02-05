import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/messaging_message.dart';
import 'misskey_streaming_service.dart';
import '../../../core/core.dart';

part 'misskey_messaging_notifier.g.dart';

@riverpod
class MisskeyMessagingHistoryNotifier extends _$MisskeyMessagingHistoryNotifier {
  @override
  FutureOr<List<MessagingMessage>> build() async {
    logger.info('初始化Misskey消息历史');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      final history = await repository.getMessagingHistory();

      // 监听实时消息以更新历史记录
      final streamingService = ref.watch(misskeyStreamingServiceProvider.notifier);
      final subscription = streamingService.messageStream.listen((message) {
        logger.debug('消息历史Notifier收到实时消息，准备刷新');
        _handleNewMessage(message);
      });

      ref.onDispose(() {
        subscription.cancel();
      });

      logger.info('Misskey消息历史初始化完成，加载了 ${history.length} 条对话');
      return history;
    } catch (e, stack) {
      logger.error('Misskey消息历史初始化失败', e, stack);
      rethrow;
    }
  }

  void _handleNewMessage(MessagingMessage message) {
    if (!ref.mounted) return;
    
    // 当收到新消息时，刷新历史列表以显示最新状态
    // TODO: 优化为本地增量更新以提高性能
    refresh();
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey消息历史');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getMessagingHistory();
    });
  }
}

@riverpod
class MisskeyMessagingNotifier extends _$MisskeyMessagingNotifier {
  @override
  FutureOr<List<MessagingMessage>> build(String userId) async {
    logger.info('初始化Misskey对话，用户ID: $userId');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      
      // 获取对话消息
      final messages = await repository.getMessagingMessages(userId: userId);

      // 监听实时消息
      final streamingService = ref.watch(misskeyStreamingServiceProvider.notifier);
      final subscription = streamingService.messageStream.listen((message) {
        if (message.userId == userId || message.recipientId == userId) {
          logger.debug('对话Notifier收到实时消息: ${message.id}');
          _handleNewMessage(message);
        }
      });

      ref.onDispose(() {
        subscription.cancel();
      });

      // 为聊天UI准备，将消息按时间正序排列
      final sortedMessages = messages.reversed.toList();
      logger.info('Misskey对话初始化完成，加载了 ${sortedMessages.length} 条消息');
      return sortedMessages;
    } catch (e, stack) {
      logger.error('Misskey对话初始化失败，用户ID: $userId', e, stack);
      rethrow;
    }
  }

  void _handleNewMessage(MessagingMessage message) {
    if (!ref.mounted) return;
    
    final currentMessages = state.value ?? [];
    if (currentMessages.any((m) => m.id == message.id)) return;

    logger.debug('收到Misskey实时消息: ${message.id}');
    state = AsyncData([...currentMessages, message]);
  }

  Future<void> sendMessage(String text, {String? fileId}) async {
    if (text.isEmpty && fileId == null) return;

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final message = await repository.sendMessagingMessage(
        userId: userId,
        text: text,
        fileId: fileId,
      );
      
      _handleNewMessage(message);
    } catch (e) {
      logger.error('发送Misskey消息失败', e);
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) return;

    final currentMessages = state.value ?? [];
    if (currentMessages.isEmpty) return;

    final firstId = currentMessages.first.id;
    logger.info('加载更多Misskey消息，用户ID: $userId, 起始ID: $firstId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newMessages = await repository.getMessagingMessages(
        userId: userId,
        untilId: firstId,
      );

      if (!ref.mounted) return currentMessages;

      logger.info('Misskey消息加载更多完成，新增 ${newMessages.length} 条消息');
      return [...newMessages.reversed, ...currentMessages];
    });
  }

  Future<void> markAsRead(String messageId) async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.markMessagingMessageAsRead(messageId);
    } catch (e) {
      logger.error('标记Misskey消息为已读失败: $messageId', e);
    }
  }
}

@riverpod
class MisskeyChatRoomNotifier extends _$MisskeyChatRoomNotifier {
  @override
  FutureOr<List<MessagingMessage>> build(String roomId) async {
    logger.info('初始化Misskey聊天室，房间ID: $roomId');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      
      // 获取聊天室消息
      final messages = await repository.getChatRoomMessages(roomId: roomId);

      // 监听实时消息 (聊天室消息通常也在同样的流中，或者需要特定的流)
      final streamingService = ref.watch(misskeyStreamingServiceProvider.notifier);
      final subscription = streamingService.messageStream.listen((message) {
        if (message.roomId == roomId) {
          logger.debug('聊天室Notifier收到实时消息: ${message.id}');
          _handleNewMessage(message);
        }
      });

      ref.onDispose(() {
        subscription.cancel();
      });

      // 同样按时间正序排列
      final sortedMessages = messages.reversed.toList();
      logger.info('Misskey聊天室初始化完成，加载了 ${sortedMessages.length} 条消息');
      return sortedMessages;
    } catch (e, stack) {
      logger.error('Misskey聊天室初始化失败，房间ID: $roomId', e, stack);
      rethrow;
    }
  }

  void _handleNewMessage(MessagingMessage message) {
    if (!ref.mounted) return;
    
    final currentMessages = state.value ?? [];
    if (currentMessages.any((m) => m.id == message.id)) return;

    state = AsyncData([...currentMessages, message]);
  }

  Future<void> sendMessage(String text, {String? fileId}) async {
    if (text.isEmpty && fileId == null) return;

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.sendChatRoomMessage(
        roomId: roomId,
        text: text,
        fileId: fileId,
      );
      // 注意：某些API不直接返回发送的消息，依赖流更新
    } catch (e) {
      logger.error('发送Misskey聊天室消息失败', e);
      rethrow;
    }
  }
}
