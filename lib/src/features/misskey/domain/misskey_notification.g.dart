// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MisskeyNotification _$MisskeyNotificationFromJson(Map<String, dynamic> json) =>
    _MisskeyNotification(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String,
      userId: json['userId'] as String?,
      user: json['user'] == null
          ? null
          : MisskeyUser.fromJson(json['user'] as Map<String, dynamic>),
      noteId: json['noteId'] as String?,
      note: json['note'] == null
          ? null
          : Note.fromJson(json['note'] as Map<String, dynamic>),
      reaction: json['reaction'] as String?,
      body: json['body'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MisskeyNotificationToJson(
  _MisskeyNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'type': instance.type,
  'userId': instance.userId,
  'user': instance.user,
  'noteId': instance.noteId,
  'note': instance.note,
  'reaction': instance.reaction,
  'body': instance.body,
};
