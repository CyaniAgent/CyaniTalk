// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Clip _$ClipFromJson(Map<String, dynamic> json) => _Clip(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastClippedAt: json['lastClippedAt'] == null
      ? null
      : DateTime.parse(json['lastClippedAt'] as String),
  userId: json['userId'] as String,
  user: MisskeyUser.fromJson(json['user'] as Map<String, dynamic>),
  name: json['name'] as String,
  description: json['description'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  favoritedCount: (json['favoritedCount'] as num?)?.toInt() ?? 0,
  notesCount: (json['notesCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClipToJson(_Clip instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastClippedAt': instance.lastClippedAt?.toIso8601String(),
  'userId': instance.userId,
  'user': instance.user,
  'name': instance.name,
  'description': instance.description,
  'isPublic': instance.isPublic,
  'favoritedCount': instance.favoritedCount,
  'notesCount': instance.notesCount,
};
