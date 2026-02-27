import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
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
import '../domain/misskey_notification.dart';
import '../domain/chat_room.dart';
import '../domain/announcement.dart';
import 'misskey_repository_interface.dart';

part 'misskey_repository.g.dart';

class MisskeyRepository implements IMisskeyRepository {
  final MisskeyApi api;

  MisskeyRepository(this.api);

  @override
  String get host => api.host;

  @override
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

  @override
  Future<Map<String, dynamic>> getDriveInfo() async {
    logger.info('MisskeyRepository: Getting drive information');
    try {
      return await api.getDriveInfo();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive info', e);
      rethrow;
    }
  }

  @override
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
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for $type timeline',
      );
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting $type timeline', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFeaturedChannels() async {
    logger.info('MisskeyRepository: Getting featured channels');
    try {
      final data = await api.getFeaturedChannels();
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} featured channels',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting featured channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFollowingChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting following channels');
    try {
      final data = await api.getFollowingChannels(
        limit: limit,
        untilId: untilId,
      );
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting following channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getOwnedChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting owned channels');
    try {
      final data = await api.getOwnedChannels(limit: limit, untilId: untilId);
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting owned channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFavoriteChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting favorite channels');
    try {
      final data = await api.getFavoriteChannels(
        limit: limit,
        untilId: untilId,
      );
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting favorite channels', e);
      rethrow;
    }
  }

  @override
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
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} channels for search query',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error searching channels', e);
      rethrow;
    }
  }

  @override
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

  @override
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

  @override
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
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
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

  @override
  Future<List<Clip>> getClips({int limit = 20, String? untilId}) async {
    logger.info('MisskeyRepository: Getting clips, limit=$limit');
    try {
      final data = await api.getClips(limit: limit, untilId: untilId);
      final clips = await compute((List<dynamic> list) {
        return list.map((e) => Clip.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${clips.length} clips',
      );
      return clips;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting clips', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> getClipNotes({
    required String clipId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting notes for clip $clipId');
    try {
      final data = await api.getClipNotes(
        clipId: clipId,
        limit: limit,
        untilId: untilId,
      );
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for clip $clipId',
      );
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting clip notes', e);
      rethrow;
    }
  }

  @override
  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    String? channelId,
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
        channelId: channelId,
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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
      return await compute((List<dynamic> list) {
        return list.map((e) => DriveFile.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive files', e);
      rethrow;
    }
  }

  @override
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
      return await compute((List<dynamic> list) {
        return list.map((e) => DriveFolder.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive folders', e);
      rethrow;
    }
  }

  @override
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

  @override
  Future<String?> getOrCreateAppFolder() async {
    const folderName = 'CyaniTalk App Transfered';
    try {
      logger.info('MisskeyRepository: Looking for folder "$folderName"');
      final folders = await getDriveFolders();
      final appFolder = folders.where((f) => f.name == folderName).firstOrNull;

      if (appFolder != null) {
        logger.info(
          'MisskeyRepository: Found existing folder: ${appFolder.id}',
        );
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

  @override
  Future<void> deleteDriveFile(String fileId) async {
    logger.info('MisskeyRepository: Deleting drive file $fileId');
    try {
      await api.deleteDriveFile(fileId);
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive file', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteDriveFolder(String folderId) async {
    logger.info('MisskeyRepository: Deleting drive folder $folderId');
    try {
      await api.deleteDriveFolder(folderId);
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive folder', e);
      rethrow;
    }
  }

  @override
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

  @override
  Future<Map<String, dynamic>> getMeta() async {
    logger.debug('MisskeyRepository: Getting instance meta');
    try {
      return await api.getMeta();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting instance meta', e);
      rethrow;
    }
  }

  /// Check if a note still exists on the server
  @override
  Future<bool> checkNoteExists(String noteId) async {
    logger.debug('MisskeyRepository: Checking if note exists: $noteId');
    try {
      return await api.checkNoteExists(noteId);
    } catch (e) {
      logger.error('MisskeyRepository: Error checking note existence', e);
      return true; // Assume exists to avoid false deletions
    }
  }

  /// Get a single note by ID
  @override
  Future<Note> getNote(String noteId) async {
    logger.debug('MisskeyRepository: Getting note: $noteId');
    try {
      final data = await api.getNote(noteId);
      final note = await compute((Map<String, dynamic> json) {
        return Note.fromJson(json);
      }, data);
      logger.debug('MisskeyRepository: Successfully retrieved note: $noteId');
      return note;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting note: $noteId', e);
      // 抛出更友好的异常信息，而不是直接 rethrow
      throw Exception('Failed to get note: ${e.toString()}');
    }
  }

  /// Get the number of online users
  @override
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

  @override
  Future<List<MessagingMessage>> getMessagingHistory({int limit = 20}) async {
    logger.info('MisskeyRepository: Getting messaging history, limit=$limit');
    try {
      final data = await api.getMessagingHistory(limit: limit);

      final result = await compute(_parseMessagingHistory, data);
      final messages = result.messages;
      final missingUserIds = result.missingUserIds;

      // Fetch missing users
      if (missingUserIds.isNotEmpty) {
        logger.info(
          'MisskeyRepository: Fetching ${missingUserIds.length} missing users',
        );
        final users = <String, MisskeyUser>{};
        await Future.wait(
          missingUserIds.map((id) async {
            try {
              final user = await showUser(id);
              users[id] = user;
            } catch (e) {
              logger.error(
                'MisskeyRepository: Error fetching missing user $id',
                e,
              );
            }
          }),
        );

        // Update messages with fetched users
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          MisskeyUser? updatedUser = m.user ?? users[m.userId];
          MisskeyUser? updatedRecipient = m.recipient ?? users[m.recipientId];

          if (updatedUser != m.user || updatedRecipient != m.recipient) {
            messages[i] = m.copyWith(
              user: updatedUser,
              recipient: updatedRecipient,
            );
          }
        }
      }

      logger.info(
        'MisskeyRepository: Successfully retrieved ${messages.length} messages',
      );
      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging history', e);
      rethrow;
    }
  }

  @override
  Future<List<MessagingMessage>> getChatRoomMessages({
    required String roomId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting chat room messages for room $roomId',
    );
    try {
      final data = await api.getChatRoomMessages(roomId, limit: limit);
      return await compute((List<dynamic> list) {
        final messages = <MessagingMessage>[];
        for (final item in data) {
          try {
            var map = Map<String, dynamic>.from(item as Map);
            if (map['user'] == null && map['from'] != null) {
              map['user'] = map['from'];
            }
            if (map['userId'] == null && map['fromId'] != null) {
              map['userId'] = map['fromId'];
            }

            messages.add(MessagingMessage.fromJson(map));
          } catch (_) {}
        }
        return messages;
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting chat room messages', e);
      rethrow;
    }
  }

  @override
  Future<List<ChatRoom>> getJoinedChatRooms() async {
    logger.info('MisskeyRepository: Getting joined chat rooms');
    try {
      final data = await api.getChatRooms();
      return await compute((List<dynamic> list) {
        return list
            .map((e) => ChatRoom.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting chat rooms', e);
      rethrow;
    }
  }

  @override
  Future<void> sendChatRoomMessage({
    required String roomId,
    String? text,
    String? fileId,
  }) async {
    logger.info('MisskeyRepository: Sending chat room message to $roomId');
    try {
      await api.sendChatRoomMessage(roomId, text: text, fileId: fileId);
    } catch (e) {
      logger.error('MisskeyRepository: Error sending chat room message', e);
      rethrow;
    }
  }

  @override
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

      final result = await compute(_parseMessagingHistory, data);
      final messages = result.messages;
      final missingUserIds = result.missingUserIds;

      // Fetch missing users
      if (missingUserIds.isNotEmpty) {
        logger.info(
          'MisskeyRepository: Fetching ${missingUserIds.length} missing users for direct messages',
        );
        final users = <String, MisskeyUser>{};
        await Future.wait(
          missingUserIds.map((id) async {
            try {
              final user = await showUser(id);
              users[id] = user;
            } catch (e) {
              logger.error(
                'MisskeyRepository: Error fetching missing user $id for direct messages',
                e,
              );
            }
          }),
        );

        // Update messages with fetched users
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          MisskeyUser? updatedUser = m.user ?? users[m.userId];
          MisskeyUser? updatedRecipient = m.recipient ?? users[m.recipientId];

          if (updatedUser != m.user || updatedRecipient != m.recipient) {
            messages[i] = m.copyWith(
              user: updatedUser,
              recipient: updatedRecipient,
            );
          }
        }
      }

      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging messages', e);
      rethrow;
    }
  }

  @override
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

  @override
  Future<void> markMessagingMessageAsRead(String messageId) async {
    logger.info(
      'MisskeyRepository: Marking messaging message $messageId as read',
    );
    try {
      await api.readMessagingMessage(messageId);
    } catch (e) {
      logger.error('MisskeyRepository: Error marking message as read', e);
      rethrow;
    }
  }

  @override
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

  @override
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
        logger.info(
          'MisskeyRepository: "Bookmarks" clip not found, creating it',
        );
        final newClip = await api.createClip(
          'Bookmarks',
          description: 'Created by CyaniTalk',
        );
        clipId = newClip['id'];
      }

      // 3. Add note to clip
      if (clipId != null) {
        await api.addNoteToClip(clipId, noteId);
        logger.info(
          'MisskeyRepository: Successfully added note to clip $clipId',
        );
      } else {
        throw Exception('Failed to get or create Bookmarks clip');
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error bookmarking note', e);
      rethrow;
    }
  }

  @override
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

  @override
  Future<List<Note>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Searching notes for query: $query');
    try {
      final data = await api.searchNotes(query, limit: limit, untilId: untilId);
      return await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error searching notes', e);
      rethrow;
    }
  }

  @override
  Future<List<MisskeyUser>> searchUsers(
    String query, {
    int limit = 20,
    String? offset,
  }) async {
    logger.info('MisskeyRepository: Searching users for query: $query');
    try {
      final data = await api.searchUsers(query, limit: limit, offset: offset);
      return await compute((List<dynamic> list) {
        return list.map((e) => MisskeyUser.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error searching users', e);
      rethrow;
    }
  }

  // --- Announcements ---

  @override
  Future<List<Announcement>> getAnnouncements({
    int limit = 10,
    bool withUnreads = true,
    bool isActive = true,
  }) async {
    logger.info('MisskeyRepository: Getting announcements');
    try {
      final data = await api.getAnnouncements(
        limit: limit,
        withUnreads: withUnreads,
        isActive: isActive,
      );
      return await compute((List<dynamic> list) {
        return list.map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting announcements', e);
      rethrow;
    }
  }

  @override
  Future<void> readAnnouncement(String announcementId) async {
    logger.info('MisskeyRepository: Reading announcement: $announcementId');
    try {
      await api.readAnnouncement(announcementId);
      logger.info('MisskeyRepository: Successfully read announcement: $announcementId');
    } catch (e) {
      logger.error('MisskeyRepository: Error reading announcement', e);
      rethrow;
    }
  }

  // --- Notifications ---

  @override
  Future<List<MisskeyNotification>> getNotifications({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting notifications, limit=$limit');
    try {
      final data = await api.getNotifications(limit: limit, untilId: untilId);
      return await compute((List<dynamic> list) {
        return list
            .map(
              (e) => MisskeyNotification.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }, data);
    } catch (e, stack) {
      logger.error('MisskeyRepository: Error getting notifications', e, stack);
      rethrow;
    }
  }

  static _MessagingParsingResult _parseMessagingHistory(List<dynamic> data) {
    final messages = <MessagingMessage>[];
    final missingUserIds = <String>{};

    for (final item in data) {
      try {
        var map = Map<String, dynamic>.from(item as Map);

        if (map.containsKey('message') && map['message'] is Map) {
          final outer = map;
          map = Map<String, dynamic>.from(map['message'] as Map);

          if (map['user'] == null && outer['user'] != null) {
            map['user'] = outer['user'];
          }
          if (map['recipient'] == null && outer['recipient'] != null) {
            map['recipient'] = outer['recipient'];
          }
          if (map['userId'] == null && outer['userId'] != null) {
            map['userId'] = outer['userId'];
          }
          if (map['recipientId'] == null && outer['recipientId'] != null) {
            map['recipientId'] = outer['recipientId'];
          }
        }

        if (map['user'] == null && map['from'] != null) {
          map['user'] = map['from'];
        }
        if (map['userId'] == null && map['fromId'] != null) {
          map['userId'] = map['fromId'];
        }

        if (map['group'] != null && map['room'] == null) {
          final group = map['group'];
          if (group is Map && group['room'] != null) {
            map['room'] = group['room'];
          }
        }

        final message = MessagingMessage.fromJson(map);
        messages.add(message);

        if (message.userId != null && message.user == null) {
          missingUserIds.add(message.userId!);
        }
        if (message.recipientId != null && message.recipient == null) {
          missingUserIds.add(message.recipientId!);
        }
        if (map['userId'] != null && message.user == null) {
          missingUserIds.add(map['userId'] as String);
        }
        if (map['recipientId'] != null && message.recipient == null) {
          missingUserIds.add(map['recipientId'] as String);
        }
      } catch (_) {}
    }

    return _MessagingParsingResult(messages, missingUserIds.toList());
  }
}

class _MessagingParsingResult {
  final List<MessagingMessage> messages;
  final List<String> missingUserIds;

  _MessagingParsingResult(this.messages, this.missingUserIds);
}

@riverpod
Future<IMisskeyRepository> misskeyRepository(Ref ref) async {
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
