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

    /// 用户的阅读时间记录（每个用户的阅读时间）
    List<DateTime>? userIds,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}