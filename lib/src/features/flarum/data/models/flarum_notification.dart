import 'package:freezed_annotation/freezed_annotation.dart';

part 'flarum_notification.freezed.dart';

@freezed
abstract class FlarumNotification with _$FlarumNotification {
  const factory FlarumNotification({
    required String id,
    required String type,
    String? contentType,
    String? content,
    required bool isRead,
    required String createdAt,
    String? fromUserId,
    String? subjectId,
    String? subjectType,
  }) = _FlarumNotification;

  factory FlarumNotification.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? {};
    final rels = json['relationships'] ?? {};

    return FlarumNotification(
      id: json['id'] as String? ?? '',
      type: attrs['type'] as String? ?? 'unknown',
      contentType: attrs['contentType'] as String?,
      content: attrs['content'] as String?,
      isRead: attrs['isRead'] as bool? ?? false,
      createdAt: attrs['createdAt'] as String? ?? '',
      fromUserId: rels['fromUser']?['data']?['id'] as String?,
      subjectId: rels['subject']?['data']?['id'] as String?,
      subjectType: rels['subject']?['data']?['type'] as String?,
    );
  }
}
