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
}

@riverpod
MisskeyRepository? misskeyRepository(Ref ref) {
  final accountsAsync = ref.watch(authServiceProvider);
  
  return accountsAsync.maybeWhen(
    data: (accounts) {
      final misskeyAccount = accounts.where(
        (acc) => acc.platform == 'misskey',
      ).firstOrNull;
      
      if (misskeyAccount == null) {
        return null;
      }
      
      final api = MisskeyApi(host: misskeyAccount.host, token: misskeyAccount.token);
      return MisskeyRepository(api);
    },
    orElse: () => null,
  );
}
