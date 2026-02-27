// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String?,
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      needConfirmationToRead: json['needConfirmationToRead'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      reads: json['reads'] == null
          ? null
          : DateTime.parse(json['reads'] as String),
      userIds: (json['userIds'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$AnnouncementToJson(_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'needConfirmationToRead': instance.needConfirmationToRead,
      'isRead': instance.isRead,
      'reads': instance.reads?.toIso8601String(),
      'userIds': instance.userIds?.map((e) => e.toIso8601String()).toList(),
    };
