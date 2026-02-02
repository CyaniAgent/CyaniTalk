import 'package:freezed_annotation/freezed_annotation.dart';
import 'misskey_user.dart';
import 'drive_file.dart';

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
  }) = _MessagingMessage;

  factory MessagingMessage.fromJson(Map<String, dynamic> json) =>
      _$MessagingMessageFromJson(json);
}

// Extension to provide a unified way to get the sender info
extension MessagingMessageX on MessagingMessage {
  String? get senderId => userId;
  MisskeyUser? get sender => user;
}
