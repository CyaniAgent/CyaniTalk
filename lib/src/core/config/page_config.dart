// 页面配置管理
//
// 该文件包含页面ID与路由的映射关系，提供统一的页面配置管理

/// 页面配置管理类
class PageConfig {
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

  /// 导航项ID列表（与navigation_settings.dart保持一致）
  static const List<String> navigationItemIds = [
    'misskey',
    'flarum',
    'drive',
    'messages',
    'me',
  ];

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

  /// 检查是否是有效的导航项ID
  ///
  /// @param itemId 导航项ID
  /// @return 是否是有效的导航项ID
  static bool isValidNavigationItem(String itemId) {
    return navigationItemIds.contains(itemId);
  }

  /// 获取所有导航项ID
  ///
  /// @return 导航项ID列表
  static List<String> getAllNavigationItemIds() {
    return navigationItemIds;
  }
}
