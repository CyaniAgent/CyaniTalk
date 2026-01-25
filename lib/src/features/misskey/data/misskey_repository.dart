import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/application/auth_service.dart';
import '../../../core/api/misskey_api.dart';
import '../domain/note.dart';
import '../domain/channel.dart';

part 'misskey_repository.g.dart';

class MisskeyRepository {
  final MisskeyApi api;

  MisskeyRepository(this.api);

  Future<List<Note>> getTimeline(String type, {int limit = 20, String? untilId}) async {
    final data = await api.getTimeline(type, limit: limit, untilId: untilId);
    return data.map((e) => Note.fromJson(e)).toList();
  }

  Future<List<Channel>> getChannels({int limit = 20}) async {
    final data = await api.getChannels(limit: limit);
    return data.map((e) => Channel.fromJson(e)).toList();
  }

  Future<List<Note>> getChannelTimeline(String channelId, {int limit = 20, String? untilId}) async {
    final data = await api.getChannelTimeline(channelId, limit: limit, untilId: untilId);
    return data.map((e) => Note.fromJson(e)).toList();
  }

  Future<void> renote(String noteId) async {
    await api.createNote(renoteId: noteId);
  }

  Future<void> reply(String noteId, String text) async {
    await api.createNote(replyId: noteId, text: text);
  }

  Future<void> addReaction(String noteId, String reaction) async {
    await api.createReaction(noteId, reaction);
  }

  Future<void> removeReaction(String noteId) async {
    await api.deleteReaction(noteId);
  }
}

@riverpod
MisskeyRepository misskeyRepository(Ref ref) {
  final accountAsync = ref.watch(selectedMisskeyAccountProvider);
  final account = accountAsync.asData?.value;
  
  if (account == null) {
    throw Exception('No Misskey account selected');
  }
  final api = MisskeyApi(host: account.host, token: account.token);
  return MisskeyRepository(api);
}
