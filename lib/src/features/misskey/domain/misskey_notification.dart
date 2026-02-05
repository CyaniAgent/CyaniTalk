import 'package:freezed_annotation/freezed_annotation.dart';
import 'misskey_user.dart';
import 'note.dart';

part 'misskey_notification.freezed.dart';
part 'misskey_notification.g.dart';

@freezed
abstract class MisskeyNotification with _$MisskeyNotification {
  const factory MisskeyNotification({
    required String id,
    required DateTime createdAt,
    required String type,
    String? userId,
    MisskeyUser? user,
    String? noteId,
    Note? note,
    String? reaction,
    // For follow requests, etc.
    Map<String, dynamic>? body,
  }) = _MisskeyNotification;

  factory MisskeyNotification.fromJson(Map<String, dynamic> json) =>
      _$MisskeyNotificationFromJson(json);
}
