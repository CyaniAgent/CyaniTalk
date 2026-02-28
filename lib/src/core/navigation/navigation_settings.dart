// 导航设置管理
//
// 该文件包含NavigationSettings类，用于管理应用程序的导航设置，
// 包括导航元素列表、默认设置等功能。
import 'package:flutter/material.dart';
import 'navigation_item.dart';
import 'navigation_element.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/config/navigation_settings_config.dart';

/// 导航设置状态
class NavigationSettings {
  /// 导航元素列表
  final List<NavigationElement> elements;

  /// 创建导航设置实例
  const NavigationSettings({this.elements = const []});

  /// 获取默认导航设置
  factory NavigationSettings.defaultSettings([BuildContext? context]) {
    final elements = <NavigationElement>[];

    // 添加默认导航项
    for (final config in NavigationSettingsConfig.defaultNavigationItems) {
      if (config['isEnabled'] as bool) {
        elements.add(
          NavigationItemElement(
            item: NavigationItem(
              id: config['id'] as String,
              title: (config['titleKey'] as String).tr(),
              icon: config['icon'] as IconData,
              selectedIcon: config['selectedIcon'] as IconData,
              isEnabled: config['isEnabled'] as bool,
              isRemovable: config['isRemovable'] as bool,
            ),
          ),
        );
      }
    }

    // 添加设置按钮之前的分割线
    elements.add(NavigationDividerElement());

    // 添加设置按钮作为特殊内容
    elements.add(
      NavigationSpecialContentElement(
        contentType: 'settings',
        data: {
          'titleKey': 'nav_settings',
          'icon': Icons.settings_outlined,
          'route': '/settings',
        },
        id: 'settings',
      ),
    );

    return NavigationSettings(elements: elements);
  }

  /// 复制并更新导航设置
  NavigationSettings copyWith({List<NavigationElement>? elements}) {
    return NavigationSettings(elements: elements ?? this.elements);
  }

  /// 获取所有导航项元素
  List<NavigationItemElement> getItemElements() {
    return elements
        .where((element) => element.type == NavigationElementType.item)
        .cast<NavigationItemElement>()
        .toList();
  }

  /// 获取启用的导航项数量
  int getEnabledCount() {
    return getItemElements().where((element) => element.item.isEnabled).length;
  }

  /// 获取可移除的导航项数量
  int getRemovableCount() {
    return getItemElements()
        .where((element) => element.item.isRemovable)
        .length;
  }

  /// 根据ID查找导航项
  NavigationItem? findItemById(String id) {
    final element = elements.firstWhere(
      (element) =>
          element.id == id && element.type == NavigationElementType.item,
      orElse: () => NavigationItemElement(
        item: NavigationItem(
          id: '',
          title: '',
          icon: Icons.star_outline,
          selectedIcon: Icons.star,
        ),
      ),
    );

    if (element is NavigationItemElement) {
      return element.item.id.isNotEmpty ? element.item : null;
    }
    return null;
  }

  /// 更新指定ID的导航项启用状态
  NavigationSettings updateItemEnabled(String id, bool isEnabled) {
    final updatedElements = elements.map((element) {
      if (element.id == id && element is NavigationItemElement) {
        return NavigationItemElement(
          item: element.item.copyWith(isEnabled: isEnabled),
        );
      }
      return element;
    }).toList();
    return copyWith(elements: updatedElements);
  }

  /// 更新导航项排序
  NavigationSettings updateItemOrder(List<NavigationItem> newOrder) {
    final updatedElements = <NavigationElement>[];
    final itemMap = {
      for (final element in elements)
        if (element is NavigationItemElement) element.item.id: element,
    };

    // 按新顺序添加导航项
    for (final item in newOrder) {
      if (itemMap.containsKey(item.id)) {
        updatedElements.add(NavigationItemElement(item: item));
      }
    }

    // 添加非导航项元素
    for (final element in elements) {
      if (element.type != NavigationElementType.item) {
        updatedElements.add(element);
      }
    }

    return copyWith(elements: updatedElements);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationSettings &&
          runtimeType == other.runtimeType &&
          _listEquals(elements, other.elements);

  @override
  int get hashCode => elements.hashCode;

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
