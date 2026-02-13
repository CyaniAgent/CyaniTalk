// Misskey时间线页面
//
// 该文件包含MisskeyTimelinePage组件，用于显示Misskey的不同类型时间线。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;
import 'package:cyanitalk/src/features/misskey/application/misskey_notifier.dart';
import 'package:cyanitalk/src/features/misskey/application/timeline_jump_provider.dart';
import 'package:cyanitalk/src/features/misskey/presentation/widgets/modern_note_card.dart';

/// Misskey时间线页面组件
///
/// 显示Misskey平台上的时间线内容，支持切换不同类型的时间线（首页、本地、社交、全球）。
class MisskeyTimelinePage extends ConsumerStatefulWidget {
  /// 创建一个新的MisskeyTimelinePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyTimelinePage({super.key});

  /// 创建MisskeyTimelinePage的状态管理对象
  @override
  ConsumerState<MisskeyTimelinePage> createState() =>
      _MisskeyTimelinePageState();
}

/// MisskeyTimelinePage的状态管理类
class _MisskeyTimelinePageState extends ConsumerState<MisskeyTimelinePage> {
  /// 当前选中的时间线类型集合
  Set<String> _selectedTimeline = {'Global'};

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  /// 存储每个笔记卡片的 GlobalKey，用于精确定位
  final Map<String, GlobalKey> _noteKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 避免重复触发加载更多
    if (_isLoadingMore) return;

    // 当滚动到距离底部300像素时触发加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  /// 滚动到指定索引的笔记
  ///
  /// 使用 GlobalKey 和 Scrollable.ensureVisible 方法，确保笔记完全可见
  ///
  /// @param index 要滚动到的笔记索引
  void _scrollToNoteIndex(int index) {
    // TODO: 滚动位置精度问题暂时放弃
    // 由于 ListView.builder 的动态高度特性，精确滚动位置计算存在挑战
    // 当前实现使用估算位置 + Scrollable.ensureVisible 的组合方案
    // 虽然能基本满足需求，但仍可能存在位置偏差
    // 后续考虑使用更复杂的方案，如：
    // 1. 实现基于 SliverList 的自定义列表，支持精确的 scrollToIndex
    // 2. 使用第三方库如 scroll_to_index 来处理动态高度列表的滚动

    final notes =
        ref.watch(misskeyTimelineProvider(_selectedTimeline.first)).value ?? [];
    if (notes.isEmpty || index >= notes.length) return;

    final targetNote = notes[index];
    final noteId = targetNote.id;

    // 确保目标笔记有对应的 GlobalKey
    if (!_noteKeys.containsKey(noteId)) {
      _noteKeys[noteId] = GlobalKey();
    }

    // 计算估算的滚动位置，确保目标笔记被构建
    const double estimatedHeightPerItem = 250.0;
    const double safetyMargin = 100.0;
    double estimatedPosition = index * estimatedHeightPerItem - safetyMargin;
    estimatedPosition = math.max(0, estimatedPosition);

    // 首先滚动到估算位置，确保目标笔记被构建
    _scrollController.jumpTo(estimatedPosition);

    // 等待几帧，确保目标笔记已经构建完成
    int frameCount = 0;
    void tryScrollToNote() {
      frameCount++;
      if (!mounted || frameCount > 10) return; // 最多尝试10帧

      final noteKey = _noteKeys[noteId];
      final context = noteKey?.currentContext;

      if (context != null) {
        // 使用 Scrollable.ensureVisible 方法，这是 Flutter 提供的标准方法
        // 可以确保一个 widget 完全可见
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // 目标笔记还没有构建，继续等待下一帧
        WidgetsBinding.instance.addPostFrameCallback((_) => tryScrollToNote());
      }
    }

    // 开始尝试滚动
    WidgetsBinding.instance.addPostFrameCallback((_) => tryScrollToNote());
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    try {
      await ref
          .read(misskeyTimelineProvider(_selectedTimeline.first).notifier)
          .loadMore();
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 构建时间线页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含分段按钮和时间线列表的Column组件
  @override
  Widget build(BuildContext context) {
    final timelineType = _selectedTimeline.first;
    final timelineAsync = ref.watch(misskeyTimelineProvider(timelineType));

    // 监听跳转信号
    ref.listen(timelineJumpProvider(timelineType), (previous, next) {
      if (next != null) {
        final notes = timelineAsync.value ?? [];
        final index = notes.indexWhere((n) => n.id == next);
        if (index != -1) {
          // 直接滚动到对应的索引位置
          // 使用 ListView 的 scrollToIndex 功能，通过索引精确定位
          // 为了确保准确性，使用一个合理的动画持续时间
          _scrollToNoteIndex(index);
          // 重置跳转信号
          ref.read(timelineJumpProvider(timelineType).notifier).state = null;
        }
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'Global',
                  label: Text('timeline_global'.tr()),
                  icon: const Icon(Icons.public),
                ),
                ButtonSegment<String>(
                  value: 'Local',
                  label: Text('timeline_local'.tr()),
                  icon: const Icon(Icons.location_city),
                ),
                ButtonSegment<String>(
                  value: 'Social',
                  label: Text('timeline_social'.tr()),
                  icon: const Icon(Icons.group_outlined),
                ),
              ],
              selected: _selectedTimeline,
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedTimeline = newSelection;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: timelineAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return _buildEmptyState(context);
              }
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(misskeyTimelineProvider(timelineType).notifier)
                    .refresh(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: notes.length + 1,
                  itemBuilder: (context, index) {
                    if (index < notes.length) {
                      final note = notes[index];
                      // 确保每个笔记都有对应的 GlobalKey
                      if (!_noteKeys.containsKey(note.id)) {
                        _noteKeys[note.id] = GlobalKey();
                      }
                      return RepaintBoundary(
                        child: ModernNoteCard(
                          key: _noteKeys[note.id], // 使用 GlobalKey 而不是 ValueKey
                          note: note,
                          timelineType: timelineType,
                        ),
                      );
                    } else {
                      return _buildLoadMoreIndicator();
                    }
                  },
                  cacheExtent: 3000, // 增加预加载范围，提前加载更多内容
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  addSemanticIndexes: true,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'common_loading_failed'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Error: $err', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref
                            .read(
                              misskeyTimelineProvider(timelineType).notifier,
                            )
                            .refresh(),
                        icon: const Icon(Icons.refresh),
                        label: Text('common_reload'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'timeline_no_notes_found'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'timeline_your_timeline_is_empty'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
