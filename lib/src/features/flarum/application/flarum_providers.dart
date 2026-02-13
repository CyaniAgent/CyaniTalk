import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/flarum_api.dart';
import '../../auth/application/auth_service.dart';
import '../data/flarum_repository.dart';
import '../data/models/forum_info.dart';
import '../data/models/user.dart';
import '../data/models/discussion.dart';
import '../data/models/flarum_notification.dart';

part 'flarum_providers.g.dart';

@Riverpod(keepAlive: true)
FlarumApi flarumApi(Ref ref) {
  return FlarumApi();
}

@Riverpod(keepAlive: true)
FlarumRepository flarumRepository(Ref ref) {
  final api = ref.watch(flarumApiProvider);

  // Watch for account changes and configure the API singleton
  final account = ref.watch(selectedFlarumAccountProvider).asData?.value;

  if (account != null) {
    api.setBaseUrl('https://${account.host}');
    // Extract userId from account.id (format: userId@host)
    final userId = account.id.split('@').first;
    api.setToken(account.token, userId: userId);
  } else {
    api.clearToken();
  }

  return FlarumRepository(api);
}

@riverpod
Future<ForumInfo> forumInfo(Ref ref) async {
  final repo = ref.watch(flarumRepositoryProvider);
  return repo.getForumInfo();
}

@riverpod
Future<User?> flarumCurrentUser(Ref ref) async {
  final repo = ref.watch(flarumRepositoryProvider);
  final api = ref.watch(flarumApiProvider);
  if (api.token == null) return null;
  try {
    return await repo.getCurrentUser();
  } catch (e) {
    return null;
  }
}

@riverpod
Future<List<Discussion>> discussions(Ref ref) async {
  final repo = ref.watch(flarumRepositoryProvider);
  return repo.getDiscussions();
}

@riverpod
Future<List<FlarumNotification>> flarumNotifications(Ref ref) async {
  final repo = ref.watch(flarumRepositoryProvider);
  return repo.getNotifications();
}
