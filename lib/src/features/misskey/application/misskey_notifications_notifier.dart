import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/domain/misskey_notification.dart';
import 'misskey_streaming_service.dart';
import '/src/core/core.dart';

part 'misskey_notifications_notifier.g.dart';

@riverpod
class MisskeyNotificationsNotifier extends _$MisskeyNotificationsNotifier {
  @override
  FutureOr<List<MisskeyNotification>> build() async {
    // 1. 立即获取所有依赖，避免在 async gap 之后调用 ref.watch
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    final streamingService = ref.watch(
      misskeyStreamingServiceProvider.notifier,
    );

    logger.info('初始化Misskey通知列表');
    try {
      final repository = await repositoryFuture;
      
      // 2. 异步点之后检查 ref.mounted
      if (!ref.mounted) return [];

      final notifications = await repository.getNotifications();

      if (!ref.mounted) return notifications;

      // 监听实时通知
      final subscription = streamingService.notificationStream.listen((event) {
        logger.debug('通知Notifier收到实时通知，准备刷新');
        _handleNewNotification(event);
      });

      ref.onDispose(() {
        subscription.cancel();
      });

      return notifications;
    } catch (e, stack) {
      // 如果是因为 dispose 导致的 Ref 错误，静默忽略
      if (e.toString().contains('disposed')) {
        logger.debug('Misskey通知: 初始化中途 Provider 已释放');
        return [];
      }

      logger.error('Misskey通知初始化失败', e, stack);
      
      // 处理网络连接错误，不阻塞程序
      if (e.toString().contains('HandshakeException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('DioException')) {
        logger.warning('Misskey通知: 网络连接错误，返回空列表: $e');
        return [];
      }
      
      // 其他错误在挂载时返回错误状态
      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
      return [];
    }
  }

  void _handleNewNotification(Map<String, dynamic> event) {
    try {
      if (!ref.mounted) return;

      // 目前简单实现为直接刷新
      refresh();
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('Misskey通知: 处理新通知失败', e);
    }
  }

  Future<void> refresh() async {
    try {
      if (!ref.mounted) return;

      logger.info('刷新Misskey通知列表');
      state = const AsyncValue.loading();

      final result = await AsyncValue.guard<List<MisskeyNotification>>(
        () async {
          if (!ref.mounted) throw Exception('disposed');
          final repository = await ref.read(misskeyRepositoryProvider.future);
          return await repository.getNotifications();
        },
      );

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('Misskey通知: 刷新失败', e);
    }
  }

  Future<void> loadMore() async {
    try {
      if (state.isLoading || state.isRefreshing || !ref.mounted) return;

      final currentNotifications = state.value ?? [];
      if (currentNotifications.isEmpty) return;

      final lastId = currentNotifications.last.id;
      logger.info('加载更多Misskey通知，起始ID: $lastId');

      final result = await AsyncValue.guard<List<MisskeyNotification>>(
        () async {
          if (!ref.mounted) throw Exception('disposed');
          final repository = await ref.read(misskeyRepositoryProvider.future);
          final newNotifications = await repository.getNotifications(
            untilId: lastId,
          );

          if (!ref.mounted) return currentNotifications;

          return [...currentNotifications, ...newNotifications];
        },
      );

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('Misskey通知: 加载更多失败', e);
    }
  }
}
