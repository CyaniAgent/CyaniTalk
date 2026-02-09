// 导航配置管理
//
// 该文件包含导航配置管理，统一管理导航项ID、页面ID和路由映射
import 'package:flutter/material.dart';

/// 导航配置管理类
class NavigationConfig {
  /// 导航项ID与分支索引的映射
  static const Map<String, int> navigationItemToBranchIndex = {
    'misskey': 0,
    'flarum': 1,
    'drive': 2,
    'messages': 3,
    'me': 4,
  };

  /// 页面ID与路由的映射关系
  static const Map<String, String> pageIdToRoute = {
    'home': '/misskey',
    'misskey': '/misskey',
    'flarum': '/forum',
    'drive': '/cloud',
    'messages': '/messaging',
    'me': '/profile',
    'profile': '/profile',
    'search': '/search',
    'settings': '/settings',
    'about': '/about',
    'notifications': '/misskey/notifications',
  };

  /// 带参数的页面ID
  static const List<String> parameterizedPageIds = ['user', 'chat', 'room'];

  /// 根据导航项ID获取分支索引
  ///
  /// @param itemId 导航项ID
  /// @return 对应的分支索引
  static int getBranchIndexForItem(String itemId) {
    return navigationItemToBranchIndex[itemId] ?? 0;
  }

  /// 根据页面ID获取路由路径
  ///
  /// @param pageId 页面ID
  /// @return 对应的路由路径
  static String? getRouteByPageId(String pageId) {
    return pageIdToRoute[pageId];
  }

  /// 检查页面ID是否需要参数
  ///
  /// @param pageId 页面ID
  /// @return 是否需要参数
  static bool isParameterizedPage(String pageId) {
    return parameterizedPageIds.contains(pageId);
  }

  /// 构建带参数的路由路径
  ///
  /// @param pageId 页面ID
  /// @param params 页面参数
  /// @return 构建的路由路径
  static String buildRouteWithParams(
    String pageId,
    Map<String, dynamic> params,
  ) {
    switch (pageId) {
      case 'user':
        if (params.containsKey('id')) {
          return '/misskey/user/${params['id']}';
        }
        break;
      case 'chat':
        if (params.containsKey('id')) {
          return '/messaging/chat/${params['id']}';
        }
        break;
      case 'room':
        if (params.containsKey('id')) {
          return '/messaging/chat/room/${params['id']}';
        }
        break;
    }
    return pageIdToRoute[pageId] ?? '/search';
  }

  /// 获取导航项的默认图标
  ///
  /// @param itemId 导航项ID
  /// @return 对应的图标
  static IconData getIconForItem(String itemId) {
    switch (itemId) {
      case 'misskey':
        return Icons.public_outlined;
      case 'flarum':
        return Icons.forum_outlined;
      case 'drive':
        return Icons.cloud_queue_outlined;
      case 'messages':
        return Icons.chat_bubble_outline;
      case 'me':
        return Icons.person_outlined;
      default:
        return Icons.star_outline;
    }
  }

  /// 获取导航项的选中图标
  ///
  /// @param itemId 导航项ID
  /// @return 对应的选中图标
  static IconData getSelectedIconForItem(String itemId) {
    switch (itemId) {
      case 'misskey':
        return Icons.public;
      case 'flarum':
        return Icons.forum;
      case 'drive':
        return Icons.cloud_queue;
      case 'messages':
        return Icons.chat_bubble;
      case 'me':
        return Icons.person;
      default:
        return Icons.star;
    }
  }
}
