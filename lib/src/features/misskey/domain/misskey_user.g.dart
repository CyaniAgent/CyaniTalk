// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MisskeyUser _$MisskeyUserFromJson(Map<String, dynamic> json) => _MisskeyUser(
  id: json['id'] as String,
  name: json['name'] as String?,
  username: json['username'] as String,
  host: json['host'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  description: json['description'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  notesCount: (json['notesCount'] as num?)?.toInt(),
  followingCount: (json['followingCount'] as num?)?.toInt(),
  followersCount: (json['followersCount'] as num?)?.toInt(),
  badgeRoles:
      (json['badgeRoles'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  isAdmin: json['isAdmin'] as bool? ?? false,
  isModerator: json['isModerator'] as bool? ?? false,
  isBot: json['isBot'] as bool? ?? false,
  isCat: json['isCat'] as bool? ?? false,
  driveCapacityMb: (json['driveCapacityMb'] as num?)?.toInt(),
  driveUsage: (json['driveUsage'] as num?)?.toInt(),
);

Map<String, dynamic> _$MisskeyUserToJson(_MisskeyUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'host': instance.host,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'notesCount': instance.notesCount,
      'followingCount': instance.followingCount,
      'followersCount': instance.followersCount,
      'badgeRoles': instance.badgeRoles,
      'roles': instance.roles,
      'isAdmin': instance.isAdmin,
      'isModerator': instance.isModerator,
      'isBot': instance.isBot,
      'isCat': instance.isCat,
      'driveCapacityMb': instance.driveCapacityMb,
      'driveUsage': instance.driveUsage,
    };
