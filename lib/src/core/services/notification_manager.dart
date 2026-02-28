import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/application/misskey_streaming_service.dart';
import '/src/features/profile/application/notification_settings_provider.dart';
import '/src/features/flarum/application/flarum_providers.dart';
import '/src/features/auth/application/auth_service.dart';
import 'notification_service.dart';
import 'sound_service.dart';
import '/src/core/core.dart';

/// 全局通知管理器
///
/// 监听各个平台的实时事件并根据用户设置触发系统通知和声音
/// 支持Misskey的实时流事件和Flarum的轮询通知。
class NotificationManager {
  /// Riverpod的引用，用于获取其他Provider
  final Ref ref;

  /// Misskey笔记事件订阅
  StreamSubscription? _misskeyNoteSubscription;

  /// Misskey消息事件订阅
  StreamSubscription? _misskeyMessageSubscription;

  /// Misskey通知事件订阅
  StreamSubscription? _misskeyNotificationSubscription;

  /// Flarum轮询定时器
  Timer? _flarumTimer;

  /// 上次检查Flarum通知的时间
  DateTime? _lastFlarumCheck;

  NotificationManager(this.ref);

  /// 启动监听
  ///
  /// 启动所有平台的通知监听，包括Misskey的实时流监听和Flarum的轮询检查。
  ///
  /// @return 无返回值
  void start() {
    _setupMisskeyListeners();
    _setupFlarumPolling();
    logger.info('NotificationManager: Started real-time listeners');
  }

  /// 停止监听
  ///
  /// 停止所有平台的通知监听，取消所有订阅和定时器。
  ///
  /// @return 无返回值
  void stop() {
    _misskeyNoteSubscription?.cancel();
    _misskeyMessageSubscription?.cancel();
    _misskeyNotificationSubscription?.cancel();
    _flarumTimer?.cancel();
    logger.info('NotificationManager: Stopped real-time listeners');
  }

  /// 设置Misskey监听
  ///
  /// 设置Misskey平台的实时事件监听，包括笔记事件、消息事件和通知事件。
  /// 根据事件类型播放不同的声音并显示系统通知。
  ///
  /// @return 无返回值
  void _setupMisskeyListeners() {
    final streamingService = ref.read(misskeyStreamingServiceProvider.notifier);
    final soundService = ref.read(soundServiceProvider);

    // 监听笔记事件 (实时动态 & 发布动态)
    _misskeyNoteSubscription = streamingService.noteStream.listen((event) {
      if (event.isDelete || event.note == null) return;

      final currentAccount = ref
          .read(selectedMisskeyAccountProvider)
          .asData
          ?.value;
      // 提取 userId (Misskey 存储在 Account.id 中，格式通常是 userId@host)
      final myId = currentAccount?.id.split('@').first;
      final isMyNote = event.note?.user?.id == myId;

      if (isMyNote) {
        // 发布动态音效
        soundService.playMisskeyPosting();
      } else {
        // 实时动态音效
        soundService.playMisskeyRealtimePost();

        // 系统通知 (如果设置开启)
        final settings = ref.read(notificationSettingsProvider).value;
        if (settings?.misskeyRealtimePost == true) {
          final userName =
              event.note?.user?.name ?? event.note?.user?.username ?? 'Unknown';
          NotificationService().showNotification(
            id: event.note.hashCode,
            title: 'Misskey: $userName',
            body: event.note?.text ?? 'New post received!',
            groupKey: 'misskey_posts',
          );
        }
      }
    });

    // 监听消息事件
    _misskeyMessageSubscription = streamingService.messageStream.listen((
      message,
    ) {
      soundService.playMisskeyMessages();

      final settings = ref.read(notificationSettingsProvider).value;
      if (settings?.misskeyMessages == true) {
        NotificationService().showNotification(
          id: message.hashCode,
          title: 'Misskey Message',
          body: message.text ?? 'New message received!',
          groupKey: 'misskey_messages',
        );
      }
    });

    // 监听通知事件 (系统通知 & 表情回应)
    _misskeyNotificationSubscription = streamingService.notificationStream
        .listen((notif) {
          final type = notif['type'] as String?;

          if (type == 'reaction') {
            soundService.playMisskeyEmojiReactions();
          } else {
            soundService.playMisskeyNotifications();

            // 这里可以根据需要添加系统弹窗通知
          }
        });
  }

  /// 设置Flarum轮询
  ///
  /// 设置Flarum平台的通知轮询检查，每2分钟检查一次新通知。
  /// 如果有新通知，根据用户设置显示系统通知。
  ///
  /// @return 无返回值
  void _setupFlarumPolling() {
    _lastFlarumCheck = DateTime.now();

    // 每 2 分钟检查一次 Flarum 通知
    _flarumTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      final settings = ref.read(notificationSettingsProvider).value;
      if (settings?.flarumNotifications != true) return;

      try {
        final notificationsAsync = ref.read(flarumNotificationsProvider);
        notificationsAsync.whenData((notifications) {
          if (notifications.isEmpty) return;

          final latest = notifications.first;
          final createdAt = DateTime.tryParse(latest.createdAt);
          if (createdAt == null) return;

          if (createdAt.isAfter(_lastFlarumCheck!)) {
            NotificationService().showNotification(
              id: latest.id.hashCode,
              title: 'Flarum Notification',
              body:
                  latest.contentType ?? 'You have a new notification on Flarum',
              groupKey: 'flarum_notifications',
            );
            _lastFlarumCheck = createdAt;
          }
        });
      } catch (e) {
        logger.error('Flarum notification poll failed', e);
      }
    });
  }
}

/// 提供 NotificationManager 的 Provider
final notificationManagerProvider = Provider((ref) => NotificationManager(ref));
