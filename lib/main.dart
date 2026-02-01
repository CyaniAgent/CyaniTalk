// CyaniTalk应用程序的主入口文件
//
// 该文件包含应用程序的启动逻辑，负责初始化Flutter应用并运行主组件。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/app.dart';
import 'src/core/core.dart';

/// 应用程序的入口点
///
/// 初始化Riverpod的ProviderScope并运行CyaniTalkApp组件，
/// 这是应用程序的根组件。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 初始化日志系统
  await logger.initialize();
  logger.info('CyaniTalk app started');

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
      child: const ProviderScope(child: CyaniTalkApp()),
    ),
  );
}
