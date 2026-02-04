import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/misskey/application/misskey_streaming_service.dart';
import '../../features/profile/application/notification_settings_provider.dart';
import '../../features/flarum/application/flarum_providers.dart';
import '../../features/auth/application/auth_service.dart';
import 'notification_service.dart';
import 'sound_service.dart';
import '../core.dart';

/// 全局通知管理器
/// 
/// 监听各个平台的实时事件并根据用户设置触发系统通知和声音
class NotificationManager {
  final Ref ref;
  StreamSubscription? _misskeyNoteSubscription;
  StreamSubscription? _misskeyMessageSubscription;
  StreamSubscription? _misskeyNotificationSubscription;
  Timer? _flarumTimer;
  DateTime? _lastFlarumCheck;

  NotificationManager(this.ref);

  /// 启动监听
  void start() {
    _setupMisskeyListeners();
    _setupFlarumPolling();
    logger.info('NotificationManager: Started real-time listeners');
  }

  /// 停止监听
  void stop() {
    _misskeyNoteSubscription?.cancel();
    _misskeyMessageSubscription?.cancel();
    _misskeyNotificationSubscription?.cancel();
    _flarumTimer?.cancel();
    logger.info('NotificationManager: Stopped real-time listeners');
  }

  void _setupMisskeyListeners() {
    final streamingService = ref.read(misskeyStreamingServiceProvider.notifier);
    final soundService = ref.read(soundServiceProvider);
    
    // 监听笔记事件 (实时动态 & 发布动态)
    _misskeyNoteSubscription = streamingService.noteStream.listen((event) {
      if (event.isDelete || event.note == null) return;

      final currentAccount = ref.read(selectedMisskeyAccountProvider).asData?.value;
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
          final userName = event.note?.user?.name ?? event.note?.user?.username ?? 'Unknown';
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
    _misskeyMessageSubscription = streamingService.messageStream.listen((message) {
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
    _misskeyNotificationSubscription = streamingService.notificationStream.listen((notif) {
      final type = notif['type'] as String?;
      
      if (type == 'reaction') {
        soundService.playMisskeyEmojiReactions();
      } else {
        soundService.playMisskeyNotifications();
        
        // 这里可以根据需要添加系统弹窗通知
      }
    });
  }

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
              body: latest.contentType ?? 'You have a new notification on Flarum',
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
