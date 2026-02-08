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

/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
@riverpod
class MisskeyTimelineNotifier extends _$MisskeyTimelineNotifier {
  /// 验证定时器，用于定期检测已删除的笔记
  Timer? _validationTimer;

  /// 初始化Misskey时间线
  ///
  /// 根据指定的时间线类型初始化时间线，订阅WebSocket实时更新，
  /// 并从REST API获取初始数据。
  ///
  /// @param type 时间线类型，如'local'、'global'、'social'等
  /// @return 返回时间线笔记列表
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

  /// 启动定期验证
  ///
  /// 启动定期验证定时器，每3秒检测一次已删除的笔记。
  ///
  /// @return 无返回值
  void _startPeriodicValidation() {
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _validateNotes();
    });
  }

  /// 验证笔记
  ///
  /// 验证时间线中的笔记是否存在，检测已删除的笔记。
  /// 只检查最近的10条笔记，避免过多的API调用。
  ///
  /// @return 无返回值
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

  /// 处理新笔记
  ///
  /// 处理从WebSocket接收到的新笔记，将其添加到时间线顶部。
  /// 会检查是否有重复笔记，避免重复添加。
  ///
  /// @param note 新收到的笔记
  /// @return 无返回值
  void _handleNewNote(Note note) {
    if (!ref.mounted) return;

    final currentNotes = state.value ?? [];

    // Avoid duplicates
    if (currentNotes.any((n) => n.id == note.id)) return;

    logger.debug('Misskey时间线收到实时笔记: ${note.id}');
    state = AsyncData([note, ...currentNotes]);
  }

  /// 处理笔记删除
  ///
  /// 处理笔记删除事件，从时间线中移除指定ID的笔记。
  ///
  /// @param noteId 要删除的笔记ID
  /// @return 无返回值
  void _handleDeleteNote(String noteId) {
    if (!ref.mounted) return;

    final currentNotes = state.value ?? [];
    if (!currentNotes.any((n) => n.id == noteId)) return;

    logger.debug('Misskey时间线删除笔记: $noteId');
    state = AsyncData(currentNotes.where((n) => n.id != noteId).toList());
  }

  /// 刷新时间线
  ///
  /// 重新从服务器获取时间线数据，替换当前的时间线内容。
  ///
  /// @return 无返回值
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

  /// 加载更多
  ///
  /// 加载时间线的更多内容，从当前时间线的最后一条笔记开始获取。
  ///
  /// @return 无返回值
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
      logger.debug('Misskey片段跳过加载更多: isLoading=${state.isLoading}, hasMore=$_hasMore');
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
@riverpod
class MisskeyClipNotesNotifier extends _$MisskeyClipNotesNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

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

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !_hasMore) return;

    final currentNotes = state.value ?? [];
    if (currentNotes.isEmpty) return;

    final lastId = currentNotes.last.id;
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final newNotes = await repository.getClipNotes(clipId: clipId, untilId: lastId);

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
  /// 初始化Misskey平台的在线用户数，并设置每30秒自动更新一次。
  ///
  /// @return 返回当前在线用户数
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
