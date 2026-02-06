// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => _ChatRoom(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  name: json['name'] as String?,
  topic: json['topic'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  userIds:
      (json['userIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  userId: json['userId'] as String?,
  user: json['user'] == null
      ? null
      : MisskeyUser.fromJson(json['user'] as Map<String, dynamic>),
  type: json['type'] as String?,
  lastMessage: json['lastMessage'] == null
      ? null
      : MessagingMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  isMuted: json['isMuted'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$ChatRoomToJson(_ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'name': instance.name,
  'topic': instance.topic,
  'isPublic': instance.isPublic,
  'userIds': instance.userIds,
  'userId': instance.userId,
  'user': instance.user,
  'type': instance.type,
  'lastMessage': instance.lastMessage,
  'unreadCount': instance.unreadCount,
  'isMuted': instance.isMuted,
  'isPinned': instance.isPinned,
};
