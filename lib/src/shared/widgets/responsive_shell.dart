// 响应式布局外壳组件
//
// 该文件包含ResponsiveShell组件，用于实现应用程序的响应式布局和底部导航栏，
// 适配不同屏幕尺寸，在小屏幕上显示底部导航栏，在大屏幕上显示侧边导航栏。
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/presentation/settings/navigation_settings_page.dart';

/// 应用程序的响应式布局外壳组件
///
/// 使用flutter_adaptive_scaffold实现响应式导航，根据屏幕尺寸自动切换
/// 底部导航栏或侧边导航栏，同时保持各页面的状态。
class ResponsiveShell extends ConsumerWidget {
  /// 导航外壳，用于管理底部导航栏的状态和页面切换
  final StatefulNavigationShell navigationShell;

  /// 创建一个新的ResponsiveShell实例
  ///
  /// [navigationShell] - 导航外壳，用于管理底部导航栏的状态和页面切换
  /// [key] - 组件的键，用于唯一标识组件
  const ResponsiveShell({required this.navigationShell, super.key});

  /// 导航项配置，包含分支索引和显示条件
  static final List<Map<String, dynamic>> _navigationItems = [
    {
      'branchIndex': 0,
      'showCondition': (NavigationSettings settings) => settings.showMisskey,
    },
    {
      'branchIndex': 1,
      'showCondition': (NavigationSettings settings) => settings.showFlarum,
    },
    {
      'branchIndex': 2,
      'showCondition': (NavigationSettings settings) => settings.showDrive,
    },
    {
      'branchIndex': 3,
      'showCondition': (NavigationSettings settings) => settings.showMessages,
    },
    {
      'branchIndex': 4,
      'showCondition': (NavigationSettings settings) => settings.showMe,
    },
  ];

  /// 将显示索引映射到分支索引
  ///
  /// [displayIndex] - 显示索引
  /// [navigationSettings] - 导航设置
  ///
  /// 返回对应的分支索引
  int _mapDisplayIndexToBranchIndex(
    int displayIndex,
    NavigationSettings navigationSettings,
  ) {
    int currentDisplayIndex = 0;

    // 遍历导航项配置，查找匹配的分支索引
    for (final item in _navigationItems) {
      final showCondition =
          item['showCondition'] as bool Function(NavigationSettings);
      if (showCondition(navigationSettings)) {
        if (currentDisplayIndex == displayIndex) {
          return item['branchIndex'] as int;
        }
        currentDisplayIndex++;
      }
    }

    return 0; // 默认返回第一个分支
  }

  /// 将分支索引映射到显示索引
  ///
  /// [branchIndex] - 分支索引
  /// [navigationSettings] - 导航设置
  ///
  /// 返回对应的显示索引
  int _mapBranchIndexToDisplayIndex(
    int branchIndex,
    NavigationSettings navigationSettings,
  ) {
    int currentDisplayIndex = 0;

    // 遍历导航项配置，查找匹配的显示索引
    for (final item in _navigationItems) {
      final showCondition =
          item['showCondition'] as bool Function(NavigationSettings);
      if (showCondition(navigationSettings)) {
        if (item['branchIndex'] as int == branchIndex) {
          return currentDisplayIndex;
        }
        currentDisplayIndex++;
      }
    }

    return 0; // 默认返回第一个显示索引
  }

  /// 构建响应式布局外壳
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod引用，用于访问状态
  ///
  /// 返回一个根据屏幕尺寸适配的AdaptiveScaffold组件
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取导航设置
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);

    return navigationSettingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(),
      data: (navigationSettings) {
        // 导航目标配置，包含图标、标签和显示条件
        final navigationDestinations = [
          {
            'showCondition': (NavigationSettings settings) =>
                settings.showMisskey,
            'destination': NavigationDestination(
              icon: const Icon(Icons.public_outlined),
              selectedIcon: const Icon(Icons.public),
              label: 'nav_misskey'.tr(),
            ),
          },
          {
            'showCondition': (NavigationSettings settings) =>
                settings.showFlarum,
            'destination': NavigationDestination(
              icon: const Icon(Icons.forum_outlined),
              selectedIcon: const Icon(Icons.forum),
              label: 'nav_flarum'.tr(),
            ),
          },
          {
            'showCondition': (NavigationSettings settings) =>
                settings.showDrive,
            'destination': NavigationDestination(
              icon: const Icon(Icons.cloud_queue_outlined),
              selectedIcon: const Icon(Icons.cloud_queue),
              label: 'nav_drive'.tr(),
            ),
          },
          {
            'showCondition': (NavigationSettings settings) =>
                settings.showMessages,
            'destination': NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: const Icon(Icons.chat_bubble),
              label: 'nav_messages'.tr(),
            ),
          },
          {
            'showCondition': (NavigationSettings settings) => settings.showMe,
            'destination': NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: 'nav_me'.tr(),
            ),
          },
        ];

        // 根据设置构建目标列表
        final destinations = navigationDestinations
            .where((item) {
              final showCondition =
                  item['showCondition'] as bool Function(NavigationSettings)?;
              return showCondition != null && showCondition(navigationSettings);
            })
            .map((item) => item['destination'] as NavigationDestination)
            .toList();

        // 确保至少有一个目标
        if (destinations.isEmpty) {
          return Center(child: Text('navigation_no_items'.tr()));
        }

        // 计算当前索引 - 使用辅助方法将原始分支索引映射到显示索引
        int selectedIndex = _mapBranchIndexToDisplayIndex(
          navigationShell.currentIndex,
          navigationSettings,
        );

        // 确保索引有效
        if (selectedIndex >= destinations.length) {
          selectedIndex = 0;
        }

        return AdaptiveScaffold(
          useDrawer: false,
          selectedIndex: selectedIndex,
          onSelectedIndexChange: (index) {
            // 由于目标可能被隐藏，需要映射到实际的分支索引
            int branchIndex = _mapDisplayIndexToBranchIndex(
              index,
              navigationSettings,
            );

            navigationShell.goBranch(
              branchIndex,
              initialLocation: branchIndex == navigationShell.currentIndex,
            );
          },
          destinations: destinations,
          body: (_) => navigationShell,
          // 断点定义（可选），默认值通常已经足够
          // < 600: 底部导航栏
          // >= 600: 侧边导航栏
        );
      },
    );
  }
}
