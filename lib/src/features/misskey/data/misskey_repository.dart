import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/logger.dart';
import '../../auth/application/auth_service.dart';
import '../../../core/api/misskey_api.dart';
import '../domain/note.dart';
import '../domain/channel.dart';

part 'misskey_repository.g.dart';

class MisskeyRepository {
  final MisskeyApi api;

  MisskeyRepository(this.api);

  Future<List<Note>> getTimeline(String type, {int limit = 20, String? untilId}) async {
    logger.info('MisskeyRepository: Getting $type timeline, limit=$limit, untilId=$untilId');
    try {
      final data = await api.getTimeline(type, limit: limit, untilId: untilId);
      final notes = data.map((e) => Note.fromJson(e)).toList();
      logger.info('MisskeyRepository: Successfully retrieved ${notes.length} notes for $type timeline');
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
      logger.info('MisskeyRepository: Successfully retrieved ${channels.length} channels');
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting channels', e);
      rethrow;
    }
  }

  Future<List<Note>> getChannelTimeline(String channelId, {int limit = 20, String? untilId}) async {
    logger.info('MisskeyRepository: Getting channel $channelId timeline, limit=$limit, untilId=$untilId');
    try {
      final data = await api.getChannelTimeline(channelId, limit: limit, untilId: untilId);
      final notes = data.map((e) => Note.fromJson(e)).toList();
      logger.info('MisskeyRepository: Successfully retrieved ${notes.length} notes for channel $channelId timeline');
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting channel $channelId timeline', e);
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
    logger.info('MisskeyRepository: Adding reaction "$reaction" to note $noteId');
    try {
      await api.createReaction(noteId, reaction);
      logger.info('MisskeyRepository: Successfully added reaction "$reaction" to note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error adding reaction to note $noteId', e);
      rethrow;
    }
  }

  Future<void> removeReaction(String noteId) async {
    logger.info('MisskeyRepository: Removing reaction from note $noteId');
    try {
      await api.deleteReaction(noteId);
      logger.info('MisskeyRepository: Successfully removed reaction from note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error removing reaction from note $noteId', e);
      rethrow;
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
  logger.info('MisskeyRepository: Initializing for account: ${account.id} on ${account.host}');
  final api = MisskeyApi(host: account.host, token: account.token);
  return MisskeyRepository(api);
}