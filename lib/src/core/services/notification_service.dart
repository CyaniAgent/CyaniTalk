import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 通知服务类
/// 
/// 负责处理通知权限请求和通知显示
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知服务
  Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: WindowsInitializationSettings(
        appName: 'CyaniTalk',
        appUserModelId: 'app.CyaniAgent.Talk',
        guid: '3F2504E0-4F89-11D3-9A0C-0305E82C3301',
      ),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification tapped: ${details.id}');
        // TODO: 在此处添加导航逻辑，例如跳转到对应的消息页面
        // 根据 details.payload 来判断跳转目标
      },
    );
  }

  /// 请求通知权限
  /// 
  /// 在移动设备上会弹出权限请求对话框
  /// 在桌面设备上通常自动授予
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    
    // 桌面端（Windows/Linux）通常不需要动态请求权限
    return true;
  }

  /// 检查权限状态
  Future<bool> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    // iOS/macOS 暂时通过重新请求（非静默）或者假设已授权
    // 桌面端默认返回 true
    return true;
  }

  /// 显示通知
  /// 
  /// [id] 通知的唯一标识符
  /// [title] 通知标题
  /// [body] 通知内容
  /// [payload] 可选的附加数据，点击通知时会传回
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? groupKey,
  }) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      'cyanitalk_general_channel',
      'CyaniTalk Notifications',
      channelDescription: 'General notifications for CyaniTalk',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );
    
    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: groupKey,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
