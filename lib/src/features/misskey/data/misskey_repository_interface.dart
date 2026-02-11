import '../domain/note.dart';
import '../domain/clip.dart';
import '../domain/channel.dart';
import '../domain/drive_file.dart';
import '../domain/drive_folder.dart';
import '../domain/misskey_user.dart';
import '../domain/messaging_message.dart';
import '../domain/misskey_notification.dart';
import '../domain/chat_room.dart';

/// Misskey 仓库接口
///
/// 定义了与 Misskey 实例交互的所有核心方法。
abstract interface class IMisskeyRepository {
  String get host;
  Future<MisskeyUser> getMe();

  Future<Map<String, dynamic>> getDriveInfo();

  Future<List<Note>> getTimeline(
    String type, {
    int limit = 20,
    String? untilId,
  });

  Future<List<Channel>> getFeaturedChannels();

  Future<List<Channel>> getFollowingChannels({int limit = 20, String? untilId});

  Future<List<Channel>> getOwnedChannels({int limit = 20, String? untilId});

  Future<List<Channel>> getFavoriteChannels({int limit = 20, String? untilId});

  Future<List<Channel>> searchChannels(
    String query, {
    int limit = 20,
    String? untilId,
  });

  Future<Channel> showChannel(String channelId);

  Future<MisskeyUser> showUser(String userId);

  Future<List<Note>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  });

  Future<List<Clip>> getClips({int limit = 20, String? untilId});

  Future<List<Note>> getClipNotes({
    required String clipId,
    int limit = 20,
    String? untilId,
  });

  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    String? channelId,
    List<String>? fileIds,
    String? visibility,
    bool? localOnly,
    String? cw,
  });

  Future<void> renote(String noteId);

  Future<void> reply(String noteId, String text);

  Future<void> addReaction(String noteId, String reaction);

  Future<void> removeReaction(String noteId);

  Future<List<DriveFile>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  });

  Future<List<DriveFolder>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  });

  Future<DriveFolder> createDriveFolder(String name, {String? parentId});

  Future<String?> getOrCreateAppFolder();

  Future<void> deleteDriveFile(String fileId);

  Future<void> deleteDriveFolder(String folderId);

  Future<DriveFile> uploadDriveFile(
    List<int> bytes,
    String filename, {
    String? folderId,
  });

  Future<bool> checkNoteExists(String noteId);

  Future<Note> getNote(String noteId);

  Future<Map<String, dynamic>> getMeta();

  Future<int> getOnlineUsersCount();

  // Messaging
  Future<List<MessagingMessage>> getMessagingHistory({int limit = 20});

  Future<List<MessagingMessage>> getChatRoomMessages({
    required String roomId,
    int limit = 20,
    String? untilId,
  });

  Future<List<ChatRoom>> getJoinedChatRooms();

  Future<void> sendChatRoomMessage({
    required String roomId,
    String? text,
    String? fileId,
  });

  Future<List<MessagingMessage>> getMessagingMessages({
    required String userId,
    int limit = 10,
    String? sinceId,
    String? untilId,
    bool markAsRead = true,
  });

  Future<MessagingMessage> sendMessagingMessage({
    required String userId,
    String? text,
    String? fileId,
  });

  Future<void> markMessagingMessageAsRead(String messageId);

  Future<void> deleteMessagingMessage(String messageId);

  Future<void> bookmark(String noteId);

  Future<List<MisskeyNotification>> getNotifications({
    int limit = 20,
    String? untilId,
  });

  Future<void> report(String noteId, String userId, String reason);

  /// 搜索笔记
  Future<List<Note>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  });

  /// 搜索用户
  Future<List<MisskeyUser>> searchUsers(
    String query, {
    int limit = 20,
    String? offset,
  });
}
