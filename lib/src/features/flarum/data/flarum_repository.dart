import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '/src/core/api/flarum_api.dart';
import 'models/forum_info.dart';
import 'models/user.dart';
import 'models/discussion.dart';
import 'models/post.dart';
import 'models/flarum_notification.dart';

import 'flarum_repository_interface.dart';

/// Flarum仓库类
///
/// 负责与Flarum API进行交互，获取论坛信息、用户信息、讨论和通知等数据。
class FlarumRepository implements IFlarumRepository {
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
  @override
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
  @override
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
  @override
  Future<List<Discussion>> getDiscussions({int? limit, int? offset}) async {
    final response = await _api.getDiscussions(
      limit: limit,
      offset: offset,
      include: 'user,lastPostedUser,tags',
    );

    final List data = response['data'] ?? [];
    final List included = response['included'] ?? [];

    return await compute((List list) {
      return list
          .map((d) => Discussion.fromJson(d, included: included))
          .toList();
    }, data);
  }

  /// 获取讨论详情
  @override
  Future<Discussion> getDiscussionDetails(String id) async {
    final response = await _api.getDiscussionDetails(id);
    final data = response['data'];
    final List included = response['included'] ?? [];

    return Discussion.fromJson(data, included: included);
  }

  /// 获取帖子列表
  @override
  Future<List<Post>> getPosts(
    String discussionId, {
    int? limit,
    int? offset,
  }) async {
    final response = await _api.getPosts(
      discussionId,
      limit: limit,
      offset: offset,
    );

    final List data = response['data'] ?? [];
    final List included = response['included'] ?? [];

    return await compute((List list) {
      return list.map((p) => Post.fromJson(p, included: included)).toList();
    }, data);
  }

  /// 获取所有标签
  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    final response = await _api.getTags();
    final List data = response['data'] ?? [];
    return data.map((t) => Map<String, dynamic>.from(t as Map)).toList();
  }

  /// 搜索讨论
  @override
  Future<List<Discussion>> searchDiscussions(String query) async {
    final response = await _api.searchDiscussions(query);
    final List data = response['data'] ?? [];
    final List included = response['included'] ?? [];

    return await compute((List list) {
      return list
          .map((d) => Discussion.fromJson(d, included: included))
          .toList();
    }, data);
  }

  /// 获取通知列表
  ///
  /// 获取当前用户的通知列表，包含发送者和主题信息。
  ///
  /// @return 返回通知列表
  @override
  Future<List<FlarumNotification>> getNotifications() async {
    final response = await _api.get(
      '/api/notifications',
      queryParameters: {'include': 'fromUser,subject'},
    );

    final List data = response.data['data'] ?? [];
    return await compute((List list) {
      return list.map((n) => FlarumNotification.fromJson(n)).toList();
    }, data);
  }
}
