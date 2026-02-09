// 导航设置管理
//
// 该文件包含NavigationSettings类，用于管理应用程序的导航设置，
// 包括导航项列表、默认设置等功能。
import 'package:flutter/material.dart';
import 'navigation_item.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/navigation_settings_config.dart';

/// 导航设置状态
class NavigationSettings {
  /// 导航项列表
  final List<NavigationItem> items;

  /// 创建导航设置实例
  const NavigationSettings({this.items = const []});

  /// 获取默认导航设置
  factory NavigationSettings.defaultSettings([BuildContext? context]) {
    final items = NavigationSettingsConfig.defaultNavigationItems.map((config) {
      return NavigationItem(
        id: config['id'] as String,
        title: (config['titleKey'] as String).tr(),
        icon: config['icon'] as IconData,
        selectedIcon: config['selectedIcon'] as IconData,
        isEnabled: config['isEnabled'] as bool,
        isRemovable: config['isRemovable'] as bool,
      );
    }).toList();

    return NavigationSettings(items: items);
  }

  /// 复制并更新导航设置
  NavigationSettings copyWith({List<NavigationItem>? items}) {
    return NavigationSettings(items: items ?? this.items);
  }

  /// 获取启用的导航项数量
  int getEnabledCount() {
    return items.where((item) => item.isEnabled).length;
  }

  /// 获取可移除的导航项数量
  int getRemovableCount() {
    return items.where((item) => item.isRemovable).length;
  }

  /// 根据ID查找导航项
  NavigationItem findItemById(String id) {
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => NavigationItem(
        id: '',
        title: '',
        icon: Icons.star_outline,
        selectedIcon: Icons.star,
      ),
    );
  }

  /// 更新指定ID的导航项启用状态
  NavigationSettings updateItemEnabled(String id, bool isEnabled) {
    final updatedItems = items.map((item) {
      if (item.id == id) {
        return item.copyWith(isEnabled: isEnabled);
      }
      return item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  /// 更新导航项排序
  NavigationSettings updateItemOrder(List<NavigationItem> newOrder) {
    return copyWith(items: newOrder);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationSettings &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items);

  @override
  int get hashCode => items.hashCode;

  /// 列表相等性检查
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
