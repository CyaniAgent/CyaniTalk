import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/messaging_message.dart';
import '../domain/chat_room.dart';
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
      
      // 并行获取 DM 历史和已加入的群聊
      final results = await Future.wait([
        repository.getMessagingHistory(),
        repository.getJoinedChatRooms(),
      ]);

      final history = results[0] as List<MessagingMessage>;
      final rooms = results[1] as List<ChatRoom>;

      // 将房间（群聊或私聊）转换为消息格式以显示在列表中
      final roomMessages = rooms.map((room) {
        if (room.type == 'user' && room.user != null) {
          // 如果是私聊房间，优先使用其中的用户信息
          final lastMsg = room.lastMessage;
          return MessagingMessage(
            id: lastMsg?.id ?? 'room-${room.id}',
            createdAt: lastMsg?.createdAt ?? room.createdAt,
            text: lastMsg?.text ?? '',
            userId: room.user?.id,
            user: room.user,
            recipientId: room.userId,
            isRead: room.unreadCount == 0,
            roomId: room.id,
            room: room,
          );
        }
        
        return MessagingMessage(
          id: room.lastMessage?.id ?? 'room-${room.id}',
          createdAt: room.lastMessage?.createdAt ?? room.createdAt,
          text: room.lastMessage?.text ?? room.topic ?? 'Group Chat',
          roomId: room.id,
          room: room,
        );
      }).toList();

      // 合并历史记录和房间记录。注意：某些旧版 API 可能导致重复，这里简单按 ID 去重
      final allMessages = <String, MessagingMessage>{};
      for (final m in history) {
        allMessages[m.id] = m;
      }
      for (final m in roomMessages) {
        // 如果房间关联了最后一条消息且已在 history 中，则合并信息
        if (allMessages.containsKey(m.id)) {
          final existing = allMessages[m.id]!;
          allMessages[m.id] = existing.copyWith(
            roomId: m.roomId,
            room: m.room,
          );
        } else {
          allMessages[m.id] = m;
        }
      }

      final combined = allMessages.values.toList();
      
      // 按时间倒序排列
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
    
    // 实现本地增量更新，只添加新消息而不重新加载整个历史
    final currentMessages = state.value ?? [];
    
    // 检查消息是否已经存在
    if (currentMessages.any((m) => m.id == message.id)) {
      logger.debug('Misskey消息历史: 消息已存在，跳过添加: ${message.id}');
      return;
    }
    
    logger.debug('Misskey消息历史: 添加新消息: ${message.id}');
    
    // 创建新的消息列表，添加新消息并保持按时间倒序排列
    final updatedMessages = [...currentMessages, message];
    updatedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // 更新状态
    state = AsyncValue.data(updatedMessages);
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey消息历史');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      
      final results = await Future.wait([
        repository.getMessagingHistory(),
        repository.getJoinedChatRooms(),
      ]);

      final history = results[0] as List<MessagingMessage>;
      final rooms = results[1] as List<ChatRoom>;

      final roomMessages = rooms.map((room) {
        if (room.type == 'user' && room.user != null) {
          final lastMsg = room.lastMessage;
          return MessagingMessage(
            id: lastMsg?.id ?? 'room-${room.id}',
            createdAt: lastMsg?.createdAt ?? room.createdAt,
            text: lastMsg?.text ?? '',
            userId: room.user?.id,
            user: room.user,
            recipientId: room.userId,
            isRead: room.unreadCount == 0,
            roomId: room.id,
            room: room,
          );
        }
        
        return MessagingMessage(
          id: room.lastMessage?.id ?? 'room-${room.id}',
          createdAt: room.lastMessage?.createdAt ?? room.createdAt,
          text: room.lastMessage?.text ?? room.topic ?? 'Group Chat',
          roomId: room.id,
          room: room,
        );
      }).toList();

      final allMessages = <String, MessagingMessage>{};
      for (final m in history) {
        allMessages[m.id] = m;
      }
      for (final m in roomMessages) {
        if (allMessages.containsKey(m.id)) {
          final existing = allMessages[m.id]!;
          allMessages[m.id] = existing.copyWith(
            roomId: m.roomId,
            room: m.room,
          );
        } else {
          allMessages[m.id] = m;
        }
      }

      final combined = allMessages.values.toList();
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
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
