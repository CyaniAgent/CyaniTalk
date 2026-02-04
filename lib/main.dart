// CyaniTalk应用程序的主入口文件
//
// 该文件包含应用程序的启动逻辑，负责初始化Flutter应用并运行主组件。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/rust/frb_generated.dart';
import 'src/app.dart';
import 'src/core/core.dart';
import 'src/core/services/background_service.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/services/notification_manager.dart';
import 'dart:io';

/// 应用程序的入口点
///
/// 初始化Riverpod的ProviderScope并运行CyaniTalkApp组件，
/// 这是应用程序的根组件。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志系统
  await logger.initialize();
  logger.info('CyaniTalk app started');

  await RustLib.init();
  await EasyLocalization.ensureInitialized();

  // 创建 ProviderContainer 以便在非 Widget 环境中使用 Provider
  final container = ProviderContainer();

  // 初始化通知服务
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // 启动全局通知管理器
  container.read(notificationManagerProvider).start();

  // 初始化后台服务
  try {
    await initializeBackgroundService();
    logger.info('Background service initialized');
    
    // 在移动端请求通知权限
    if (Platform.isAndroid || Platform.isIOS) {
      await notificationService.requestPermissions();
    }
  } catch (e) {
    logger.error('Failed to initialize background service: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('zh', 'Miao'),
        Locale('ja', 'Miao'),
        Locale('en', 'Miao'),
        Locale('miao', 'Miao'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ja', 'JP'),
      child: UncontrolledProviderScope(
        container: container,
        child: const CyaniTalkApp(),
      ),
    ),
  );
}
