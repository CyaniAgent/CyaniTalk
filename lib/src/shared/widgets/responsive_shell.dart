// 响应式布局外壳组件
//
// 该文件包含ResponsiveShell组件，用于实现应用程序的响应式布局和导航，
// 适配不同屏幕尺寸，在小屏幕上显示侧边抽屉，在大屏幕上显示侧边导航栏。
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/navigation.dart';
import '../../core/navigation/sub_navigation_notifier.dart';
import 'root_navigation_drawer.dart';
import 'user_navigation_header.dart';

/// 应用程序的响应式布局外壳组件
///
/// 根据屏幕尺寸自动切换侧边抽屉或侧边导航栏，同时保持各页面的状态。
class ResponsiveShell extends ConsumerWidget {
  /// 导航外壳，用于管理页面切换
  final StatefulNavigationShell navigationShell;

  /// 创建一个新的ResponsiveShell实例
  const ResponsiveShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);

    return navigationSettingsAsync.when(
      loading: () => const Scaffold(
        body: SizedBox.shrink(),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (navigationSettings) {
        // 过滤启用的导航项 (Excluding 'me' as it's in the header)
        final rootItems = navigationSettings.items
            .where((item) => item.isEnabled && item.id != 'me')
            .toList();

        if (rootItems.isEmpty) {
          return Scaffold(
            body: Center(child: Text('navigation_no_items'.tr())),
          );
        }

        final bool isSmall = Breakpoints.small.isActive(context);
        final bool isLarge = Breakpoints.large.isActive(context);

        // Map branch index to displaying root index (excluding 'me')
        int selectedRootIndex = NavigationService.mapBranchIndexToDisplayIndex(
          navigationShell.currentIndex,
          navigationSettings,
        );
        
        // Explicitly check if we are on the 'me' branch
        final bool isMeSelected = navigationShell.currentIndex == NavigationService.getBranchIndexForItem('me');

        if (isMeSelected || selectedRootIndex >= rootItems.length) {
          selectedRootIndex = -1; // Header handled selection
        }

        return Scaffold(
          key: rootScaffoldKey,
          drawer: isSmall
              ? RootNavigationDrawer(
                  selectedRootIndex: selectedRootIndex,
                  onRootSelected: (index) => _onRootSelected(index, navigationSettings),
                )
              : null,
          body: Row(
            children: [
              if (!isSmall)
                _buildSidebar(context, ref, selectedRootIndex, rootItems, isLarge, navigationSettings),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: navigationShell,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    int selectedRootIndex,
    List<NavigationItem> rootItems,
    bool isLarge,
    dynamic navigationSettings,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      width: isLarge ? 256 : 80,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          UserNavigationHeader(
            isExtended: isLarge,
            isSelected: selectedRootIndex == -1,
            onTap: () {
              int branchIndex = NavigationService.getBranchIndexForItem('me');
              navigationShell.goBranch(
                branchIndex,
                initialLocation: branchIndex == navigationShell.currentIndex,
              );
            },
          ),
          const Divider(indent: 12, endIndent: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (int i = 0; i < rootItems.length; i++) ...[
                  _buildRootSidebarItem(context, ref, rootItems[i], i, selectedRootIndex, isLarge, navigationSettings),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootSidebarItem(
    BuildContext context,
    WidgetRef ref,
    NavigationItem item,
    int index,
    int selectedRootIndex,
    bool isLarge,
    dynamic navigationSettings,
  ) {
    final isSelected = index == selectedRootIndex;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _onRootSelected(index, navigationSettings),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isLarge ? 16 : 0),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLarge
                ? Row(
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isSelected 
                ? _buildSidebarSubNavigation(context, ref, item.id, isLarge)
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSidebarSubNavigation(BuildContext context, WidgetRef ref, String rootId, bool isLarge) {
    if (rootId == 'misskey') {
      return _buildMisskeySidebarSubs(context, ref, isLarge);
    } else if (rootId == 'flarum') {
      return _buildForumSidebarSubs(context, ref, isLarge);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMisskeySidebarSubs(BuildContext context, WidgetRef ref, bool isLarge) {
    final selectedSub = ref.watch(misskeySubIndexProvider);
    final subs = [
      {'icon': Icons.timeline, 'label': 'misskey_drawer_timeline'.tr()},
      {'icon': Icons.collections_bookmark, 'label': 'misskey_drawer_clips'.tr()},
      {'icon': Icons.satellite_alt, 'label': 'misskey_drawer_antennas'.tr()},
      {'icon': Icons.hub, 'label': 'misskey_drawer_channels'.tr()},
      {'icon': Icons.explore, 'label': 'misskey_drawer_explore'.tr()},
      {'icon': Icons.person_add, 'label': 'misskey_drawer_follow_requests'.tr()},
      {'icon': Icons.campaign, 'label': 'misskey_drawer_announcements'.tr()},
      {'icon': Icons.terminal, 'label': 'misskey_drawer_aiscript_console'.tr()},
    ];

    return Padding(
      padding: EdgeInsets.only(left: isLarge ? 24 : 0, top: 4),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSidebarSubItem(
              context,
              icon: subs[i]['icon'] as IconData,
              label: subs[i]['label'] as String,
              isSelected: selectedSub == i,
              isLarge: isLarge,
              onTap: () => ref.read(misskeySubIndexProvider.notifier).set(i),
            ),
        ],
      ),
    );
  }

  Widget _buildForumSidebarSubs(BuildContext context, WidgetRef ref, bool isLarge) {
    final selectedSub = ref.watch(forumSubIndexProvider);
    final subs = [
      {'icon': Icons.forum, 'label': 'flarum_drawer_discussions'.tr()},
      {'icon': Icons.label, 'label': 'flarum_drawer_tags'.tr()},
      {'icon': Icons.notifications, 'label': 'flarum_drawer_notifications'.tr()},
    ];

    return Padding(
      padding: EdgeInsets.only(left: isLarge ? 24 : 0, top: 4),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSidebarSubItem(
              context,
              icon: subs[i]['icon'] as IconData,
              label: subs[i]['label'] as String,
              isSelected: selectedSub == i,
              isLarge: isLarge,
              onTap: () => ref.read(forumSubIndexProvider.notifier).set(i),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarSubItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isLarge,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 0),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surfaceContainerHighest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLarge
              ? Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }

  void _onRootSelected(int index, dynamic navigationSettings) {
    int branchIndex = NavigationService.mapDisplayIndexToBranchIndex(
      index,
      navigationSettings,
    );
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
