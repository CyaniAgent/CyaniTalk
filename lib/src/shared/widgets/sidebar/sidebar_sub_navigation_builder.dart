// 侧边栏子导航构建工具类
//
// 该文件包含根据配置动态生成子导航项的工具方法
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/config/navigation_settings_config.dart';

/// 子导航项类
class SubNavigationItem {
  final IconData icon;
  final String label;

  const SubNavigationItem({required this.icon, required this.label});
}

/// 侧边栏子导航构建工具类
class SidebarSubNavigationBuilder {
  /// 根据根导航项ID构建子导航
  static Widget buildSubNavigation(
    BuildContext context,
    String rootId,
    bool isLarge,
    int selectedSub,
    ValueChanged<int> onSubSelected,
  ) {
    final subItems = NavigationSettingsConfig.getSubItems(rootId);

    if (subItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final subNavigationItems = subItems.map((item) {
      return SubNavigationItem(
        icon: item['icon'] as IconData,
        label: (item['labelKey'] as String).tr(),
      );
    }).toList();

    return _buildSubNavigationItems(
      context,
      isLarge,
      subNavigationItems,
      selectedSub,
      onSubSelected,
    );
  }

  /// 构建子导航项列表
  static Widget _buildSubNavigationItems(
    BuildContext context,
    bool isLarge,
    List<SubNavigationItem> subs,
    int selectedSub,
    ValueChanged<int> onSubSelected,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: isLarge ? 24 : 0, top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSidebarSubItem(
              context,
              icon: subs[i].icon,
              label: subs[i].label,
              isSelected: selectedSub == i,
              isLarge: isLarge,
              onTap: () => onSubSelected(i),
            ),
        ],
      ),
    );
  }

  /// 构建单个子导航项
  static Widget _buildSidebarSubItem(
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
            color: isSelected
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLarge
              ? Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: '$label subitem',
                        child: Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
