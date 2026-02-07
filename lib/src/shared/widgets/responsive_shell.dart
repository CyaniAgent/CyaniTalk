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

  /// 导航项分支索引映射
  static final Map<String, int> _itemBranchIndexMap = {
    'misskey': 0,
    'flarum': 1,
    'drive': 2,
    'messages': 3,
    'me': 4,
  };

  /// 获取导航项对应的分支索引
  int _getBranchIndexForItem(String itemId) {
    return _itemBranchIndexMap[itemId] ?? 0;
  }

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

    // 遍历启用的导航项
    for (final item in navigationSettings.items) {
      if (item.isEnabled) {
        if (currentDisplayIndex == displayIndex) {
          return _getBranchIndexForItem(item.id);
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

    // 遍历启用的导航项
    for (final item in navigationSettings.items) {
      if (item.isEnabled) {
        if (_getBranchIndexForItem(item.id) == branchIndex) {
          return currentDisplayIndex;
        }
        currentDisplayIndex++;
      }
    }

    return 0; // 默认返回第一个显示索引
  }

  /// 构建导航目标
  NavigationDestination _buildNavigationDestination(NavigationItem item) {
    return NavigationDestination(
      icon: Icon(item.icon),
      selectedIcon: Icon(_getSelectedIcon(item.icon)),
      label: item.title,
    );
  }

  /// 获取选中状态的图标
  IconData _getSelectedIcon(IconData icon) {
    // 简单的图标映射，将outline图标转换为非outline图标
    if (icon == Icons.public_outlined) return Icons.public;
    if (icon == Icons.forum_outlined) return Icons.forum;
    if (icon == Icons.cloud_queue_outlined) return Icons.cloud_queue;
    if (icon == Icons.chat_bubble_outline) return Icons.chat_bubble;
    if (icon == Icons.person_outline) return Icons.person;
    return icon;
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
        // 构建启用的导航目标列表
        final destinations = navigationSettings.items
            .where((item) => item.isEnabled)
            .map(_buildNavigationDestination)
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
