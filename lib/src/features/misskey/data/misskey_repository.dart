import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/logger.dart';
import '../../auth/application/auth_service.dart';
import '../../../core/api/misskey_api.dart';
import '../domain/note.dart';
import '../domain/clip.dart';
import '../domain/channel.dart';
import '../domain/drive_file.dart';
import '../domain/drive_folder.dart';
import '../domain/misskey_user.dart';
import '../domain/messaging_message.dart';

part 'misskey_repository.g.dart';

class MisskeyRepository {
  final MisskeyApi api;

  MisskeyRepository(this.api);

  Future<MisskeyUser> getMe() async {
    logger.info('MisskeyRepository: Getting current user information');
    try {
      final data = await api.i();
      logger.debug('MisskeyRepository: Raw /api/i response: $data');
      final user = MisskeyUser.fromJson(data);
      logger.info(
        'MisskeyRepository: Successfully retrieved user info for ${user.username}',
      );
      return user;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting current user info', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDriveInfo() async {
    logger.info('MisskeyRepository: Getting drive information');
    try {
      return await api.getDriveInfo();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive info', e);
      rethrow;
    }
  }

  Future<List<Note>> getTimeline(
    String type, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting $type timeline, limit=$limit, untilId=$untilId',
    );
    try {
      final data = await api.getTimeline(type, limit: limit, untilId: untilId);
      final notes = data.map((e) => Note.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for $type timeline',
      );
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting $type timeline', e);
      rethrow;
    }
  }

  Future<List<Channel>> getFeaturedChannels() async {
    logger.info('MisskeyRepository: Getting featured channels');
    try {
      final data = await api.getFeaturedChannels();
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} featured channels',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting featured channels', e);
      rethrow;
    }
  }

  Future<List<Channel>> getFollowingChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting following channels');
    try {
      final data = await api.getFollowingChannels(limit: limit, untilId: untilId);
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting following channels', e);
      rethrow;
    }
  }

  Future<List<Channel>> getOwnedChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting owned channels');
    try {
      final data = await api.getOwnedChannels(limit: limit, untilId: untilId);
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting owned channels', e);
      rethrow;
    }
  }

  Future<List<Channel>> getFavoriteChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting favorite channels');
    try {
      final data = await api.getFavoriteChannels(limit: limit, untilId: untilId);
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting favorite channels', e);
      rethrow;
    }
  }

  Future<List<Channel>> searchChannels(
    String query, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Searching channels with query "$query", limit=$limit',
    );
    try {
      final data = await api.searchChannels(
        query,
        limit: limit,
        untilId: untilId,
      );
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} channels for search query',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error searching channels', e);
      rethrow;
    }
  }

  Future<Channel> showChannel(String channelId) async {
    logger.info('MisskeyRepository: Showing channel $channelId');
    try {
      final data = await api.showChannel(channelId);
      return Channel.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error showing channel $channelId', e);
      rethrow;
    }
  }

  Future<MisskeyUser> showUser(String userId) async {
    logger.info('MisskeyRepository: Showing user $userId');
    try {
      final data = await api.showUser(userId);
      return MisskeyUser.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error showing user $userId', e);
      rethrow;
    }
  }

  Future<List<Note>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting channel $channelId timeline, limit=$limit, untilId=$untilId',
    );
    try {
      final data = await api.getChannelTimeline(
        channelId,
        limit: limit,
        untilId: untilId,
      );
      final notes = data.map((e) => Note.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for channel $channelId timeline',
      );
      return notes;
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error getting channel $channelId timeline',
        e,
      );
      rethrow;
    }
  }

  Future<List<Clip>> getClips({int limit = 20, String? untilId}) async {
    logger.info('MisskeyRepository: Getting clips, limit=$limit');
    try {
      final data = await api.getClips(limit: limit, untilId: untilId);
      final clips = data.map((e) => Clip.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${clips.length} clips',
      );
      return clips;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting clips', e);
      rethrow;
    }
  }

  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    List<String>? fileIds,
    String? visibility,
    bool? localOnly,
    String? cw,
  }) async {
    logger.info('MisskeyRepository: Creating note');
    try {
      await api.createNote(
        text: text,
        replyId: replyId,
        renoteId: renoteId,
        fileIds: fileIds,
        visibility: visibility,
        localOnly: localOnly,
        cw: cw,
      );
      logger.info('MisskeyRepository: Successfully created note');
    } catch (e) {
      logger.error('MisskeyRepository: Error creating note', e);
      rethrow;
    }
  }

  Future<void> renote(String noteId) async {
    logger.info('MisskeyRepository: Renoting note $noteId');
    try {
      await api.createNote(renoteId: noteId);
      logger.info('MisskeyRepository: Successfully renoted note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error renoting note $noteId', e);
      rethrow;
    }
  }

  Future<void> reply(String noteId, String text) async {
    logger.info('MisskeyRepository: Replying to note $noteId');
    try {
      await api.createNote(replyId: noteId, text: text);
      logger.info('MisskeyRepository: Successfully replied to note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error replying to note $noteId', e);
      rethrow;
    }
  }

  Future<void> addReaction(String noteId, String reaction) async {
    logger.info(
      'MisskeyRepository: Adding reaction "$reaction" to note $noteId',
    );
    try {
      await api.createReaction(noteId, reaction);
      logger.info(
        'MisskeyRepository: Successfully added reaction "$reaction" to note $noteId',
      );
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error adding reaction to note $noteId',
        e,
      );
      rethrow;
    }
  }

  Future<void> removeReaction(String noteId) async {
    logger.info('MisskeyRepository: Removing reaction from note $noteId');
    try {
      await api.deleteReaction(noteId);
      logger.info(
        'MisskeyRepository: Successfully removed reaction from note $noteId',
      );
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error removing reaction from note $noteId',
        e,
      );
      rethrow;
    }
  }

  Future<List<DriveFile>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting drive files, folderId=$folderId, limit=$limit',
    );
    try {
      final data = await api.getDriveFiles(
        folderId: folderId,
        limit: limit,
        untilId: untilId,
      );
      return data.map((e) => DriveFile.fromJson(e)).toList();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive files', e);
      rethrow;
    }
  }

  Future<List<DriveFolder>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting drive folders, folderId=$folderId, limit=$limit',
    );
    try {
      final data = await api.getDriveFolders(
        folderId: folderId,
        limit: limit,
        untilId: untilId,
      );
      return data.map((e) => DriveFolder.fromJson(e)).toList();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive folders', e);
      rethrow;
    }
  }

  Future<DriveFolder> createDriveFolder(String name, {String? parentId}) async {
    logger.info(
      'MisskeyRepository: Creating drive folder "$name", parentId=$parentId',
    );
    try {
      final data = await api.createDriveFolder(name, parentId: parentId);
      return DriveFolder.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error creating drive folder', e);
      rethrow;
    }
  }

  Future<String?> getOrCreateAppFolder() async {
    const folderName = 'CyaniTalk App Transfered';
    try {
      logger.info('MisskeyRepository: Looking for folder "$folderName"');
      final folders = await getDriveFolders();
      final appFolder = folders.where((f) => f.name == folderName).firstOrNull;

      if (appFolder != null) {
        logger.info('MisskeyRepository: Found existing folder: ${appFolder.id}');
        return appFolder.id;
      }

      logger.info('MisskeyRepository: Folder not found, creating it');
      final newFolder = await createDriveFolder(folderName);
      return newFolder.id;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting/creating app folder', e);
      return null; // Fallback to root on error
    }
  }

  Future<void> deleteDriveFile(String fileId) async {
    logger.info('MisskeyRepository: Deleting drive file $fileId');
    try {
      await api.deleteDriveFile(fileId);
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive file', e);
      rethrow;
    }
  }

  Future<void> deleteDriveFolder(String folderId) async {
    logger.info('MisskeyRepository: Deleting drive folder $folderId');
    try {
      await api.deleteDriveFolder(folderId);
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive folder', e);
      rethrow;
    }
  }

  Future<DriveFile> uploadDriveFile(
    List<int> bytes,
    String filename, {
    String? folderId,
  }) async {
    logger.info(
      'MisskeyRepository: Uploading drive file "$filename", folderId=$folderId',
    );
    try {
      // If no folderId is specified, we try to use the CyaniTalk App Transfered folder
      final targetFolderId = folderId ?? await getOrCreateAppFolder();

      final data = await api.uploadDriveFile(
        bytes,
        filename,
        folderId: targetFolderId,
      );
      return DriveFile.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error uploading drive file', e);
      rethrow;
    }
  }

  /// Check if a note still exists on the server
  Future<bool> checkNoteExists(String noteId) async {
    logger.debug('MisskeyRepository: Checking if note exists: $noteId');
    try {
      return await api.checkNoteExists(noteId);
    } catch (e) {
      logger.error('MisskeyRepository: Error checking note existence', e);
      return true; // Assume exists to avoid false deletions
    }
  }

  /// Get the number of online users
  Future<int> getOnlineUsersCount() async {
    logger.debug('MisskeyRepository: Getting online users count');
    try {
      return await api.getOnlineUsersCount();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting online users count', e);
      rethrow;
    }
  }

  // --- Messaging ---

  Future<List<MessagingMessage>> getMessagingHistory({int limit = 10}) async {
    logger.info('MisskeyRepository: Getting messaging history, limit=$limit');
    try {
      final data = await api.getMessagingHistory(limit: limit);
      logger.debug('MisskeyRepository: Raw messaging history data type: ${data.runtimeType}');
      if (data.isNotEmpty) {
         logger.debug('MisskeyRepository: First item in history: ${data.first}');
      }
      
      final messages = <MessagingMessage>[];
      for (final item in data) {
        try {
          var map = Map<String, dynamic>.from(item as Map);
          
          // Check for wrapped message (common in some history endpoints)
          if (map.containsKey('message') && map['message'] is Map) {
            final wrappedMessage = Map<String, dynamic>.from(map['message'] as Map);
            // We might want to preserve some root fields if needed, but usually the message has what we need
            map = wrappedMessage;
          }

          // Handle aliases manually
          if (map['user'] == null && map['from'] != null) map['user'] = map['from'];
          if (map['userId'] == null && map['fromId'] != null) map['userId'] = map['fromId'];
          
          messages.add(MessagingMessage.fromJson(map));
        } catch (e) {
          logger.error('MisskeyRepository: Error decoding message item: $item', e);
        }
      }
      
      logger.info('MisskeyRepository: Successfully retrieved ${messages.length} messages');
      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging history', e);
      rethrow;
    }
  }

  Future<List<MessagingMessage>> getMessagingMessages({
    required String userId,
    int limit = 10,
    String? sinceId,
    String? untilId,
    bool markAsRead = true,
  }) async {
    logger.info(
      'MisskeyRepository: Getting messaging messages for user $userId, limit=$limit',
    );
    try {
      final data = await api.getMessagingMessages(
        userId: userId,
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        markAsRead: markAsRead,
      );
      
      final messages = <MessagingMessage>[];
      for (final item in data) {
        try {
          var map = Map<String, dynamic>.from(item as Map);

          // Check for wrapped message
          if (map.containsKey('message') && map['message'] is Map) {
            map = Map<String, dynamic>.from(map['message'] as Map);
          }

          // Handle aliases manually
          if (map['user'] == null && map['from'] != null) map['user'] = map['from'];
          if (map['userId'] == null && map['fromId'] != null) map['userId'] = map['fromId'];
          
          messages.add(MessagingMessage.fromJson(map));
        } catch (e) {
          logger.error('MisskeyRepository: Error decoding message item', e);
        }
      }
      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging messages', e);
      rethrow;
    }
  }

  Future<MessagingMessage> sendMessagingMessage({
    required String userId,
    String? text,
    String? fileId,
  }) async {
    logger.info('MisskeyRepository: Sending messaging message to user $userId');
    try {
      final data = await api.createMessagingMessage(
        userId: userId,
        text: text,
        fileId: fileId,
      );
      return MessagingMessage.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error sending messaging message', e);
      rethrow;
    }
  }

  Future<void> markMessagingMessageAsRead(String messageId) async {
    logger.info('MisskeyRepository: Marking messaging message $messageId as read');
    try {
      await api.readMessagingMessage(messageId);
    } catch (e) {
      logger.error('MisskeyRepository: Error marking message as read', e);
      rethrow;
    }
  }

  Future<void> deleteMessagingMessage(String messageId) async {
    logger.info('MisskeyRepository: Deleting messaging message $messageId');
    try {
      await api.deleteMessagingMessage(messageId);
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting message', e);
      rethrow;
    }
  }

  // --- Actions ---

  Future<void> bookmark(String noteId) async {
    logger.info('MisskeyRepository: Bookmarking note $noteId');
    try {
      // 1. Check if "Bookmarks" clip exists
      final clips = await getClips();
      String? clipId;
      
      for (final clip in clips) {
        if (clip.name == 'Bookmarks') {
          clipId = clip.id;
          break;
        }
      }

      // 2. If not, create it
      if (clipId == null) {
        logger.info('MisskeyRepository: "Bookmarks" clip not found, creating it');
        final newClip = await api.createClip('Bookmarks', description: 'Created by CyaniTalk');
        clipId = newClip['id'];
      }

      // 3. Add note to clip
      if (clipId != null) {
        await api.addNoteToClip(clipId, noteId);
        logger.info('MisskeyRepository: Successfully added note to clip $clipId');
      } else {
         throw Exception('Failed to get or create Bookmarks clip');
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error bookmarking note', e);
      rethrow;
    }
  }

  Future<void> report(String noteId, String userId, String reason) async {
    logger.info('MisskeyRepository: Reporting note $noteId by user $userId');
    try {
      final comment = 'Report for note $noteId: $reason';
      await api.reportUser(userId, comment);
      logger.info('MisskeyRepository: Successfully reported user/note');
    } catch (e) {
      logger.error('MisskeyRepository: Error reporting note', e);
      rethrow;
    }
  }
}

@riverpod
Future<MisskeyRepository> misskeyRepository(Ref ref) async {
  logger.info('MisskeyRepository: Initializing repository');
  final account = await ref.watch(selectedMisskeyAccountProvider.future);

  if (account == null) {
    logger.error('MisskeyRepository: No Misskey account selected');
    throw Exception('No Misskey account selected');
  }
  logger.info(
    'MisskeyRepository: Initializing for account: ${account.id} on ${account.host}',
  );
  final api = MisskeyApi(host: account.host, token: account.token);
  return MisskeyRepository(api);
}
