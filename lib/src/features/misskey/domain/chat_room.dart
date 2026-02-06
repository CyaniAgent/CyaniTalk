import 'package:freezed_annotation/freezed_annotation.dart';

import 'misskey_user.dart';
import 'messaging_message.dart';

part 'chat_room.freezed.dart';
part 'chat_room.g.dart';

@freezed
abstract class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required DateTime createdAt,
    String? name,
    String? topic,
    @Default(false) bool isPublic,
    @Default([]) List<String> userIds,
    String? userId,
    // For direct message rooms
    MisskeyUser? user,
    String? type, // 'room' or 'user'
    MessagingMessage? lastMessage,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isPinned,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}
