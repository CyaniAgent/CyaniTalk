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
