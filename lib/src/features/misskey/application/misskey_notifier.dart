import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/note.dart';
import '../domain/clip.dart';
import '../domain/channel.dart';
import '../domain/misskey_user.dart';
import 'misskey_streaming_service.dart';
import 'note_cache_manager.dart';
import '../../../core/core.dart';

part 'misskey_notifier.g.dart';

/// 时间线验证状态管理
class TimelineValidationState {
  /// 上次验证时间
  final DateTime lastValidation;

  /// 验证中标记
  final bool isValidating;

  const TimelineValidationState({
    required this.lastValidation,
    this.isValidating = false,
  });

  TimelineValidationState copyWith({
    DateTime? lastValidation,
    bool? isValidating,
  }) {
    return TimelineValidationState(
      lastValidation: lastValidation ?? this.lastValidation,
      isValidating: isValidating ?? this.isValidating,
    );
  }
}

/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
/// 使用缓存管理器提高性能，支持后台比对和自动更新。
@riverpod
class MisskeyTimelineNotifier extends _$MisskeyTimelineNotifier {
  /// 缓存管理器
  static final NoteCacheManager _cacheManager = NoteCacheManager();

  /// 验证定时器，用于定期检测已删除的笔记
  Timer? _validationTimer;

  /// 获取缓存管理器实例
  static NoteCacheManager get cacheManager => _cacheManager;

  /// 初始化Misskey时间线
  @override
  FutureOr<List<Note>> build(String type) async {
    // 1. 立即获取所有依赖，避免在 async gap 之后调用 ref.watch
    final streamingService = ref.watch(misskeyStreamingServiceProvider.notifier);
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);

    try {
      logger.info('初始化Misskey时间线，类型: $type');

      // 初始化缓存管理器（从持久化存储加载缓存）
      await _cacheManager.initialize();
      if (!ref.mounted) return [];

      // Subscribe to this timeline via WebSocket
      streamingService.subscribeToTimeline(type);

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
        _cacheManager.stopValidationTimer();
      });

      // 优先从缓存加载
      final cachedNotes = _cacheManager.getAllNotes();
      if (cachedNotes.isNotEmpty) {
        logger.info('Misskey时间线: 从内存缓存加载了 ${cachedNotes.length} 条笔记');

        // 延迟获取最新数据，避免阻塞UI
        Future.delayed(const Duration(seconds: 2), () async {
          if (!ref.mounted) return;
          await _loadLatestData(type);
        });

        // Start periodic validation to detect deleted notes
        _startPeriodicValidation();

        logger.info('Misskey时间线初始化完成，从内存缓存加载了 ${cachedNotes.length} 条笔记');
        return cachedNotes;
      }

      // 尝试从持久化存储加载
      final persistentNotes = await _cacheManager.loadNotesFromPersistentStorage();
      if (!ref.mounted) return persistentNotes;

      if (persistentNotes.isNotEmpty) {
        logger.info('Misskey时间线: 从持久化存储加载了 ${persistentNotes.length} 条笔记');

        // 将持久化存储的笔记添加到内存缓存
        _cacheManager.putNotes(persistentNotes);

        // 延迟获取最新数据，避免阻塞UI
        Future.delayed(const Duration(seconds: 2), () async {
          if (!ref.mounted) return;
          await _loadLatestData(type);
        });

        // Start periodic validation to detect deleted notes
        _startPeriodicValidation();

        logger.info('Misskey时间线初始化完成，从持久化存储加载了 ${persistentNotes.length} 条笔记');
        return persistentNotes;
      }

      // 如果缓存为空，从服务器获取数据
      logger.info('Misskey时间线: 缓存为空，从服务器获取数据');
      final repository = await repositoryFuture;
      if (!ref.mounted) return [];

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return latestNotes;

      // 将最新笔记添加到缓存
      _cacheManager.putNotes(latestNotes);

      // Start periodic validation to detect deleted notes
      _startPeriodicValidation();

      logger.info('Misskey时间线初始化完成，加载了 ${latestNotes.length} 条笔记');
      return latestNotes;
    } catch (e, stack) {
      if (e.toString().contains('disposed')) return [];

      // 处理网络连接错误，不阻塞程序
      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('DioException')) {
        logger.warning('Misskey时间线: 网络连接错误，返回空列表: $e');
        return [];
      }

      // 其他错误返回错误状态
      logger.error('Misskey时间线: 初始化失败', e, stack);
      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
      return [];
    }
  }

  /// 加载最新数据并更新界面
  Future<void> _loadLatestData(String type) async {
    try {
      if (!ref.mounted) return;

      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return;

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return;

      // 直接替换缓存数据
      logger.info('Misskey时间线: 获取到 ${latestNotes.length} 条最新笔记，替换缓存');
      _cacheManager.putNotes(latestNotes);

      // 更新UI
      if (ref.mounted) {
        final currentNotes = state.value ?? [];
        final currentNoteIds = currentNotes.map((n) => n.id).toSet();
        final newNotesCount = latestNotes
            .where((n) => !currentNoteIds.contains(n.id))
            .length;

        if (newNotesCount > 0) {
          logger.info('Misskey时间线: 发现 $newNotesCount 条新笔记，更新UI');
          state = AsyncData(latestNotes);
        } else {
          final newNotes = _updateNotesInList(currentNotes, latestNotes);
          state = AsyncData(newNotes);
          logger.debug('Misskey时间线: 无新笔记，只更新变化的部分');
        }
      }

      _startPeriodicValidation();
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.error('Misskey时间线: 加载最新数据失败', e);
    }
  }

  /// 启动定期验证
  void _startPeriodicValidation() {
    _cacheManager.startValidationTimer((noteIds) async {
      await _validateCachedNotes(noteIds);
    });
  }

  /// 验证缓存的笔记
  Future<void> _validateCachedNotes(List<String> noteIds) async {
    try {
      if (!ref.mounted) return;

      final currentNotes = state.value ?? [];
      if (currentNotes.isEmpty) return;

      final notesToCheck = <String>[];
      for (final note in currentNotes.take(10)) {
        if (noteIds.contains(note.id)) {
          notesToCheck.add(note.id);
        }
      }

      if (notesToCheck.isEmpty) return;

      logger.debug('Misskey时间线: 开始验证 ${notesToCheck.length} 条笔记');

      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return;

      final updatedNotes = <Note>[];

      for (final noteId in notesToCheck) {
        if (!ref.mounted) break;

        try {
          final latestNote = await repository.getNote(noteId);
          if (!ref.mounted) break;

          final cachedNote = _cacheManager.getNote(noteId);
          if (cachedNote == null || _hasNoteChanged(cachedNote, latestNote)) {
            updatedNotes.add(latestNote);
          }
        } catch (e) {
          if (!ref.mounted) break;
          final errorStr = e.toString();
          if (errorStr.contains('404') ||
              errorStr.contains('400') ||
              errorStr.contains('Note not found')) {
            _handleDeleteNote(noteId);
          }
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (ref.mounted && updatedNotes.isNotEmpty) {
        for (final note in updatedNotes) {
          _cacheManager.putNote(note);
        }
        final newNotes = _updateNotesInList(currentNotes, updatedNotes);
        state = AsyncData(newNotes);
      }
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.error('Misskey时间线: 验证缓存失败', e);
    }
  }

  bool _hasNoteChanged(Note oldNote, Note newNote) {
    return oldNote.text != newNote.text ||
        oldNote.renoteCount != newNote.renoteCount ||
        oldNote.repliesCount != newNote.repliesCount ||
        oldNote.reactions != newNote.reactions ||
        oldNote.myReaction != newNote.myReaction;
  }

  List<Note> _updateNotesInList(List<Note> notes, List<Note> updatedNotes) {
    final noteMap = <String, Note>{};
    for (final note in notes) {
      noteMap[note.id] = note;
    }
    final result = <Note>[];
    for (final note in updatedNotes) {
      result.add(note);
      noteMap.remove(note.id);
    }
    for (final note in notes) {
      if (noteMap.containsKey(note.id)) {
        result.add(note);
        noteMap.remove(note.id);
      }
    }
    return result;
  }

  void _handleNewNote(Note note) {
    try {
      if (!ref.mounted) return;
      final currentNotes = state.value ?? [];
      if (currentNotes.any((n) => n.id == note.id)) return;

      state = AsyncData([note, ...currentNotes]);
      _cacheManager.putNote(note);
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.error('Misskey时间线: 处理新笔记失败', e);
    }
  }

  void _handleDeleteNote(String noteId) {
    try {
      if (!ref.mounted) return;
      final currentNotes = state.value ?? [];
      if (!currentNotes.any((n) => n.id == noteId)) return;

      state = AsyncData(currentNotes.where((n) => n.id != noteId).toList());
      _cacheManager.removeNote(noteId);
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.error('Misskey时间线: 处理删除笔记失败', e);
    }
  }

  Future<void> refresh() async {
    try {
      if (!ref.mounted) return;

      logger.info('刷新Misskey时间线，类型: $type');

      final cachedNotes = _cacheManager.getAllNotes();
      if (cachedNotes.isNotEmpty && ref.mounted) {
        state = AsyncData(cachedNotes);
      } else {
        state = const AsyncValue.loading();
      }

      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return;

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return;

      final currentNotes = state.value ?? [];
      if (_hasNotesChanged(currentNotes, latestNotes)) {
        _cacheManager.putNotes(latestNotes);
        if (ref.mounted) {
          state = AsyncData(latestNotes);
        }
      }
    } catch (e, stack) {
      if (e.toString().contains('disposed')) return;

      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('DioException')) {
        if (state.value != null && state.value!.isNotEmpty) return;
        if (ref.mounted) {
          state = AsyncError(e, stack);
        }
        return;
      }

      logger.error('Misskey时间线: 刷新失败', e, stack);
      if (ref.mounted) {
        state = AsyncError(e, stack);
      }
    }
  }

  bool _hasNotesChanged(List<Note> oldNotes, List<Note> newNotes) {
    if (oldNotes.length != newNotes.length) return true;
    final oldNoteIds = oldNotes.map((n) => n.id).toSet();
    final newNoteIds = newNotes.map((n) => n.id).toSet();
    return oldNoteIds != newNoteIds;
  }

  Future<void> loadMore() async {
    try {
      if (state.isLoading || state.isRefreshing || !ref.mounted) return;

      final currentNotes = state.value ?? [];
      if (currentNotes.isEmpty) return;

      final lastId = currentNotes.last.id;
      logger.info('加载更多Misskey时间线内容，类型: $type, 最后笔记ID: $lastId');

      final result = await AsyncValue.guard<List<Note>>(() async {
        if (!ref.mounted) return currentNotes;
        final repository = await ref.read(misskeyRepositoryProvider.future);
        if (!ref.mounted) return currentNotes;
        final newNotes = await repository.getTimeline(type, untilId: lastId);
        if (!ref.mounted) return currentNotes;
        _cacheManager.putNotes(newNotes);
        return [...currentNotes, ...newNotes];
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.error('Misskey时间线: 加载更多失败', e);
    }
  }
}

/// Misskey频道列表状态管理类
@riverpod
class MisskeyChannelsNotifier extends _$MisskeyChannelsNotifier {
  @override
  FutureOr<List<Channel>> build({
    MisskeyChannelListType type = MisskeyChannelListType.featured,
    String? query,
  }) async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    logger.info('初始化Misskey频道列表，类型: $type, 查询: $query');
    
    final repository = await repositoryFuture;
    if (!ref.mounted) return [];

    final channels = await switch (type) {
      MisskeyChannelListType.featured => repository.getFeaturedChannels(),
      MisskeyChannelListType.favorites => repository.getFavoriteChannels(),
      MisskeyChannelListType.following => repository.getFollowingChannels(),
      MisskeyChannelListType.managing => repository.getOwnedChannels(),
      MisskeyChannelListType.search => repository.searchChannels(query ?? ''),
    };

    return channels;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await switch (type) {
        MisskeyChannelListType.featured => repository.getFeaturedChannels(),
        MisskeyChannelListType.favorites => repository.getFavoriteChannels(),
        MisskeyChannelListType.following => repository.getFollowingChannels(),
        MisskeyChannelListType.managing => repository.getOwnedChannels(),
        MisskeyChannelListType.search => repository.searchChannels(query ?? ''),
      };
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !ref.mounted) return;

    final currentChannels = state.value ?? [];
    if (currentChannels.isEmpty || type == MisskeyChannelListType.featured) return;

    final lastId = currentChannels.last.id;
    final result = await AsyncValue.guard(() async {
      if (!ref.mounted) return currentChannels;
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return currentChannels;

      final newChannels = await switch (type) {
        MisskeyChannelListType.favorites => repository.getFavoriteChannels(untilId: lastId),
        MisskeyChannelListType.following => repository.getFollowingChannels(untilId: lastId),
        MisskeyChannelListType.managing => repository.getOwnedChannels(untilId: lastId),
        MisskeyChannelListType.search => repository.searchChannels(query ?? '', untilId: lastId),
        _ => Future.value(<Channel>[]),
      };

      return [...currentChannels, ...newChannels];
    });
    
    if (ref.mounted) {
      state = result;
    }
  }
}

/// Misskey频道时间线状态管理类
@riverpod
class MisskeyChannelTimelineNotifier extends _$MisskeyChannelTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String channelId) async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    final repository = await repositoryFuture;
    if (!ref.mounted) return [];
    return await repository.getChannelTimeline(channelId);
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getChannelTimeline(channelId);
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !ref.mounted) return;

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    final result = await AsyncValue.guard(() async {
      if (!ref.mounted) return currentNotes;
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return currentNotes;
      final newNotes = await repository.getChannelTimeline(channelId, untilId: lastId);
      return [...currentNotes, ...newNotes];
    });

    if (ref.mounted) {
      state = result;
    }
  }
}

/// Misskey片段(Clips)列表状态管理类
@riverpod
class MisskeyClipsNotifier extends _$MisskeyClipsNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<Clip>> build() async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    _hasMore = true;
    final repository = await repositoryFuture;
    if (!ref.mounted) return [];
    final clips = await repository.getClips();
    if (clips.length < 20) _hasMore = false;
    return clips;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final clips = await repository.getClips();
      if (clips.length < 20) _hasMore = false;
      return clips;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !_hasMore || !ref.mounted) return;

    final currentClips = state.value ?? [];
    if (currentClips.isEmpty) return;

    final lastId = currentClips.last.id;
    final result = await AsyncValue.guard(() async {
      if (!ref.mounted) return currentClips;
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return currentClips;
      final newClips = await repository.getClips(untilId: lastId);
      if (newClips.isEmpty || newClips.length < 20) _hasMore = false;
      return [...currentClips, ...newClips];
    });

    if (ref.mounted) {
      state = result;
    }
  }
}

/// Misskey片段笔记状态管理类
@riverpod
class MisskeyClipNotesNotifier extends _$MisskeyClipNotesNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<Note>> build(String clipId) async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    _hasMore = true;
    final repository = await repositoryFuture;
    if (!ref.mounted) return [];
    final notes = await repository.getClipNotes(clipId: clipId);
    if (notes.length < 20) _hasMore = false;
    return notes;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final notes = await repository.getClipNotes(clipId: clipId);
      if (notes.length < 20) _hasMore = false;
      return notes;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !_hasMore || !ref.mounted) return;

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    final result = await AsyncValue.guard(() async {
      if (!ref.mounted) return currentNotes;
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return currentNotes;
      final newNotes = await repository.getClipNotes(clipId: clipId, untilId: lastId);
      if (newNotes.isEmpty || newNotes.length < 20) _hasMore = false;
      return [...currentNotes, ...newNotes];
    });

    if (ref.mounted) {
      state = result;
    }
  }
}

/// Misskey在线用户数状态管理类
@riverpod
class MisskeyOnlineUsersNotifier extends _$MisskeyOnlineUsersNotifier {
  Timer? _timer;

  @override
  FutureOr<int> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (ref.mounted) await refresh();
    });

    ref.onDispose(() => _timer?.cancel());

    return await _fetchCount();
  }

  Future<int> _fetchCount() async {
    if (!ref.mounted) return 0;
    final repository = await ref.read(misskeyRepositoryProvider.future);
    return await repository.getOnlineUsersCount();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final result = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getOnlineUsersCount();
    });
    if (ref.mounted && result.hasValue) {
      state = result;
    }
  }
}

/// 当前Misskey用户状态管理类
@riverpod
class MisskeyMeNotifier extends _$MisskeyMeNotifier {
  @override
  FutureOr<MisskeyUser> build() async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    final repository = await repositoryFuture;
    if (!ref.mounted) throw Exception('disposed');
    return await repository.getMe();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getMe();
    });
  }
}

/// Misskey用户信息状态管理类
@riverpod
class MisskeyUserNotifier extends _$MisskeyUserNotifier {
  @override
  FutureOr<MisskeyUser> build(String userId) async {
    final repositoryFuture = ref.watch(misskeyRepositoryProvider.future);
    final repository = await repositoryFuture;
    if (!ref.mounted) throw Exception('disposed');
    return await repository.showUser(userId);
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) throw Exception('disposed');
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.showUser(userId);
    });
  }
}
