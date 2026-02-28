// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userId: json['userId'] as String?,
  user: json['user'] == null
      ? null
      : MisskeyUser.fromJson(json['user'] as Map<String, dynamic>),
  text: json['text'] as String?,
  cw: json['cw'] as String?,
  fileIds:
      (json['fileIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  replyId: json['replyId'] as String?,
  renoteId: json['renoteId'] as String?,
  reply: json['reply'] == null
      ? null
      : Note.fromJson(json['reply'] as Map<String, dynamic>),
  renote: json['renote'] == null
      ? null
      : Note.fromJson(json['renote'] as Map<String, dynamic>),
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  renoteCount: (json['renoteCount'] as num?)?.toInt() ?? 0,
  repliesCount: (json['repliesCount'] as num?)?.toInt() ?? 0,
  visibility: json['visibility'] as String?,
  localOnly: json['localOnly'] as bool? ?? false,
  myReaction: json['myReaction'] as String?,
  emojis: (json['emojis'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': instance.userId,
  'user': instance.user,
  'text': instance.text,
  'cw': instance.cw,
  'fileIds': instance.fileIds,
  'files': instance.files,
  'replyId': instance.replyId,
  'renoteId': instance.renoteId,
  'reply': instance.reply,
  'renote': instance.renote,
  'reactions': instance.reactions,
  'renoteCount': instance.renoteCount,
  'repliesCount': instance.repliesCount,
  'visibility': instance.visibility,
  'localOnly': instance.localOnly,
  'myReaction': instance.myReaction,
  'emojis': instance.emojis,
};
