// CyaniTalk应用程序的主入口文件
//
// 该文件包含应用程序的启动逻辑，负责初始化Flutter应用并运行主组件。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyanitalk/src/rust/frb_generated.dart';
import 'src/app.dart';
import 'src/core/core.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/core/services/background_service.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/services/notification_manager.dart';
import 'dart:io';

/// 应用程序的入口点
///
/// 初始化应用程序的各种服务和配置，包括：
/// - 初始化Flutter绑定
/// - 初始化持久化存储
/// - 初始化日志系统
/// - 初始化Rust库
/// - 初始化国际化支持
/// - 创建Riverpod的ProviderContainer
/// - 初始化通知服务
/// - 启动后台服务
/// - 运行CyaniTalkApp组件
///
/// 这是应用程序的启动点，负责所有必要的初始化工作。
///
/// @return 无返回值，应用程序启动后会持续运行
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化持久化存储
  final sharedPrefs = await SharedPreferences.getInstance();

  // 初始化日志系统
  await logger.initialize();
  logger.info('CyaniTalk app started');

  await RustLib.init();
  await EasyLocalization.ensureInitialized();

  // 创建 ProviderContainer 以便在非 Widget 环境中使用 Provider
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  );

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
