import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/domain/announcement.dart';
import '/src/core/utils/logger.dart';

part 'misskey_announcements_notifier.g.dart';

@riverpod
class MisskeyAnnouncementsNotifier extends _$MisskeyAnnouncementsNotifier {
  @override
  FutureOr<List<Announcement>> build() async {
    logger.info('MisskeyAnnouncementsNotifier: Initializing announcements');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);

      if (!ref.mounted) return [];

      final announcements = await repository.getAnnouncements();

      if (!ref.mounted) return announcements;

      logger.info(
        'MisskeyAnnouncementsNotifier: Loaded ${announcements.length} announcements',
      );

      return announcements;
    } catch (e, stack) {
      // 如果是因为 dispose 导致的 Ref 错误，静默忽略
      if (e.toString().contains('disposed')) {
        logger.debug('MisskeyAnnouncementsNotifier: Provider disposed during initialization');
        return [];
      }

      logger.error('MisskeyAnnouncementsNotifier: Failed to load announcements', e, stack);

      // 处理网络连接错误，不阻塞程序
      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('DioException')) {
        logger.warning('MisskeyAnnouncementsNotifier: Network error, returning empty list: $e');
        return [];
      }

      // 其他错误在挂载时返回错误状态
      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
      return [];
    }
  }

  /// 标记公告为已读
  ///
  /// @param announcementId 要标记为已读的公告 ID
  Future<void> markAsRead(String announcementId) async {
    try {
      logger.info('MisskeyAnnouncementsNotifier: Marking announcement as read: $announcementId');

      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.readAnnouncement(announcementId);

      logger.info('MisskeyAnnouncementsNotifier: Successfully marked as read: $announcementId');

      // 刷新公告列表以更新已读状态
      refresh();
    } catch (e, stack) {
      logger.error('MisskeyAnnouncementsNotifier: Failed to mark as read', e, stack);

      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
    }
  }

  /// 刷新公告列表
  Future<void> refresh() async {
    logger.info('MisskeyAnnouncementsNotifier: Refreshing announcements');
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final announcements = await repository.getAnnouncements();

      if (ref.mounted) {
        state = AsyncData(announcements);
      }
    } catch (e, stack) {
      logger.error('MisskeyAnnouncementsNotifier: Failed to refresh', e, stack);

      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
    }
  }
}