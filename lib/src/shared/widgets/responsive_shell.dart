// 响应式布局外壳组件
//
// 该文件包含ResponsiveShell组件，用于实现应用程序的响应式布局和底部导航栏，
// 适配不同屏幕尺寸，在小屏幕上显示底部导航栏，在大屏幕上显示侧边导航栏。
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

/// 应用程序的响应式布局外壳组件
///
/// 使用flutter_adaptive_scaffold实现响应式导航，根据屏幕尺寸自动切换
/// 底部导航栏或侧边导航栏，同时保持各页面的状态。
class ResponsiveShell extends StatelessWidget {
  /// 导航外壳，用于管理底部导航栏的状态和页面切换
  final StatefulNavigationShell navigationShell;

  /// 创建一个新的ResponsiveShell实例
  ///
  /// [navigationShell] - 导航外壳，用于管理底部导航栏的状态和页面切换
  /// [key] - 组件的键，用于唯一标识组件
  const ResponsiveShell({required this.navigationShell, super.key});

  /// 构建响应式布局外壳
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个根据屏幕尺寸适配的AdaptiveScaffold组件
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useDrawer: false,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.public_outlined),
          selectedIcon: const Icon(Icons.public),
          label: 'nav_misskey'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.forum_outlined),
          selectedIcon: const Icon(Icons.forum),
          label: 'nav_flarum'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.cloud_queue_outlined),
          selectedIcon: const Icon(Icons.cloud_queue),
          label: 'nav_drive'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: 'nav_messages'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: 'nav_me'.tr(),
        ),
      ],
      body: (_) => navigationShell,
      smallBody: (_) => navigationShell,
      // 断点定义（可选），默认值通常已经足够
      // < 600: 底部导航栏
      // >= 600: 侧边导航栏
    );
  }
}
