// CyaniTalk应用程序的主组件文件
//
// 该文件包含应用程序的根组件CyaniTalkApp，负责配置应用程序的主题、路由和整体结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/router.dart';

/// CyaniTalk应用程序的根组件
///
/// 负责初始化应用程序的路由配置和主题设置，
/// 是整个应用程序的入口组件。
class CyaniTalkApp extends ConsumerWidget {
  /// 创建一个新的CyaniTalkApp实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const CyaniTalkApp({super.key});

  /// 构建应用程序的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
  ///
  /// 返回配置好的MaterialApp.router组件
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'CyaniTalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
