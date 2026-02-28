import 'package:flutter/material.dart';
import '/src/routing/router.dart';
import '/src/core/utils/logger.dart';
import '/src/core/config/page_config.dart';

/// 导航服务类
///
/// 提供通用的导航功能，包括通过页面ID直接跳转到对应页面的能力
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// 通过页面ID直接跳转到对应页面
  ///
  /// 根据页面ID跳转到对应的页面，支持带参数的页面
  ///
  /// @param pageId 页面ID，如 'home', 'misskey', 'settings' 等
  /// @param params 可选的页面参数，用于需要参数的页面
  /// @return 返回导航是否成功
  Future<bool> navigateByPageId(
    String pageId, {
    Map<String, dynamic>? params,
  }) async {
    logger.info('NavigationService: 尝试通过页面ID跳转: $pageId, 参数: $params');

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) {
      logger.error('NavigationService: 导航器未初始化');
      return false;
    }

    try {
      // 检查是否是带参数的页面
      if (pageId == 'user' && params != null && params.containsKey('id')) {
        // 跳转到用户资料页
        final userId = params['id'];
        await navigator.pushNamed('/misskey/user/$userId');
        logger.info('NavigationService: 成功跳转到用户资料页: $userId');
        return true;
      } else if (pageId == 'chat' &&
          params != null &&
          params.containsKey('id')) {
        // 跳转到私信页面
        final userId = params['id'];
        await navigator.pushNamed('/messaging/chat/$userId');
        logger.info('NavigationService: 成功跳转到私信页面: $userId');
        return true;
      } else if (pageId == 'room' &&
          params != null &&
          params.containsKey('id')) {
        // 跳转到群聊页面
        final roomId = params['id'];
        await navigator.pushNamed('/messaging/chat/room/$roomId');
        logger.info('NavigationService: 成功跳转到群聊页面: $roomId');
        return true;
      } else {
        // 跳转到普通页面
        final route = PageConfig.getRouteByPageId(pageId);
        if (route != null) {
          await navigator.pushNamed(route, arguments: params);
          logger.info('NavigationService: 成功跳转到页面: $pageId, 路由: $route');
          return true;
        } else {
          // 页面ID不存在，跳转到搜索页面
          await navigator.pushNamed('/search', arguments: {'query': pageId});
          logger.info('NavigationService: 页面ID不存在，跳转到搜索页面: $pageId');
          return true;
        }
      }
    } catch (e) {
      logger.error('NavigationService: 跳转失败: $e');
      return false;
    }
  }

  /// 通过ID直接跳转到对应页面
  ///
  /// 根据ID的格式和类型，自动判断并跳转到对应的页面
  ///
  /// @param id 要跳转的ID，可以是用户ID、房间ID、帖子ID等
  /// @param idType 可选的ID类型，用于更准确地判断跳转目标
  /// @return 返回导航是否成功
  Future<bool> navigateById(String id, {String? idType}) async {
    logger.info('NavigationService: 尝试通过ID跳转: $id, 类型: $idType');

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) {
      logger.error('NavigationService: 导航器未初始化');
      return false;
    }

    try {
      // 根据ID类型或格式判断跳转目标
      if (idType == 'user' ||
          id.startsWith('u_') ||
          id.length > 10 && !id.contains('-')) {
        // 跳转到用户资料页
        await navigator.pushNamed('/misskey/user/$id');
        logger.info('NavigationService: 成功跳转到用户资料页: $id');
        return true;
      } else if (idType == 'room' ||
          id.startsWith('room_') ||
          id.contains('-')) {
        // 跳转到群聊页面
        await navigator.pushNamed('/messaging/chat/room/$id');
        logger.info('NavigationService: 成功跳转到群聊页面: $id');
        return true;
      } else if (idType == 'message' || id.startsWith('msg_')) {
        // 跳转到私信页面
        await navigator.pushNamed('/messaging/chat/$id');
        logger.info('NavigationService: 成功跳转到私信页面: $id');
        return true;
      } else if (idType == 'notification') {
        // 跳转到通知页面
        await navigator.pushNamed('/misskey/notifications');
        logger.info('NavigationService: 成功跳转到通知页面');
        return true;
      } else if (idType == 'misskey' || id == 'home') {
        // 跳转到Misskey主页
        await navigator.pushNamed('/misskey');
        logger.info('NavigationService: 成功跳转到Misskey主页');
        return true;
      } else {
        // 默认跳转到搜索页面，搜索该ID
        await navigator.pushNamed('/search', arguments: {'query': id});
        logger.info('NavigationService: 成功跳转到搜索页面，搜索: $id');
        return true;
      }
    } catch (e) {
      logger.error('NavigationService: 跳转失败: $e');
      return false;
    }
  }

  /// 解析通知payload并跳转
  ///
  /// 解析通知的payload数据，并根据其中的信息跳转到对应页面
  ///
  /// @param payload 通知的payload数据
  /// @return 返回导航是否成功
  Future<bool> navigateFromPayload(String payload) async {
    logger.info('NavigationService: 尝试通过payload跳转: $payload');

    try {
      // 解析payload，支持JSON格式
      if (payload.contains('{') && payload.contains('}')) {
        // 简单的JSON解析
        if (payload.contains('"type":"user"') && payload.contains('"id":"')) {
          final id = payload.split('"id":"')[1].split('"')[0];
          return await navigateById(id, idType: 'user');
        } else if (payload.contains('"type":"room"') &&
            payload.contains('"id":"')) {
          final id = payload.split('"id":"')[1].split('"')[0];
          return await navigateById(id, idType: 'room');
        } else if (payload.contains('"type":"message"') &&
            payload.contains('"id":"')) {
          final id = payload.split('"id":"')[1].split('"')[0];
          return await navigateById(id, idType: 'message');
        } else if (payload.contains('"type":"notification"')) {
          return await navigateById('notifications', idType: 'notification');
        }
      }

      // 如果payload不是JSON格式，尝试直接作为ID处理
      return await navigateById(payload);
    } catch (e) {
      logger.error('NavigationService: 解析payload失败: $e');
      return false;
    }
  }

  /// 获取当前路由信息
  ///
  /// @return 返回当前路由的路径
  String? getCurrentRoute() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator != null) {
      final context = navigator.context;
      final route = ModalRoute.of(context)?.settings.name;
      logger.debug('NavigationService: 当前路由: $route');
      return route;
    }
    return null;
  }

  /// 返回到上一页
  ///
  /// @return 返回是否成功返回
  Future<bool> goBack() async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      logger.info('NavigationService: 成功返回上一页');
      return true;
    }
    logger.debug('NavigationService: 无法返回上一页');
    return false;
  }

  /// 跳转到指定路径
  ///
  /// @param path 要跳转的路径
  /// @param arguments 可选的参数
  /// @return 返回导航是否成功
  Future<bool> navigateTo(String path, {Object? arguments}) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) {
      logger.error('NavigationService: 导航器未初始化');
      return false;
    }

    try {
      await navigator.pushNamed(path, arguments: arguments);
      logger.info('NavigationService: 成功跳转到路径: $path');
      return true;
    } catch (e) {
      logger.error('NavigationService: 跳转失败: $e');
      return false;
    }
  }
}

/// 全局导航服务实例
final navigationService = NavigationService();
