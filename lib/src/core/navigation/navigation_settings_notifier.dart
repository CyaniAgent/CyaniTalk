// 导航设置状态管理器
//
// 该文件包含NavigationSettingsNotifier类，用于管理应用程序的导航设置状态，
// 包括从存储加载设置、保存设置、更新导航项状态等功能。
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_settings.dart';
import 'navigation_item.dart';
import 'navigation_element.dart';

part 'navigation_settings_notifier.g.dart';

/// 导航设置状态管理器
@Riverpod(keepAlive: true)
class NavigationSettingsNotifier extends _$NavigationSettingsNotifier {
  /// 初始化导航设置状态
  @override
  Future<NavigationSettings> build() async {
    // 初始化时尝试从持久化存储加载设置
    final settings = await _loadFromStorage();
    return settings;
  }

  /// 从持久化存储加载设置
  Future<NavigationSettings> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载导航项配置
      final navigationItemsString = prefs.getString('navigation_items');
      final navigationOrderString = prefs.getString('navigation_order');

      NavigationSettings settings;

      if (navigationItemsString != null && navigationOrderString != null) {
        try {
          // 解析导航项配置
          final List<dynamic> itemsJson = navigationItemsString.split(';');
          final List<NavigationItem> items = [];

          for (final itemJson in itemsJson) {
            if (itemJson.isNotEmpty) {
              try {
                final Map<String, dynamic> itemMap = _parseJsonString(itemJson);
                final item = NavigationItem(
                  id: itemMap['id'] as String,
                  title: itemMap['title'] as String,
                  icon: NavigationItem.getIconFromId(itemMap['id'] as String),
                  selectedIcon: NavigationItem.getSelectedIconFromId(
                    itemMap['id'] as String,
                  ),
                  isEnabled: itemMap['isEnabled'] as bool,
                  isRemovable: itemMap['isRemovable'] as bool,
                );
                items.add(item);
              } catch (e) {
                // 解析失败，跳过该项
              }
            }
          }

          // 解析排序顺序
          final List<String> orderList = navigationOrderString.split(',');
          final List<NavigationItem> orderedItems = [];

          // 按照存储的顺序排列导航项
          for (final id in orderList) {
            final item = items.firstWhere(
              (item) => item.id == id,
              orElse: () => NavigationItem(
                id: '',
                title: '',
                icon: Icons.star_outline,
                selectedIcon: Icons.star,
              ),
            );
            if (item.id.isNotEmpty) {
              orderedItems.add(item);
            }
          }

          // 添加未在排序中的导航项
          for (final item in items) {
            if (!orderedItems.any((orderedItem) => orderedItem.id == item.id)) {
              orderedItems.add(item);
            }
          }

          // 创建导航元素列表
          final elements = <NavigationElement>[];
          for (final item in orderedItems) {
            elements.add(NavigationItemElement(item: item));
          }
          // 添加分割线和设置按钮
          elements.add(NavigationDividerElement());
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

          settings = NavigationSettings(elements: elements);
        } catch (e) {
          // 解析失败，使用默认设置
          settings = NavigationSettings.defaultSettings();
        }
      } else {
        // 没有存储的设置，使用默认设置
        settings = NavigationSettings.defaultSettings();
      }

      // 检查并确保至少有两个导航项启用
      if (settings.getEnabledCount() < 2) {
        // 按照顺序尝试启用导航项
        final updatedElements = <NavigationElement>[];
        int enabledCount = settings.getEnabledCount();

        for (final element in settings.elements) {
          if (element.type == NavigationElementType.item &&
              element is NavigationItemElement) {
            final item = element.item;
            if (!item.isEnabled && item.isRemovable && enabledCount < 2) {
              updatedElements.add(
                NavigationItemElement(item: item.copyWith(isEnabled: true)),
              );
              enabledCount++;
            } else {
              updatedElements.add(element);
            }
          } else {
            updatedElements.add(element);
          }
        }

        settings = NavigationSettings(elements: updatedElements);
        await _saveToStorage(settings);
      }

      return settings;
    } catch (e) {
      // 加载失败时返回默认设置
      return NavigationSettings.defaultSettings();
    }
  }

  /// 保存设置到持久化存储
  Future<void> _saveToStorage(NavigationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 获取所有导航项元素
      final itemElements = settings.elements
          .where((element) => element.type == NavigationElementType.item)
          .cast<NavigationItemElement>()
          .toList();
      final items = itemElements.map((e) => e.item).toList();

      // 保存导航项配置
      final itemsJson = items
          .map((item) => _jsonToString(item.toJson()))
          .join(';');
      await prefs.setString('navigation_items', itemsJson);

      // 保存排序顺序
      final orderList = items.map((item) => item.id).join(',');
      await prefs.setString('navigation_order', orderList);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 解析JSON字符串
  Map<String, dynamic> _parseJsonString(String jsonString) {
    // 简单的JSON字符串解析
    final Map<String, dynamic> result = {};
    final cleanString = jsonString.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleanString.split(',');

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim().replaceAll('"', '');
        final value = parts[1].trim();

        if (value == 'true') {
          result[key] = true;
        } else if (value == 'false') {
          result[key] = false;
        } else if (value.startsWith('"') && value.endsWith('"')) {
          result[key] = value.replaceAll('"', '');
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  /// 将JSON对象转换为字符串
  String _jsonToString(Map<String, dynamic> json) {
    final pairs = json.entries
        .map((entry) => '"${entry.key}":${_valueToString(entry.value)}')
        .join(',');
    return '{$pairs}';
  }

  /// 将值转换为字符串
  String _valueToString(dynamic value) {
    if (value is String) {
      return '"$value"';
    }
    return value.toString();
  }

  /// 更新导航项启用状态
  Future<void> updateItemEnabled(
    String itemId,
    bool isEnabled,
    BuildContext context,
  ) async {
    // 查找要更新的导航项
    NavigationItem? item;
    for (final element in state.value!.elements) {
      if (element.type == NavigationElementType.item &&
          element is NavigationItemElement &&
          element.item.id == itemId) {
        item = element.item;
        break;
      }
    }

    if (item == null) {
      return;
    }

    // 如果是不可移除的导航项（如个人页面），强制保持启用状态
    if (!item.isRemovable) {
      final newState = state.value!.updateItemEnabled(itemId, true);
      state = AsyncData(newState);
      await _saveToStorage(newState);
      return;
    }

    // 检查如果禁用该项后，是否还有至少两个导航项启用
    if (!isEnabled) {
      final tempState = state.value!.updateItemEnabled(itemId, false);
      if (tempState.getEnabledCount() < 2) {
        // 至少需要两个导航项启用，显示提示并取消禁用操作
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('至少需要启用两个导航项'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // 更新导航项启用状态
    final newState = state.value!.updateItemEnabled(itemId, isEnabled);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新导航项排序
  Future<void> updateItemOrder(List<NavigationItem> newOrder) async {
    // 获取所有原始导航项元素
    final originalItemElements = state.value!.elements
        .where((element) => element.type == NavigationElementType.item)
        .cast<NavigationItemElement>()
        .toList();
    final originalItems = originalItemElements.map((e) => e.item).toList();

    final updatedOrder = List<NavigationItem>.from(newOrder);

    // 添加未在新排序中的导航项
    for (final item in originalItems) {
      if (!updatedOrder.any((updatedItem) => updatedItem.id == item.id)) {
        updatedOrder.add(item);
      }
    }

    final newState = state.value!.updateItemOrder(updatedOrder);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 重置配置
  Future<void> resetSettings() async {
    final newState = NavigationSettings.defaultSettings();
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }
}
