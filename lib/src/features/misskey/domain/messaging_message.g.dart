// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessagingMessage _$MessagingMessageFromJson(Map<String, dynamic> json) =>
    _MessagingMessage(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String?,
      userId: json['userId'] as String?,
      user: json['user'] == null
          ? null
          : MisskeyUser.fromJson(json['user'] as Map<String, dynamic>),
      recipientId: json['recipientId'] as String?,
      recipient: json['recipient'] == null
          ? null
          : MisskeyUser.fromJson(json['recipient'] as Map<String, dynamic>),
      isRead: json['isRead'] as bool? ?? false,
      fileId: json['fileId'] as String?,
      file: json['file'] == null
          ? null
          : DriveFile.fromJson(json['file'] as Map<String, dynamic>),
      group: json['group'] as Map<String, dynamic>?,
      roomId: json['roomId'] as String?,
    );

Map<String, dynamic> _$MessagingMessageToJson(_MessagingMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'userId': instance.userId,
      'user': instance.user,
      'recipientId': instance.recipientId,
      'recipient': instance.recipient,
      'isRead': instance.isRead,
      'fileId': instance.fileId,
      'file': instance.file,
      'group': instance.group,
      'roomId': instance.roomId,
    };
