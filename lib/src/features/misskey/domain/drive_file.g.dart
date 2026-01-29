// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriveFile _$DriveFileFromJson(Map<String, dynamic> json) => _DriveFile(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  name: json['name'] as String,
  type: json['type'] as String,
  size: (json['size'] as num).toInt(),
  url: json['url'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  blurhash: json['blurhash'] as String?,
  isSensitive: json['isSensitive'] as bool? ?? false,
  folderId: json['folderId'] as String?,
);

Map<String, dynamic> _$DriveFileToJson(_DriveFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'blurhash': instance.blurhash,
      'isSensitive': instance.isSensitive,
      'folderId': instance.folderId,
    };
