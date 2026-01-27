import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/misskey_repository.dart';
import '../domain/note.dart';
import '../domain/channel.dart';
import '../../../core/core.dart';

part 'misskey_notifier.g.dart';

@riverpod
class MisskeyTimelineNotifier extends _$MisskeyTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String type) async {
    logger.info('初始化Misskey时间线，类型: $type');
    final repository = ref.watch(misskeyRepositoryProvider);
    final notes = await repository.getTimeline(type);
    logger.info('Misskey时间线初始化完成，加载了 ${notes.length} 条笔记');
    return notes;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey时间线，类型: $type');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
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
      final repository = ref.read(misskeyRepositoryProvider);
      final newNotes = await repository.getTimeline(type, untilId: lastId);
      logger.info('Misskey时间线加载更多完成，新增 ${newNotes.length} 条笔记');
      return [...currentNotes, ...newNotes];
    });
  }
}

@riverpod
class MisskeyChannelsNotifier extends _$MisskeyChannelsNotifier {
  @override
  FutureOr<List<Channel>> build() async {
    logger.info('初始化Misskey频道列表');
    final repository = ref.watch(misskeyRepositoryProvider);
    final channels = await repository.getChannels();
    logger.info('Misskey频道列表初始化完成，加载了 ${channels.length} 个频道');
    return channels;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey频道列表');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
      final channels = await repository.getChannels();
      logger.info('Misskey频道列表刷新完成，加载了 ${channels.length} 个频道');
      return channels;
    });
  }
}

@riverpod
class MisskeyChannelTimelineNotifier extends _$MisskeyChannelTimelineNotifier {
  @override
  FutureOr<List<Note>> build(String channelId) async {
    logger.info('初始化Misskey频道时间线，频道ID: $channelId');
    final repository = ref.watch(misskeyRepositoryProvider);
    final notes = await repository.getChannelTimeline(channelId);
    logger.info('Misskey频道时间线初始化完成，加载了 ${notes.length} 条笔记');
    return notes;
  }

  Future<void> refresh() async {
    logger.info('刷新Misskey频道时间线，频道ID: $channelId');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(misskeyRepositoryProvider);
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
      final repository = ref.read(misskeyRepositoryProvider);
      final newNotes = await repository.getChannelTimeline(channelId, untilId: lastId);
      logger.info('Misskey频道时间线加载更多完成，新增 ${newNotes.length} 条笔记');
      return [...currentNotes, ...newNotes];
    });
  }
}