// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriveFolder _$DriveFolderFromJson(Map<String, dynamic> json) => _DriveFolder(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  name: json['name'] as String,
  parentId: json['parentId'] as String?,
);

Map<String, dynamic> _$DriveFolderToJson(_DriveFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'parentId': instance.parentId,
    };
