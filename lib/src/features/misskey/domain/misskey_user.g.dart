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
  isAdmin: json['isAdmin'] as bool? ?? false,
  isModerator: json['isModerator'] as bool? ?? false,
  isBot: json['isBot'] as bool? ?? false,
  isCat: json['isCat'] as bool? ?? false,
);

Map<String, dynamic> _$MisskeyUserToJson(_MisskeyUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'host': instance.host,
      'avatarUrl': instance.avatarUrl,
      'isAdmin': instance.isAdmin,
      'isModerator': instance.isModerator,
      'isBot': instance.isBot,
      'isCat': instance.isCat,
    };
