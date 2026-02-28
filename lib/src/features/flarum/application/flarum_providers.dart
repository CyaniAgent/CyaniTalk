import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/core/api/flarum_api.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/features/flarum/data/flarum_repository.dart';
import '/src/features/flarum/data/models/forum_info.dart';
import '/src/features/flarum/data/models/user.dart';
import '/src/features/flarum/data/models/discussion.dart';
import '/src/features/flarum/data/models/flarum_notification.dart';

part 'flarum_providers.g.dart';

@Riverpod(keepAlive: true)
FlarumApi flarumApi(Ref ref) {
  return FlarumApi();
}

@riverpod
Future<List<String>> flarumEndpoints(Ref ref) async {
  final api = ref.watch(flarumApiProvider);
  return await api.getEndpoints();
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
