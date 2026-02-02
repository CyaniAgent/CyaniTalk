import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/misskey_user.dart';
import '../../../core/core.dart';

part 'misskey_user_notifier.g.dart';

@riverpod
class MisskeyUserNotifier extends _$MisskeyUserNotifier {
  @override
  FutureOr<MisskeyUser> build(String userId) async {
    logger.info('MisskeyUserNotifier: Initializing for userId: $userId');
    try {
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      return await repository.showUser(userId);
    } catch (e, stack) {
      logger.error('MisskeyUserNotifier: Error fetching user $userId', e, stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.showUser(userId);
    });
  }
}
