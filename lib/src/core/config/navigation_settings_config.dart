// 导航设置配置管理
//
// 该文件包含导航设置的默认配置，包括默认导航项、图标映射等
// 与 navigation_settings.dart 配合使用
import 'package:flutter/material.dart';

/// 导航设置配置类
class NavigationSettingsConfig {
  /// 默认导航项配置
  static const List<Map<String, dynamic>> defaultNavigationItems = [
    {
      'id': 'misskey',
      'titleKey': 'nav_misskey',
      'icon': Icons.public_outlined,
      'selectedIcon': Icons.public,
      'isEnabled': true,
      'isRemovable': true,
    },
    {
      'id': 'flarum',
      'titleKey': 'nav_flarum',
      'icon': Icons.forum_outlined,
      'selectedIcon': Icons.forum,
      'isEnabled': true,
      'isRemovable': true,
    },
    {
      'id': 'drive',
      'titleKey': 'nav_drive',
      'icon': Icons.cloud_queue_outlined,
      'selectedIcon': Icons.cloud_queue,
      'isEnabled': true,
      'isRemovable': true,
    },
    {
      'id': 'messages',
      'titleKey': 'nav_messages',
      'icon': Icons.chat_bubble_outline,
      'selectedIcon': Icons.chat_bubble,
      'isEnabled': true,
      'isRemovable': true,
    },
    {
      'id': 'me',
      'titleKey': 'nav_me',
      'icon': Icons.person_outline,
      'selectedIcon': Icons.person,
      'isEnabled': true,
      'isRemovable': false, // 个人页面不可移除
    },
  ];

  /// 导航项ID与图标的映射
  static const Map<String, IconData> navigationItemIcons = {
    'misskey': Icons.public_outlined,
    'flarum': Icons.forum_outlined,
    'drive': Icons.cloud_queue_outlined,
    'messages': Icons.chat_bubble_outline,
    'me': Icons.person_outline,
  };

  /// 导航项ID与选中图标的映射
  static const Map<String, IconData> navigationItemSelectedIcons = {
    'misskey': Icons.public,
    'flarum': Icons.forum,
    'drive': Icons.cloud_queue,
    'messages': Icons.chat_bubble,
    'me': Icons.person,
  };

  /// 导航项ID与标题键的映射
  static const Map<String, String> navigationItemTitleKeys = {
    'misskey': 'nav_misskey',
    'flarum': 'nav_flarum',
    'drive': 'nav_drive',
    'messages': 'nav_messages',
    'me': 'nav_me',
  };

  /// 获取导航项的图标
  /// 
  /// @param itemId 导航项ID
  /// @return 对应的图标
  static IconData getIconForItem(String itemId) {
    return navigationItemIcons[itemId] ?? Icons.star_outlined;
  }

  /// 获取导航项的选中图标
  /// 
  /// @param itemId 导航项ID
  /// @return 对应的选中图标
  static IconData getSelectedIconForItem(String itemId) {
    return navigationItemSelectedIcons[itemId] ?? Icons.star;
  }

  /// 获取导航项的标题键
  /// 
  /// @param itemId 导航项ID
  /// @return 对应的标题键
  static String getTitleKeyForItem(String itemId) {
    return navigationItemTitleKeys[itemId] ?? '';
  }

  /// 检查导航项是否可移除
  /// 
  /// @param itemId 导航项ID
  /// @return 是否可移除
  static bool isItemRemovable(String itemId) {
    return itemId != 'me'; // 个人页面不可移除
  }
}
