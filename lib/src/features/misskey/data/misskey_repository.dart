import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/logger.dart';
import '../../auth/application/auth_service.dart';
import '../../../core/api/misskey_api.dart';
import '../domain/note.dart';
import '../domain/channel.dart';
import '../domain/drive_file.dart';
import '../domain/drive_folder.dart';
import '../domain/misskey_user.dart';

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

  Future<List<Channel>> getChannels({int limit = 20}) async {
    logger.info('MisskeyRepository: Getting channels, limit=$limit');
    try {
      final data = await api.getChannels(limit: limit);
      final channels = data.map((e) => Channel.fromJson(e)).toList();
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} channels',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting channels', e);
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
      final data = await api.uploadDriveFile(
        bytes,
        filename,
        folderId: folderId,
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
}

@riverpod
MisskeyRepository misskeyRepository(Ref ref) {
  logger.info('MisskeyRepository: Initializing repository');
  final accountAsync = ref.watch(selectedMisskeyAccountProvider);
  final account = accountAsync.asData?.value;

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
