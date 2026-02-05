import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/misskey_notification.dart';
import 'misskey_streaming_service.dart';
import '../../../core/core.dart';

part 'misskey_notifications_notifier.g.dart';

@riverpod
class MisskeyNotificationsNotifier extends _$MisskeyNotificationsNotifier {
  @override
  FutureOr<List<MisskeyNotification>> build() async {
    logger.info('初始化Misskey通知列表');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      final notifications = await repository.getNotifications();

      // 监听实时通知
      final streamingService = ref.watch(misskeyStreamingServiceProvider.notifier);
      final subscription = streamingService.notificationStream.listen((event) {
        logger.debug('通知Notifier收到实时通知，准备刷新');
        _handleNewNotification(event);
      });

      ref.onDispose(() {
        subscription.cancel();
      });

      return notifications;
    } catch (e, stack) {
      logger.error('Misskey通知初始化失败', e, stack);
      rethrow;
    }
  }

  void _handleNewNotification(Map<String, dynamic> event) {
    if (!ref.mounted) return;
    
    // 目前简单实现为直接刷新
    refresh();
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey通知列表');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getNotifications();
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) return;

    final currentNotifications = state.value ?? [];
    if (currentNotifications.isEmpty) return;

    final lastId = currentNotifications.last.id;
    logger.info('加载更多Misskey通知，起始ID: $lastId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newNotifications = await repository.getNotifications(
        untilId: lastId,
      );

      if (!ref.mounted) return currentNotifications;

      return [...currentNotifications, ...newNotifications];
    });
  }
}
