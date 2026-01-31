// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: json['id'] as String,
  platform: json['platform'] as String,
  host: json['host'] as String,
  username: json['username'] as String?,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  token: json['token'] as String,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'platform': instance.platform,
  'host': instance.host,
  'username': instance.username,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'token': instance.token,
};
