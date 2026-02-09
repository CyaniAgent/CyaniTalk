import 'models/forum_info.dart';
import 'models/user.dart';
import 'models/discussion.dart';
import 'models/post.dart';
import 'models/flarum_notification.dart';

/// Flarum 仓库接口
///
/// 定义了与 Flarum 实例交互的核心方法。
abstract interface class IFlarumRepository {
  /// 获取论坛信息
  Future<ForumInfo> getForumInfo();

  /// 获取当前用户信息
  Future<User?> getCurrentUser();

  /// 获取讨论列表
  Future<List<Discussion>> getDiscussions({int? limit, int? offset});

  /// 获取讨论详情（包含所有帖子）
  Future<Discussion> getDiscussionDetails(String id);

  /// 获取讨论中的帖子列表
  Future<List<Post>> getPosts(String discussionId, {int? limit, int? offset});

  /// 获取所有标签
  Future<List<Map<String, dynamic>>> getTags();

  /// 搜索讨论
  Future<List<Discussion>> searchDiscussions(String query);

  /// 获取通知列表
  Future<List<FlarumNotification>> getNotifications();
}
