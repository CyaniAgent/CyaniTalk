import 'package:flutter/foundation.dart';

class NavigationStateTracker extends ChangeNotifier {
  static final NavigationStateTracker instance =
      NavigationStateTracker._internal();
  factory NavigationStateTracker() => instance;
  NavigationStateTracker._internal();

  String _currentPath = '';

  String get currentPath => _currentPath;
  set currentPath(String value) {
    if (_currentPath != value) {
      _currentPath = value;
      notifyListeners();
    }
  }

  static const rootPaths = ['/misskey', '/cloud', '/messaging', '/profile'];

  String get currentPageName {
    final path = _currentPath;

    for (final rootPath in rootPaths) {
      if (path == rootPath ||
          path.startsWith('$rootPath/') ||
          path.startsWith('$rootPath?')) {
        return _pageNameFromRootPath(rootPath);
      }
    }

    return _pageNameFromRoute(path);
  }

  bool get isRootPage {
    final path = _currentPath;
    return rootPaths.contains(path);
  }

  String _pageNameFromRootPath(String rootPath) {
    switch (rootPath) {
      case '/misskey':
        return 'Misskey';
      case '/cloud':
        return '云盘';
      case '/messaging':
        return '消息';
      case '/profile':
        return '我';
      default:
        return 'CyaniTalk';
    }
  }

  String _pageNameFromRoute(String location) {
    if (location == '/search') return '搜索';
    if (location == '/settings' || location.startsWith('/settings/')) {
      return '设置';
    }
    if (location == '/about') return '关于';
    if (location == '/licenses') return '开源许可';
    if (location == '/developer') return '开发者';
    if (location == '/login') return '登录';
    if (location == '/misskey/notifications') return '通知';
    if (location.startsWith('/misskey/user/')) return '用户资料';
    if (location.startsWith('/messaging/chat/')) return '聊天';
    return 'CyaniTalk';
  }
}
