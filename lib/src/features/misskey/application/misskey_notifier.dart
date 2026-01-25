import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/note.dart';
import '../domain/channel.dart';

part 'misskey_notifier.g.dart';

@riverpod
class MisskeyTimelineNotifier extends _$MisskeyTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String type) async {
    final repository = ref.watch(misskeyRepositoryProvider);
    if (repository == null) {
      return [];
    }
    return repository.getTimeline(type);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      if (repository == null) {
        return [];
      }
      return repository.getTimeline(type);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) return;
    
    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      if (repository == null) {
        return currentNotes;
      }
      final newNotes = await repository.getTimeline(type, untilId: lastId);
      return [...currentNotes, ...newNotes];
    });
  }
}

@riverpod
class MisskeyChannelsNotifier extends _$MisskeyChannelsNotifier {
  @override
  FutureOr<List<Channel>> build() async {
    final repository = ref.watch(misskeyRepositoryProvider);
    if (repository == null) {
      return [];
    }
    return repository.getChannels();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      if (repository == null) {
        return [];
      }
      return repository.getChannels();
    });
  }
}

@riverpod
class MisskeyChannelTimelineNotifier extends _$MisskeyChannelTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String channelId) async {
    final repository = ref.watch(misskeyRepositoryProvider);
    if (repository == null) {
      return [];
    }
    return repository.getChannelTimeline(channelId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      if (repository == null) {
        return [];
      }
      return repository.getChannelTimeline(channelId);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) return;
    
    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      if (repository == null) {
        return currentNotes;
      }
      final newNotes = await repository.getChannelTimeline(channelId, untilId: lastId);
      return [...currentNotes, ...newNotes];
    });
  }
}
