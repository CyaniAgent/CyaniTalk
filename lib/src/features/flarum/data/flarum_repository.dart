import 'package:dio/dio.dart';
import '../../../core/api/flarum_api.dart';
import 'models/forum_info.dart';
import 'models/user.dart';
import 'models/discussion.dart';
import 'models/flarum_notification.dart';

class FlarumRepository {
  final FlarumApi _api;

  FlarumRepository(this._api);

  Future<ForumInfo> getForumInfo() async {
    final response = await _api.get('/api');
    return ForumInfo.fromJson(response.data);
  }

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

  Future<List<Discussion>> getDiscussions() async {
    final response = await _api.get(
      '/api/discussions',
      queryParameters: {'include': 'user,lastPostedUser,tags'},
    );

    final List data = response.data['data'] ?? [];
    return data.map((d) => Discussion.fromJson(d)).toList();
  }

  Future<List<FlarumNotification>> getNotifications() async {
    final response = await _api.get(
      '/api/notifications',
      queryParameters: {'include': 'fromUser,subject'},
    );

    final List data = response.data['data'] ?? [];
    return data.map((n) => FlarumNotification.fromJson(n)).toList();
  }
}
