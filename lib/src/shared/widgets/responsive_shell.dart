// 响应式布局外壳组件
//
// 该文件包含ResponsiveShell组件，用于实现应用程序的响应式布局和底部导航栏，
// 适配不同屏幕尺寸，在小屏幕上显示底部导航栏，在大屏幕上显示侧边导航栏。
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/navigation.dart';
import 'root_navigation_drawer.dart';

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

  /// 构建侧边导航目标
  NavigationRailDestination _buildNavigationRailDestination(
    NavigationItem item,
  ) {
    return NavigationRailDestination(
      icon: Icon(item.icon),
      selectedIcon: Icon(item.selectedIcon),
      label: Text(item.title),
    );
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (navigationSettings) {
        // 确保至少有一个目标
        if (navigationSettings.items.where((item) => item.isEnabled).isEmpty) {
          return Scaffold(
            body: Center(child: Text('navigation_no_items'.tr())),
          );
        }

        // 计算当前索引
        int selectedIndex = NavigationService.mapBranchIndexToDisplayIndex(
          navigationShell.currentIndex,
          navigationSettings,
        );

        if (selectedIndex >=
            navigationSettings.items.where((item) => item.isEnabled).length) {
          selectedIndex = 0;
        }

        return Scaffold(
          drawer: RootNavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              int branchIndex = NavigationService.mapDisplayIndexToBranchIndex(
                index,
                navigationSettings,
              );
              navigationShell.goBranch(
                branchIndex,
                initialLocation: branchIndex == navigationShell.currentIndex,
              );
            },
          ),
          body: AdaptiveLayout(
            primaryNavigation: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.mediumAndUp: SlotLayout.from(
                  key: const Key('primaryNavigationMedium'),
                  builder: (_) => NavigationRail(
                    extended: Breakpoints.large.isActive(context),
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      int branchIndex =
                          NavigationService.mapDisplayIndexToBranchIndex(
                        index,
                        navigationSettings,
                      );
                      navigationShell.goBranch(
                        branchIndex,
                        initialLocation:
                            branchIndex == navigationShell.currentIndex,
                      );
                    },
                    destinations: navigationSettings.items
                        .where((item) => item.isEnabled)
                        .map(_buildNavigationRailDestination)
                        .toList(),
                  ),
                ),
              },
            ),
            body: SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                Breakpoints.standard: SlotLayout.from(
                  key: const Key('body'),
                  builder: (_) => navigationShell,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
