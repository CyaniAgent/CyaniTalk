// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Channel _$ChannelFromJson(Map<String, dynamic> json) => _Channel(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastNotedAt: json['lastNotedAt'] == null
      ? null
      : DateTime.parse(json['lastNotedAt'] as String),
  name: json['name'] as String,
  description: json['description'] as String?,
  userId: json['userId'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  pinnedNoteIds:
      (json['pinnedNoteIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  color: json['color'] as String? ?? "",
  isArchived: json['isArchived'] as bool? ?? false,
  usersCount: (json['usersCount'] as num?)?.toInt() ?? 0,
  notesCount: (json['notesCount'] as num?)?.toInt() ?? 0,
  isSensitive: json['isSensitive'] as bool? ?? false,
  allowRenoteToExternal: json['allowRenoteToExternal'] as bool? ?? true,
  isFollowing: json['isFollowing'] as bool?,
  isFavorited: json['isFavorited'] as bool?,
);

Map<String, dynamic> _$ChannelToJson(_Channel instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastNotedAt': instance.lastNotedAt?.toIso8601String(),
  'name': instance.name,
  'description': instance.description,
  'userId': instance.userId,
  'bannerUrl': instance.bannerUrl,
  'pinnedNoteIds': instance.pinnedNoteIds,
  'color': instance.color,
  'isArchived': instance.isArchived,
  'usersCount': instance.usersCount,
  'notesCount': instance.notesCount,
  'isSensitive': instance.isSensitive,
  'allowRenoteToExternal': instance.allowRenoteToExternal,
  'isFollowing': instance.isFollowing,
  'isFavorited': instance.isFavorited,
};
