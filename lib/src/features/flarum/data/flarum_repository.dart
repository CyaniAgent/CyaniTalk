import 'package:dio/dio.dart';
import '../../../core/api/flarum_api.dart';
import 'models/forum_info.dart';
import 'models/user.dart';
import 'models/discussion.dart';
import 'models/flarum_notification.dart';

/// Flarum仓库类
///
/// 负责与Flarum API进行交互，获取论坛信息、用户信息、讨论和通知等数据。
class FlarumRepository {
  /// Flarum API实例
  final FlarumApi _api;

  /// 创建Flarum仓库实例
  ///
  /// @param api Flarum API实例
  FlarumRepository(this._api);

  /// 获取论坛信息
  ///
  /// 获取Flarum论坛的基本信息，包括版本、设置等。
  ///
  /// @return 返回论坛信息
  Future<ForumInfo> getForumInfo() async {
    final response = await _api.get('/api');
    return ForumInfo.fromJson(response.data);
  }

  /// 获取当前用户信息
  ///
  /// 获取当前登录用户的详细信息，包括用户组。
  /// 如果未登录或用户不存在，返回null。
  ///
  /// @return 返回当前用户信息，如果未登录或不存在则返回null
  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get(
        '/api/user',
        queryParameters: {'include': 'groups'},
      );

      final data = response.data['data'];
      if (data == null) return null;

      final List included = response.data['included'] ?? [];

      return User.fromJson(data, included: included);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// 获取讨论列表
  ///
  /// 获取论坛的讨论列表，包含用户、最后发帖用户和标签信息。
  ///
  /// @return 返回讨论列表
  Future<List<Discussion>> getDiscussions() async {
    final response = await _api.get(
      '/api/discussions',
      queryParameters: {'include': 'user,lastPostedUser,tags'},
    );

    final List data = response.data['data'] ?? [];
    return data.map((d) => Discussion.fromJson(d)).toList();
  }

  /// 获取通知列表
  ///
  /// 获取当前用户的通知列表，包含发送者和主题信息。
  ///
  /// @return 返回通知列表
  Future<List<FlarumNotification>> getNotifications() async {
    final response = await _api.get(
      '/api/notifications',
      queryParameters: {'include': 'fromUser,subject'},
    );

    final List data = response.data['data'] ?? [];
    return data.map((n) => FlarumNotification.fromJson(n)).toList();
  }
}
