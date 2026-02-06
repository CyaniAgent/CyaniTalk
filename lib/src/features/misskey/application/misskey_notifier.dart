import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/note.dart';
import '../domain/clip.dart';
import '../domain/channel.dart';
import '../domain/misskey_user.dart';
import 'misskey_streaming_service.dart';
import '../../../core/core.dart';

part 'misskey_notifier.g.dart';

@riverpod
class MisskeyTimelineNotifier extends _$MisskeyTimelineNotifier {
  Timer? _validationTimer;

  @override
  FutureOr<List<Note>> build(String type) async {
    logger.info('初始化Misskey时间线，类型: $type');

    // Subscribe to this timeline via WebSocket
    final streamingService = ref.watch(
      misskeyStreamingServiceProvider.notifier,
    );
    streamingService.subscribeToTimeline(type);

    // Initial fetch from REST API
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final notes = await repository.getTimeline(type);

    // Listening to the note stream from the streaming service
    final subscription = streamingService.noteStream.listen((event) {
      if (event.isDelete) {
        _handleDeleteNote(event.noteId!);
      } else if (event.timelineType == type) {
        _handleNewNote(event.note!);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      _validationTimer?.cancel();
    });

    // Start periodic validation to detect deleted notes
    _startPeriodicValidation();

    logger.info('Misskey时间线初始化完成，加载了 ${notes.length} 条笔记');
    return notes;
  }

  void _startPeriodicValidation() {
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _validateNotes();
    });
  }

  Future<void> _validateNotes() async {
    if (!ref.mounted) return;

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    // Check the top 10 most recent notes
    final notesToCheck = currentNotes.take(10).toList();

    for (final note in notesToCheck) {
      if (!ref.mounted) return;

      try {
        final repository = await ref
            .read(misskeyRepositoryProvider.future);
        final exists = await repository.checkNoteExists(note.id);
        if (!exists && ref.mounted) {
          logger.info('Misskey时间线: 检测到已删除的笔记: ${note.id}');
          _handleDeleteNote(note.id);
        }
      } catch (e) {
        logger.error('Misskey时间线: 验证笔记失败: ${note.id}', e);
      }
    }
  }

  void _handleNewNote(Note note) {
    if (!ref.mounted) return;

    final currentNotes = state.value ?? [];

    // Avoid duplicates
    if (currentNotes.any((n) => n.id == note.id)) return;

    logger.debug('Misskey时间线收到实时笔记: ${note.id}');
    state = AsyncData([note, ...currentNotes]);
  }

  void _handleDeleteNote(String noteId) {
    if (!ref.mounted) return;

    final currentNotes = state.value ?? [];
    if (!currentNotes.any((n) => n.id == noteId)) return;

    logger.debug('Misskey时间线删除笔记: $noteId');
    state = AsyncData(currentNotes.where((n) => n.id != noteId).toList());
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey时间线，类型: $type');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final notes = await repository.getTimeline(type);
      logger.info('Misskey时间线刷新完成，加载了 ${notes.length} 条笔记');
      return notes;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) {
      logger.debug('Misskey时间线正在加载中，跳过加载更多');
      return;
    }

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) {
      logger.debug('Misskey时间线为空，跳过加载更多');
      return;
    }

    final lastId = currentNotes.last.id;
    logger.info('加载更多Misskey时间线内容，类型: $type, 最后笔记ID: $lastId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newNotes = await repository.getTimeline(type, untilId: lastId);

      if (!ref.mounted) return currentNotes;

      logger.info('Misskey时间线加载更多完成，新增 ${newNotes.length} 条笔记');
      return [...currentNotes, ...newNotes];
    });
  }
}

@riverpod
class MisskeyChannelsNotifier extends _$MisskeyChannelsNotifier {
  @override
  FutureOr<List<Channel>> build({
    MisskeyChannelListType type = MisskeyChannelListType.featured,
    String? query,
  }) async {
    logger.info('初始化Misskey频道列表，类型: $type, 查询: $query');
    final repository = await ref.watch(misskeyRepositoryProvider.future);

    final channels = await switch (type) {
      MisskeyChannelListType.featured => repository.getFeaturedChannels(),
      MisskeyChannelListType.favorites => repository.getFavoriteChannels(),
      MisskeyChannelListType.following => repository.getFollowingChannels(),
      MisskeyChannelListType.managing => repository.getOwnedChannels(),
      MisskeyChannelListType.search => repository.searchChannels(query ?? ''),
    };

    logger.info('Misskey频道列表初始化完成，加载了 ${channels.length} 个频道');
    return channels;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey频道列表，类型: $type');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final channels = await switch (type) {
        MisskeyChannelListType.featured => repository.getFeaturedChannels(),
        MisskeyChannelListType.favorites => repository.getFavoriteChannels(),
        MisskeyChannelListType.following => repository.getFollowingChannels(),
        MisskeyChannelListType.managing => repository.getOwnedChannels(),
        MisskeyChannelListType.search => repository.searchChannels(query ?? ''),
      };
      logger.info('Misskey频道列表刷新完成，加载了 ${channels.length} 个频道');
      return channels;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) {
      logger.debug('Misskey频道列表正在加载中，跳过加载更多');
      return;
    }

    final currentChannels = state.value ?? [];
    if (currentChannels.isEmpty) {
      logger.debug('Misskey频道列表为空，跳过加载更多');
      return;
    }

    // featured doesn't support pagination usually in the same way
    if (type == MisskeyChannelListType.featured) return;

    final lastId = currentChannels.last.id;
    logger.info('加载更多Misskey频道，类型: $type, 最后ID: $lastId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);

      final newChannels = await switch (type) {
        MisskeyChannelListType.favorites => repository.getFavoriteChannels(untilId: lastId),
        MisskeyChannelListType.following => repository.getFollowingChannels(untilId: lastId),
        MisskeyChannelListType.managing => repository.getOwnedChannels(untilId: lastId),
        MisskeyChannelListType.search => repository.searchChannels(
          query ?? '',
          untilId: lastId,
        ),
        _ => Future.value(<Channel>[]),
      };

      if (!ref.mounted) return currentChannels;

      logger.info('Misskey频道列表加载更多完成，新增 ${newChannels.length} 个频道');
      return [...currentChannels, ...newChannels];
    });
  }
}

@riverpod
class MisskeyChannelTimelineNotifier extends _$MisskeyChannelTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String channelId) async {
    logger.info('初始化Misskey频道时间线，频道ID: $channelId');
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final notes = await repository.getChannelTimeline(channelId);
    logger.info('Misskey频道时间线初始化完成，加载了 ${notes.length} 条笔记');
    return notes;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey频道时间线，频道ID: $channelId');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final notes = await repository.getChannelTimeline(channelId);
      logger.info('Misskey频道时间线刷新完成，加载了 ${notes.length} 条笔记');
      return notes;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) {
      logger.debug('Misskey频道时间线正在加载中，跳过加载更多');
      return;
    }

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) {
      logger.debug('Misskey频道时间线为空，跳过加载更多');
      return;
    }

    final lastId = currentNotes.last.id;
    logger.info('加载更多Misskey频道时间线内容，频道ID: $channelId, 最后笔记ID: $lastId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newNotes = await repository.getChannelTimeline(
        channelId,
        untilId: lastId,
      );

      if (!ref.mounted) return currentNotes;

      logger.info('Misskey频道时间线加载更多完成，新增 ${newNotes.length} 条笔记');
      return [...currentNotes, ...newNotes];
    });
  }
}

@riverpod
class MisskeyClipsNotifier extends _$MisskeyClipsNotifier {
  @override
  FutureOr<List<Clip>> build() async {
    logger.info('初始化Misskey片段(Clips)列表');
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final clips = await repository.getClips();
    logger.info('Misskey片段列表初始化完成，加载了 ${clips.length} 个片段');
    return clips;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey片段列表');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final clips = await repository.getClips();
      logger.info('Misskey片段列表刷新完成，加载了 ${clips.length} 个片段');
      return clips;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing) {
      logger.debug('Misskey片段正在加载中，跳过加载更多');
      return;
    }

    final currentClips = state.value ?? [];
    if (currentClips.isEmpty) {
      logger.debug('Misskey片段为空，跳过加载更多');
      return;
    }

    final lastId = currentClips.last.id;
    logger.info('加载更多Misskey片段，最后ID: $lastId');

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newClips = await repository.getClips(untilId: lastId);

      if (!ref.mounted) return currentClips;

      logger.info('Misskey片段加载更多完成，新增 ${newClips.length} 个片段');
      return [...currentClips, ...newClips];
    });
  }
}

@riverpod
class MisskeyOnlineUsersNotifier extends _$MisskeyOnlineUsersNotifier {
  Timer? _timer;

  @override
  FutureOr<int> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!ref.mounted) return;
      state = await AsyncValue.guard(() async {
        final repository = await ref.read(misskeyRepositoryProvider.future);
        return await repository.getOnlineUsersCount();
      });
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    final repository = await ref.read(misskeyRepositoryProvider.future);
    return await repository.getOnlineUsersCount();
  }
}

@riverpod
class MisskeyMeNotifier extends _$MisskeyMeNotifier {
  @override
  FutureOr<MisskeyUser> build() async {
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    return await repository.getMe();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getMe();
    });
  }
}

@riverpod
class MisskeyUserNotifier extends _$MisskeyUserNotifier {
  @override
  FutureOr<MisskeyUser> build(String userId) async {
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    return await repository.showUser(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.showUser(userId);
    });
  }
}
