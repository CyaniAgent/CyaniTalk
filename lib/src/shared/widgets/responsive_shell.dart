// 响应式布局外壳组件
//
// 该文件包含ResponsiveShell组件，用于实现应用程序的响应式布局和导航，
// 适配不同屏幕尺寸，在小屏幕上显示侧边抽屉，在大屏幕上显示侧边导航栏。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/core/navigation/navigation.dart';
import '/src/core/navigation/navigation_element.dart';
import '/src/core/navigation/sub_navigation_notifier.dart';
import 'root_navigation_drawer.dart';
import 'user_navigation_header.dart';
import 'sidebar/sidebar_sub_navigation_builder.dart';

/// 应用程序的响应式布局外壳组件
class ResponsiveShell extends ConsumerStatefulWidget {
  /// 导航外壳，用于管理页面切换
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({required this.navigationShell, super.key});

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell> {
  bool _isTransitioning = false;
  Timer? _transitionTimer;

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  void _onRootSelected(int index, dynamic navigationSettings) {
    // 锁定语义更新，防止 Windows AXTree 报错
    setState(() => _isTransitioning = true);
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isTransitioning = false);
    });

    int branchIndex = NavigationService.mapDisplayIndexToBranchIndex(
      index,
      navigationSettings,
    );
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);

    return navigationSettingsAsync.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (navigationSettings) {
        // 获取所有导航项元素（排除me项和非启用项）
        final rootItemElements = navigationSettings.elements
            .where(
              (element) =>
                  element.type == NavigationElementType.item &&
                  element is NavigationItemElement &&
                  element.item.isEnabled &&
                  element.item.id != 'me',
            )
            .cast<NavigationItemElement>()
            .toList();

        final rootItems = rootItemElements.map((e) => e.item).toList();

        if (rootItems.isEmpty) {
          return Scaffold(
            body: Center(child: Text('navigation_no_items'.tr())),
          );
        }

        final bool isSmall = Breakpoints.small.isActive(context);
        final bool isLarge = Breakpoints.large.isActive(context);

        int selectedRootIndex = NavigationService.mapBranchIndexToDisplayIndex(
          widget.navigationShell.currentIndex,
          navigationSettings,
        );

        final bool isMeSelected =
            widget.navigationShell.currentIndex ==
            NavigationService.getBranchIndexForItem('me');

        if (isMeSelected || selectedRootIndex >= rootItems.length) {
          selectedRootIndex = -1;
        }

        return Scaffold(
          key: rootScaffoldKey,
          drawer: isSmall
              ? RootNavigationDrawer(
                  selectedRootIndex: selectedRootIndex,
                  onRootSelected: (index) =>
                      _onRootSelected(index, navigationSettings),
                )
              : null,
          body: ExcludeSemantics(
            excluding: _isTransitioning,
            child: Row(
              children: [
                if (!isSmall)
                  _buildSidebar(
                    context,
                    ref,
                    selectedRootIndex,
                    rootItems,
                    isLarge,
                    navigationSettings,
                  ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.navigationShell),
              ],
            ),
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
    final isMedium = Breakpoints.medium.isActive(context);
    final sidebarWidth = isLarge
        ? 280.0
        : isMedium
        ? 240.0
        : 80.0;

    return Container(
      width: sidebarWidth,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          UserNavigationHeader(
            isExtended: !Breakpoints.small.isActive(context),
            isSelected: selectedRootIndex == -1,
            onTap: () {
              // 同样应用转换锁定
              setState(() => _isTransitioning = true);
              _transitionTimer?.cancel();
              _transitionTimer = Timer(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _isTransitioning = false);
              });

              int branchIndex = NavigationService.getBranchIndexForItem('me');
              widget.navigationShell.goBranch(
                branchIndex,
                initialLocation:
                    branchIndex == widget.navigationShell.currentIndex,
              );
            },
          ),
          const Divider(indent: 12, endIndent: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: !Breakpoints.small.isActive(context) ? 8 : 4,
              ),
              children: [
                // 渲染所有导航元素
                ..._buildNavigationElements(
                  context,
                  ref,
                  selectedRootIndex,
                  navigationSettings,
                  !Breakpoints.small.isActive(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建导航元素列表
  List<Widget> _buildNavigationElements(
    BuildContext context,
    WidgetRef ref,
    int selectedRootIndex,
    dynamic navigationSettings,
    bool isLarge,
  ) {
    final widgets = <Widget>[];
    int currentItemIndex = 0;

    for (final element in navigationSettings.elements) {
      switch (element.type) {
        case NavigationElementType.item:
          if (element is NavigationItemElement) {
            final item = element.item;
            if (item.isEnabled && item.id != 'me') {
              widgets.add(
                _buildRootSidebarItem(
                  context,
                  ref,
                  item,
                  currentItemIndex,
                  selectedRootIndex,
                  isLarge,
                  navigationSettings,
                ),
              );
              currentItemIndex++;
            }
          }
          break;

        case NavigationElementType.divider:
          if (element is NavigationDividerElement) {
            widgets.add(
              Divider(indent: element.indent, endIndent: element.endIndent),
            );
          }
          break;

        case NavigationElementType.customWidget:
          if (element is NavigationCustomWidgetElement) {
            widgets.add(element.builder(context));
          }
          break;

        case NavigationElementType.specialContent:
          if (element is NavigationSpecialContentElement) {
            widgets.add(_buildSpecialContentElement(context, element, isLarge));
          }
          break;
      }
    }

    return widgets;
  }

  /// 构建特殊内容元素
  Widget _buildSpecialContentElement(
    BuildContext context,
    NavigationSpecialContentElement element,
    bool isLarge,
  ) {
    final theme = Theme.of(context);
    final data = element.data;

    try {
      final titleKey = data['titleKey'] as String;
      final route = data['route'] as String;
      final icon = data['icon'] as IconData;

      return ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: isLarge
            ? Semantics(
                label: '${titleKey.tr()} button',
                child: Text(
                  titleKey.tr(),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            : null,
        onTap: () => GoRouter.of(context).push(route),
        hoverColor: theme.colorScheme.secondaryContainer.withAlpha(80),
        focusColor: theme.colorScheme.secondaryContainer,
      );
    } catch (e) {
      // 处理错误，返回一个默认的占位符
      return ListTile(
        leading: Icon(Icons.error_outline, color: theme.colorScheme.error),
        title: isLarge
            ? Semantics(label: 'Error button', child: Text('Error'))
            : null,
      );
    }
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
              color: isSelected
                  ? theme.colorScheme.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLarge
                ? Row(
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurfaceVariant,
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
                : const ExcludeSemantics(
                    child: SizedBox(width: double.infinity, height: 0),
                  ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSidebarSubNavigation(
    BuildContext context,
    WidgetRef ref,
    String rootId,
    bool isLarge,
  ) {
    if (rootId == 'misskey') {
      final selectedSub = ref.watch(misskeySubIndexProvider);
      return SidebarSubNavigationBuilder.buildSubNavigation(
        context,
        rootId,
        isLarge,
        selectedSub,
        (i) => ref.read(misskeySubIndexProvider.notifier).set(i),
      );
    } else if (rootId == 'flarum') {
      final selectedSub = ref.watch(forumSubIndexProvider);
      return SidebarSubNavigationBuilder.buildSubNavigation(
        context,
        rootId,
        isLarge,
        selectedSub,
        (i) => ref.read(forumSubIndexProvider.notifier).set(i),
      );
    }
    return const SizedBox.shrink();
  }
}
