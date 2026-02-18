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
  ///
  /// 根据指定的时间线类型初始化时间线，订阅WebSocket实时更新。
  /// 优先从缓存加载笔记，同时在后台获取最新数据。
  ///
  /// @param type 时间线类型，如'local'、'global'、'social'等
  /// @return 返回时间线笔记列表
  @override
  FutureOr<List<Note>> build(String type) async {
    try {
      logger.info('初始化Misskey时间线，类型: $type');

      // 初始化缓存管理器（从持久化存储加载缓存）
      await _cacheManager.initialize();

      // Subscribe to this timeline via WebSocket
      final streamingService = ref.watch(
        misskeyStreamingServiceProvider.notifier,
      );
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
          await _loadLatestData(type, streamingService);
        });

        // Start periodic validation to detect deleted notes
        _startPeriodicValidation();

        logger.info('Misskey时间线初始化完成，从内存缓存加载了 ${cachedNotes.length} 条笔记');
        return cachedNotes;
      }

      // 尝试从持久化存储加载
      final persistentNotes = await _cacheManager
          .loadNotesFromPersistentStorage();
      if (persistentNotes.isNotEmpty) {
        logger.info('Misskey时间线: 从持久化存储加载了 ${persistentNotes.length} 条笔记');

        // 将持久化存储的笔记添加到内存缓存
        _cacheManager.putNotes(persistentNotes);

        // 延迟获取最新数据，避免阻塞UI
        Future.delayed(const Duration(seconds: 2), () async {
          if (!ref.mounted) return;
          await _loadLatestData(type, streamingService);
        });

        // Start periodic validation to detect deleted notes
        _startPeriodicValidation();

        logger.info('Misskey时间线初始化完成，从持久化存储加载了 ${persistentNotes.length} 条笔记');
        return persistentNotes;
      }

      // 如果缓存为空，从服务器获取数据
      logger.info('Misskey时间线: 缓存为空，从服务器获取数据');
      final repository = await ref.watch(misskeyRepositoryProvider.future);
      if (!ref.mounted) return [];

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return [];

      // 将最新笔记添加到缓存
      _cacheManager.putNotes(latestNotes);

      // Start periodic validation to detect deleted notes
      _startPeriodicValidation();

      logger.info('Misskey时间线初始化完成，加载了 ${latestNotes.length} 条笔记');
      return latestNotes;
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return [];
      }
      rethrow;
    }
  }

  /// 加载最新数据并更新界面
  ///
  /// 在后台获取最新数据，直接替换缓存，优先显示服务器返回的最新数据。
  ///
  /// @param type 时间线类型
  /// @param streamingService 流式服务实例
  /// @return 无返回值
  Future<void> _loadLatestData(String type, dynamic streamingService) async {
    try {
      if (!ref.mounted) return;

      final repository = await ref.watch(misskeyRepositoryProvider.future);
      if (!ref.mounted) return;

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return;

      // 直接替换缓存数据
      logger.info('Misskey时间线: 获取到 ${latestNotes.length} 条最新笔记，替换缓存');
      _cacheManager.putNotes(latestNotes);

      // 更新UI，使用服务器返回的最新数据，确保新笔记在最前面
      if (ref.mounted) {
        final currentNotes = state.value ?? [];
        // 检查是否有新笔记不在当前列表中
        final currentNoteIds = currentNotes.map((n) => n.id).toSet();
        final newNotesCount = latestNotes.where((n) => !currentNoteIds.contains(n.id)).length;
        
        if (newNotesCount > 0) {
          logger.info('Misskey时间线: 发现 $newNotesCount 条新笔记，更新UI');
          // 直接使用服务器返回的最新数据，确保新笔记在最前面
          state = AsyncData(latestNotes);
        } else {
          // 如果没有新笔记，只更新变化的部分
          final newNotes = _updateNotesInList(currentNotes, latestNotes);
          state = AsyncData(newNotes);
          logger.debug('Misskey时间线: 无新笔记，只更新变化的部分');
        }
      }

      // Start periodic validation to detect deleted notes
      _startPeriodicValidation();
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('Misskey时间线: 加载最新数据失败', e);
    }
  }

  /// 启动定期验证
  ///
  /// 启动定期验证定时器，使用缓存管理器的后台比对功能。
  /// 每60秒检测一次缓存的笔记是否有更新或被删除。
  ///
  /// @return 无返回值
  void _startPeriodicValidation() {
    _cacheManager.startValidationTimer((noteIds) async {
      await _validateCachedNotes(noteIds);
    });
  }

  /// 验证缓存的笔记
  ///
  /// 使用缓存管理器验证笔记，获取最新数据并比对。
  /// 只检查最近的10条笔记，避免过多的API调用。
  /// 如果数据有变化，静默更新界面。
  ///
  /// @param noteIds 需要验证的笔记ID列表
  /// @return 无返回值
  Future<void> _validateCachedNotes(List<String> noteIds) async {
    try {
      if (!ref.mounted) return;

      final currentNotes = state.value ?? [];
      if (currentNotes.isEmpty) return;

      // 只检查当前时间线中最近的10条笔记
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
      final deletedNoteIds = <String>[];

      for (final noteId in notesToCheck) {
        if (!ref.mounted) break;

        try {
          final latestNote = await repository.getNote(noteId);
          if (!ref.mounted) break;

          // 获取缓存的笔记
          final cachedNote = _cacheManager.getNote(noteId);
          if (cachedNote == null) {
            updatedNotes.add(latestNote);
            logger.debug('Misskey时间线: 笔记 $noteId 不在缓存中，添加');
            continue;
          }

          // 比较笔记是否有变化
          if (_hasNoteChanged(cachedNote, latestNote)) {
            updatedNotes.add(latestNote);
            logger.debug('Misskey时间线: 笔记 $noteId 有变化，更新');
          } else {
            logger.debug('Misskey时间线: 笔记 $noteId 无变化');
          }
        } catch (e) {
          if (!ref.mounted) break;
          final errorStr = e.toString();
          if (errorStr.contains('UnmountedRefException')) {
            break;
          }
          if (errorStr.contains('404') ||
              errorStr.contains('400') ||
              errorStr.contains('Note not found')) {
            // 404 means deleted, 400 often means the ID is invalid for this instance
            // or some other restriction. Note not found is our specific exception for deleted notes.
            // We treat it as something we should remove from UI.
            deletedNoteIds.add(noteId);
            logger.info('Misskey时间线: 检测到无法加载的笔记 ($noteId): $errorStr');
            _handleDeleteNote(noteId);
          } else {
            logger.error('Misskey时间线: 验证笔记失败: $noteId', e);
          }
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (ref.mounted && updatedNotes.isNotEmpty) {
        // 更新缓存
        for (final note in updatedNotes) {
          _cacheManager.putNote(note);
        }

        // 静默更新界面
        final newNotes = _updateNotesInList(currentNotes, updatedNotes);
        state = AsyncData(newNotes);
        logger.debug('Misskey时间线: 验证完成，更新了 ${updatedNotes.length} 条笔记');
      }
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }

  /// 检查单个笔记是否有变化
  ///
  /// 比较两个笔记，判断是否有变化。
  ///
  /// @param oldNote 旧的笔记
  /// @param newNote 新的笔记
  /// @return 如果有变化返回 true，否则返回 false
  bool _hasNoteChanged(Note oldNote, Note newNote) {
    // 比较关键字段
    return oldNote.text != newNote.text ||
        oldNote.renoteCount != newNote.renoteCount ||
        oldNote.repliesCount != newNote.repliesCount ||
        oldNote.reactions != newNote.reactions ||
        oldNote.myReaction != newNote.myReaction;
  }

  /// 在笔记列表中更新笔记
  ///
  /// 用新笔记替换列表中的旧笔记，保持updatedNotes的顺序。
  ///
  /// @param notes 原始笔记列表
  /// @param updatedNotes 需要更新的笔记列表
  /// @return 更新后的笔记列表
  List<Note> _updateNotesInList(List<Note> notes, List<Note> updatedNotes) {
    final noteMap = <String, Note>{};
    // 先添加原始笔记
    for (final note in notes) {
      noteMap[note.id] = note;
    }
    // 用新笔记更新，保持updatedNotes的顺序
    final result = <Note>[];
    // 先添加updatedNotes中的笔记
    for (final note in updatedNotes) {
      result.add(note);
      noteMap.remove(note.id);
    }
    // 再添加剩余的原始笔记
    for (final note in notes) {
      if (noteMap.containsKey(note.id)) {
        result.add(note);
        noteMap.remove(note.id);
      }
    }
    return result;
  }

  /// 处理新笔记
  ///
  /// 处理从WebSocket接收到的新笔记，将其添加到时间线顶部。
  /// 会检查是否有重复笔记，避免重复添加。
  /// 同时将笔记添加到缓存中。
  ///
  /// @param note 新收到的笔记
  /// @return 无返回值
  void _handleNewNote(Note note) {
    try {
      if (!ref.mounted) return;

      final currentNotes = state.value ?? [];

      // Avoid duplicates
      if (currentNotes.any((n) => n.id == note.id)) return;

      logger.debug('Misskey时间线收到实时笔记: ${note.id}');
      state = AsyncData([note, ...currentNotes]);

      // 将新笔记添加到缓存
      _cacheManager.putNote(note);
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }

  /// 处理笔记删除
  ///
  /// 处理笔记删除事件，从时间线中移除指定ID的笔记。
  /// 同时从缓存中移除该笔记。
  ///
  /// @param noteId 要删除的笔记ID
  /// @return 无返回值
  void _handleDeleteNote(String noteId) {
    try {
      if (!ref.mounted) return;

      final currentNotes = state.value ?? [];
      if (!currentNotes.any((n) => n.id == noteId)) return;

      logger.debug('Misskey时间线删除笔记: $noteId');
      state = AsyncData(currentNotes.where((n) => n.id != noteId).toList());

      // 从缓存中移除笔记
      _cacheManager.removeNote(noteId);
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }

  /// 刷新时间线
  ///
  /// 优先从缓存加载笔记，同时在后台获取最新数据。
  /// 如果数据有变化，静默更新界面。
  ///
  /// @return 无返回值
  Future<void> refresh() async {
    try {
      if (!ref.mounted) return;

      logger.info('刷新Misskey时间线，类型: $type');

      // 优先从缓存加载
      final cachedNotes = _cacheManager.getAllNotes();
      if (cachedNotes.isNotEmpty) {
        logger.info('Misskey时间线: 从缓存加载了 ${cachedNotes.length} 条笔记');
        if (ref.mounted) {
          state = AsyncData(cachedNotes);
        }
      } else {
        state = const AsyncValue.loading();
      }

      // 在后台获取最新数据
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (!ref.mounted) return;

      final latestNotes = await repository.getTimeline(type);
      if (!ref.mounted) return;

      // 检查数据是否有变化
      final currentNotes = state.value ?? [];
      final hasChanges = _hasNotesChanged(currentNotes, latestNotes);

      if (hasChanges) {
        logger.info('Misskey时间线: 检测到数据变化，更新缓存和界面');
        _cacheManager.putNotes(latestNotes);
        if (ref.mounted) {
          state = AsyncData(latestNotes);
        }
      } else {
        logger.debug('Misskey时间线: 数据无变化，保持当前状态');
      }
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }

  /// 检查笔记列表是否有变化
  ///
  /// 比较两个笔记列表，判断是否有新增、删除或更新的笔记。
  ///
  /// @param oldNotes 旧的笔记列表
  /// @param newNotes 新的笔记列表
  /// @return 如果有变化返回 true，否则返回 false
  bool _hasNotesChanged(List<Note> oldNotes, List<Note> newNotes) {
    if (oldNotes.length != newNotes.length) return true;

    final oldNoteIds = oldNotes.map((n) => n.id).toSet();
    final newNoteIds = newNotes.map((n) => n.id).toSet();

    return oldNoteIds != newNoteIds;
  }

  /// 加载更多
  ///
  /// 加载时间线的更多内容，从当前时间线的最后一条笔记开始获取。
  /// 同时将新加载的笔记添加到缓存中。
  ///
  /// @return 无返回值
  Future<void> loadMore() async {
    try {
      if (state.isLoading || state.isRefreshing || !ref.mounted) {
        logger.debug('Misskey时间线正在加载中或provider已被dispose，跳过加载更多');
        return;
      }

      final currentNotes = state.value ?? [];
      if (currentNotes.isEmpty) {
        logger.debug('Misskey时间线为空，跳过加载更多');
        return;
      }

      final lastId = currentNotes.last.id;
      logger.info('加载更多Misskey时间线内容，类型: $type, 最后笔记ID: $lastId');

      final result = await AsyncValue.guard<List<Note>>(() async {
        try {
          if (!ref.mounted) return currentNotes;

          final repository = await ref.read(misskeyRepositoryProvider.future);
          if (!ref.mounted) return currentNotes;

          final newNotes = await repository.getTimeline(type, untilId: lastId);
          if (!ref.mounted) return currentNotes;

          // 将新笔记添加到缓存
          _cacheManager.putNotes(newNotes);

          logger.info('Misskey时间线加载更多完成，新增 ${newNotes.length} 条笔记');
          return [...currentNotes, ...newNotes];
        } catch (e) {
          if (e.toString().contains('UnmountedRefException')) {
            return currentNotes;
          }
          rethrow;
        }
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('UnmountedRefException')) {
        return;
      }
      rethrow;
    }
  }
}

/// Misskey频道列表状态管理类
///
/// 负责管理Misskey平台的频道列表，支持不同类型的频道列表和搜索功能。
@riverpod
class MisskeyChannelsNotifier extends _$MisskeyChannelsNotifier {
  /// 初始化Misskey频道列表
  ///
  /// 根据指定的频道列表类型初始化频道列表，支持不同类型的频道和搜索功能。
  ///
  /// @param type 频道列表类型，默认为推荐频道
  /// @param query 搜索查询，仅在type为search时有效
  /// @return 返回频道列表
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

  /// 刷新频道列表
  ///
  /// 重新从服务器获取频道列表数据，替换当前的频道列表内容。
  ///
  /// @return 无返回值
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

  /// 加载更多频道
  ///
  /// 加载频道列表的更多内容，从当前列表的最后一个频道开始获取。
  /// 注意：推荐频道列表不支持分页。
  ///
  /// @return 无返回值
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
        MisskeyChannelListType.favorites => repository.getFavoriteChannels(
          untilId: lastId,
        ),
        MisskeyChannelListType.following => repository.getFollowingChannels(
          untilId: lastId,
        ),
        MisskeyChannelListType.managing => repository.getOwnedChannels(
          untilId: lastId,
        ),
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

/// Misskey频道时间线状态管理类
///
/// 负责管理Misskey平台的频道时间线，显示指定频道的笔记列表。
@riverpod
class MisskeyChannelTimelineNotifier extends _$MisskeyChannelTimelineNotifier {
  /// 初始化Misskey频道时间线
  ///
  /// 根据指定的频道ID初始化频道时间线，加载该频道的笔记列表。
  ///
  /// @param channelId 频道ID
  /// @return 返回频道时间线的笔记列表
  @override
  FutureOr<List<Note>> build(String channelId) async {
    logger.info('初始化Misskey频道时间线，频道ID: $channelId');
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final notes = await repository.getChannelTimeline(channelId);
    logger.info('Misskey频道时间线初始化完成，加载了 ${notes.length} 条笔记');
    return notes;
  }

  /// 刷新频道时间线
  ///
  /// 重新从服务器获取频道时间线数据，替换当前的时间线内容。
  ///
  /// @return 无返回值
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

  /// 加载更多频道时间线内容
  ///
  /// 加载频道时间线的更多内容，从当前时间线的最后一条笔记开始获取。
  ///
  /// @return 无返回值
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

/// Misskey片段(Clips)列表状态管理类
///
/// 负责管理Misskey平台的片段(Clips)列表，支持片段的刷新和加载更多功能。
@riverpod
class MisskeyClipsNotifier extends _$MisskeyClipsNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// 初始化Misskey片段列表
  @override
  FutureOr<List<Clip>> build() async {
    logger.info('初始化Misskey片段(Clips)列表');
    _hasMore = true;
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final clips = await repository.getClips();
    if (clips.length < 20) {
      _hasMore = false;
    }
    logger.info('Misskey片段列表初始化完成，加载了 ${clips.length} 个片段');
    return clips;
  }

  /// 刷新片段列表
  Future<void> refresh() async {
    logger.info('刷新Misskey片段列表');
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final clips = await repository.getClips();
      if (clips.length < 20) {
        _hasMore = false;
      }
      logger.info('Misskey片段列表刷新完成，加载了 ${clips.length} 个片段');
      return clips;
    });
  }

  /// 加载更多片段
  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !_hasMore) {
      logger.debug(
        'Misskey片段跳过加载更多: isLoading=${state.isLoading}, hasMore=$_hasMore',
      );
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

      if (newClips.isEmpty || newClips.length < 20) {
        _hasMore = false;
      }

      if (!ref.mounted) return currentClips;

      logger.info('Misskey片段加载更多完成，新增 ${newClips.length} 个片段');
      return [...currentClips, ...newClips];
    });
  }
}

/// Misskey片段笔记状态管理类
///
/// 负责管理Misskey平台的片段(Clips)中的笔记列表，支持片段笔记的刷新和加载更多功能。
@riverpod
class MisskeyClipNotesNotifier extends _$MisskeyClipNotesNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// 初始化Misskey片段笔记
  ///
  /// 初始化指定片段ID的笔记列表，加载该片段中的笔记。
  ///
  /// @param clipId 片段ID
  /// @return 返回片段笔记列表
  @override
  FutureOr<List<Note>> build(String clipId) async {
    logger.info('初始化Misskey片段笔记，片段ID: $clipId');
    _hasMore = true;
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    final notes = await repository.getClipNotes(clipId: clipId);
    if (notes.length < 20) {
      _hasMore = false;
    }
    return notes;
  }

  /// 刷新片段笔记列表
  ///
  /// 重新从服务器获取片段笔记数据，替换当前的笔记列表内容。
  ///
  /// @return 无返回值
  Future<void> refresh() async {
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final notes = await repository.getClipNotes(clipId: clipId);
      if (notes.length < 20) {
        _hasMore = false;
      }
      return notes;
    });
  }

  /// 加载更多片段笔记
  ///
  /// 加载片段笔记的更多内容，从当前列表的最后一条笔记开始获取。
  ///
  /// @return 无返回值
  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !_hasMore) return;

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newNotes = await repository.getClipNotes(
        clipId: clipId,
        untilId: lastId,
      );

      if (newNotes.isEmpty || newNotes.length < 20) {
        _hasMore = false;
      }

      if (!ref.mounted) return currentNotes;
      return [...currentNotes, ...newNotes];
    });
  }
}

/// Misskey在线用户数状态管理类
///
/// 负责管理Misskey平台的在线用户数，定期更新以保持数据最新。
@riverpod
class MisskeyOnlineUsersNotifier extends _$MisskeyOnlineUsersNotifier {
  /// 定时器，用于定期更新在线用户数
  Timer? _timer;

  /// 初始化Misskey在线用户数
  ///
  /// 初始化Misskey平台的在线用户数，并设置每10秒自动更新一次。
  ///
  /// @return 返回当前在线用户数
  @override
  FutureOr<int> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!ref.mounted) return;
      await refresh();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    // 首次加载
    return await _fetchCount();
  }

  /// 获取在线用户数
  Future<int> _fetchCount() async {
    final result = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getOnlineUsersCount();
    });

    if (result.hasError) {
      logger.warning('Misskey在线用户数: 加载失败', result.error);
      throw result.error!;
    }
    return result.value!;
  }

  /// 刷新在线用户数
  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getOnlineUsersCount();
    });
  }
}

/// 当前Misskey用户状态管理类
///
/// 负责管理当前登录的Misskey用户信息，支持用户信息的刷新功能。
@riverpod
class MisskeyMeNotifier extends _$MisskeyMeNotifier {
  /// 初始化当前Misskey用户信息
  ///
  /// 初始化当前登录的Misskey用户信息，加载用户的详细数据。
  ///
  /// @return 返回当前用户信息
  @override
  FutureOr<MisskeyUser> build() async {
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    return await repository.getMe();
  }

  /// 刷新当前用户信息
  ///
  /// 重新从服务器获取当前用户的最新信息，替换当前的用户数据。
  ///
  /// @return 无返回值
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.getMe();
    });
  }
}

/// Misskey用户信息状态管理类
///
/// 负责管理指定ID的Misskey用户信息，支持用户信息的刷新功能。
@riverpod
class MisskeyUserNotifier extends _$MisskeyUserNotifier {
  /// 初始化Misskey用户信息
  ///
  /// 初始化指定ID的Misskey用户信息，加载用户的详细数据。
  ///
  /// @param userId 用户ID
  /// @return 返回用户信息
  @override
  FutureOr<MisskeyUser> build(String userId) async {
    final repository = await ref.watch(misskeyRepositoryProvider.future);
    return await repository.showUser(userId);
  }

  /// 刷新用户信息
  ///
  /// 重新从服务器获取指定用户的最新信息，替换当前的用户数据。
  ///
  /// @return 无返回值
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      return await repository.showUser(userId);
    });
  }
}
