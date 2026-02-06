import 'package:freezed_annotation/freezed_annotation.dart';
import 'misskey_user.dart';
import 'drive_file.dart';
import 'chat_room.dart';

part 'messaging_message.freezed.dart';
part 'messaging_message.g.dart';

@freezed
abstract class MessagingMessage with _$MessagingMessage {
  const factory MessagingMessage({
    required String id,
    required DateTime createdAt,
    String? text,
    String? userId,
    MisskeyUser? user,
    String? recipientId,
    MisskeyUser? recipient,
    @Default(false) bool isRead,
    String? fileId,
    DriveFile? file,
    // Support for Chat API grouping and rooms
    Map<String, dynamic>? group, 
    String? roomId,
    ChatRoom? room,
  }) = _MessagingMessage;

  factory MessagingMessage.fromJson(Map<String, dynamic> json) =>
      _$MessagingMessageFromJson(_handleAliases(json));

  static Map<String, dynamic> _handleAliases(Map<String, dynamic> json) {
    final Map<String, dynamic> newJson = Map<String, dynamic>.from(json);
    // Handle aliases
    if (newJson['user'] == null && newJson['from'] != null) newJson['user'] = newJson['from'];
    if (newJson['userId'] == null && newJson['fromId'] != null) newJson['userId'] = newJson['fromId'];
    if (newJson['recipient'] == null && newJson['to'] != null) newJson['recipient'] = newJson['to'];
    if (newJson['recipientId'] == null && newJson['toId'] != null) newJson['recipientId'] = newJson['toId'];
    
    // Additional aliases that might be used by different Misskey versions/instances
    if (newJson['user'] == null && newJson['sender'] != null) newJson['user'] = newJson['sender'];
    if (newJson['userId'] == null && newJson['senderId'] != null) newJson['userId'] = newJson['senderId'];
    if (newJson['recipient'] == null && newJson['recipientUser'] != null) newJson['recipient'] = newJson['recipientUser'];
    if (newJson['recipientId'] == null && newJson['recipientId'] != null) newJson['recipientId'] = newJson['recipientId'];
    
    // Handle sender/recipient aliases (for cases where sender is the user and recipient is the other party)
    if (newJson['user'] == null && newJson['senderUser'] != null) newJson['user'] = newJson['senderUser'];
    if (newJson['userId'] == null && newJson['senderUserId'] != null) newJson['userId'] = newJson['senderUserId'];
    
    // Handle room data in group field
    if (newJson['group'] != null && newJson['room'] == null) {
      final group = newJson['group'];
      if (group is Map && group['room'] != null) {
         newJson['room'] = group['room'];
      }
    }
    return newJson;
  }
}

// Extension to provide a unified way to get the sender info
extension MessagingMessageX on MessagingMessage {
  String? get senderId => userId;
  MisskeyUser? get sender => user;
}
