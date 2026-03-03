import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// Misskey 公告模型
///
/// 表示来自 Misskey 实例的公告信息
@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    /// 公告 ID
    required String id,

    /// 公告创建时间
    required DateTime createdAt,

    /// 公告更新时间
    required DateTime updatedAt,

    /// 公告标题
    String? title,

    /// 公告文本内容（可能包含 MFM 格式）
    String? text,

    /// 公告图片 URL
    String? imageUrl,

    /// 是否需要显示"我已阅读"按钮
    @Default(false) bool needConfirmationToRead,

    /// 用户是否已阅读此公告
    @Default(false) bool isRead,

    /// 用户阅读此公告的时间
    DateTime? reads,

    /// 已阅读此公告的用户 ID 列表
    List<String>? userIds,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // 安全处理可能为 null 的字段
    final id = json['id'] as String? ?? '';
    final createdAtStr =
        json['createdAt'] as String? ?? DateTime.now().toIso8601String();
    final updatedAtStr =
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String();

    // 安全解析日期
    DateTime createdAt;
    DateTime updatedAt;
    try {
      createdAt = DateTime.parse(createdAtStr);
    } catch (_) {
      createdAt = DateTime.now();
    }
    try {
      updatedAt = DateTime.parse(updatedAtStr);
    } catch (_) {
      updatedAt = DateTime.now();
    }

    // 安全处理 reads 字段
    DateTime? reads;
    final readsStr = json['reads'] as String?;
    if (readsStr != null) {
      try {
        reads = DateTime.parse(readsStr);
      } catch (_) {
        reads = null;
      }
    }

    // 安全处理 userIds 字段
    List<String>? userIds;
    final userIdsList = json['userIds'] as List<dynamic>?;
    if (userIdsList != null) {
      userIds = userIdsList
          .map((e) => e as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Announcement(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      title: json['title'] as String?,
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      needConfirmationToRead: json['needConfirmationToRead'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      reads: reads,
      userIds: userIds,
    );
  }
}
