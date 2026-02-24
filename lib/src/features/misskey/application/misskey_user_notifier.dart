import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/misskey_user.dart';
import '../../../core/core.dart';

part 'misskey_user_notifier.g.dart';

@riverpod
class MisskeyUserNotifier extends _$MisskeyUserNotifier {
  @override
  FutureOr<MisskeyUser> build(String userId) async {
    // 1. 立即获取依赖
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);

    logger.info('MisskeyUserNotifier: Initializing for userId: $userId');
    try {
      final repository = await repositoryFuture;
      if (!ref.mounted) throw Exception('disposed');
      
      return await repository.showUser(userId);
    } catch (e, stack) {
      if (e.toString().contains('disposed')) return const MisskeyUser(id: '', username: '', host: ''); // Return dummy or handle accordingly

      logger.error(
        'MisskeyUserNotifier: Error fetching user $userId',
        e,
        stack,
      );
      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    try {
      if (!ref.mounted) return;

      state = const AsyncValue.loading();

      final result = await AsyncValue.guard<MisskeyUser>(() async {
        if (!ref.mounted) throw Exception('disposed');
        final repository = await ref.read(misskeyRepositoryProvider.future);
        return await repository.showUser(userId);
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }
}
