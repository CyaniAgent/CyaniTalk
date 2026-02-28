import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/clip.dart';
import '/src/features/misskey/domain/channel.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/misskey/domain/misskey_user.dart';
import '/src/features/misskey/domain/messaging_message.dart';
import '/src/features/misskey/domain/misskey_notification.dart';
import '/src/features/misskey/domain/chat_room.dart';
import '/src/features/misskey/domain/announcement.dart';
import '/src/features/misskey/domain/emoji.dart';

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

  /// 获取公告列表
  ///
  /// 获取当前用户需要查看的公告列表。
  ///
  /// @param limit 返回的公告数量限制，默认 10
  /// @param withUnreads 是否包含未读公告，默认 true
  /// @param isActive 是否只返回活跃的公告，默认 true
  /// @return 公告列表
  Future<List<Announcement>> getAnnouncements({
    int limit = 10,
    bool withUnreads = true,
    bool isActive = true,
  });

  /// 标记公告为已读
  ///
  /// 标记指定公告为已读状态。
  ///
  /// @param announcementId 要标记为已读的公告 ID
  Future<void> readAnnouncement(String announcementId);

  /// 获取表情列表
  Future<List<Emoji>> getEmojis();

  /// 获取单个表情详情
  Future<EmojiDetail> getEmoji(String name);

  /// 获取笔记的表情反应
  Future<List<dynamic>> getNoteReactions(
    String noteId, {
    String? type,
    int limit = 10,
    String? sinceId,
    String? untilId,
    int? sinceDate,
    int? untilDate,
  });
}
