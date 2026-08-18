import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Nyachi/src/core/utils/logger.dart';
import 'package:Nyachi/src/features/misskey/application/misskey_notifier.dart';
import 'package:Nyachi/src/features/misskey/application/timeline_animation_state.dart';
import 'package:Nyachi/src/features/misskey/domain/note.dart';
import 'package:Nyachi/src/features/misskey/presentation/widgets/modern_note_card.dart';
import 'package:Nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:Nyachi/src/shared/widgets/error_state.dart';
import 'package:Nyachi/src/shared/widgets/empty_state.dart';

class MisskeyTimelinePage extends ConsumerStatefulWidget {
  const MisskeyTimelinePage({super.key, required this.timelineType});

  final String timelineType;

  @override
  ConsumerState<MisskeyTimelinePage> createState() =>
      _MisskeyTimelinePageState();
}

class _MisskeyTimelinePageState extends ConsumerState<MisskeyTimelinePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _upScrollCount = 0;
  DateTime? _lastUpScrollTime;
  double? _scrollTargetOffset;

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

  void _handleUpScrollRefresh() {
    final now = DateTime.now();
    if (_lastUpScrollTime == null ||
        now.difference(_lastUpScrollTime!) > const Duration(milliseconds: 300)) {
      _upScrollCount++;
      _lastUpScrollTime = now;
      logger.info('Timeline scroll-to-refresh count: $_upScrollCount/3');

      if (_upScrollCount >= 3) {
        _upScrollCount = 0;
        _lastUpScrollTime = null;
        ref.read(timelineAnimationProvider.notifier).reset();
        ref.read(misskeyTimelineProvider(widget.timelineType).notifier).refresh();
      }
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (!_scrollController.hasClients) return;

      final dy = event.scrollDelta.dy;
      if (dy == 0) return;

      final currentOffset = _scrollController.offset;

      // 如果在顶部，并且是往上滚，则执行"顶端往上滚动3次刷新"
      if (currentOffset <= 0 && dy < 0) {
        _handleUpScrollRefresh();
        return;
      }

      // 往下滚时，重置往上滚的计数
      if (dy > 0) {
        _upScrollCount = 0;
      }

      // 仅在 Windows 上开启平滑无缝滚动
      final isWindows = Theme.of(context).platform == TargetPlatform.windows;
      if (!isWindows) return;

      GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent resolvedEvent) {
        final maxExtent = _scrollController.position.maxScrollExtent;

        double baseOffset = _scrollTargetOffset ?? currentOffset;

        // 修正方向反转情况
        if ((dy < 0 && baseOffset > currentOffset) || (dy > 0 && baseOffset < currentOffset)) {
          baseOffset = currentOffset;
        }

        // 增加 1.5 倍滚动距离，使滚动平滑且跟手
        final target = (baseOffset + dy * 1.5).clamp(0.0, maxExtent);
        _scrollTargetOffset = target;

        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        ).then((_) {
          if (mounted && _scrollController.hasClients && _scrollController.offset == _scrollTargetOffset) {
            _scrollTargetOffset = null;
          }
        });
      });
    }
  }

  void _autoScrollToTop() {
    if (!_scrollController.hasClients || _scrollController.offset <= 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      await ref
          .read(misskeyTimelineProvider(widget.timelineType).notifier)
          .loadMore();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(
      misskeyTimelineProvider(widget.timelineType),
    );
    final animState = ref.watch(timelineAnimationProvider);

    // 检测刚发布的帖子，自动滚动到顶部
    if (animState.highlightedNoteIds.isNotEmpty) {
      _autoScrollToTop();
    }

    final animNotifier = ref.read(timelineAnimationProvider.notifier);

    return RefreshIndicator(
      onRefresh: () {
        animNotifier.reset();
        return ref
            .read(misskeyTimelineProvider(widget.timelineType).notifier)
            .refresh();
      },
      child: timelineAsync.maybeWhen(
        data: _buildList,
        loading: () {
          if (timelineAsync.hasValue) {
            return _buildList(timelineAsync.value!);
          }
          return _buildLoadingState();
        },
        error: (err, stack) {
          if (timelineAsync.hasValue) {
            return _buildList(timelineAsync.value!);
          }
          return _buildErrorState(err);
        },
        orElse: _buildLoadingState,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: CyaniLoadingIndicator(size: 60),
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<Note> notes) {
    if (notes.isEmpty) return _buildEmptyState(context);

    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    final animNotifier = ref.read(timelineAnimationProvider.notifier);

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: Column(
        children: [
          // 搜索框
          _buildSearchBar(),
          // 帖子列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notes.length + 1,
              scrollCacheExtent: ScrollCacheExtent.pixels(isWindows ? 500 : 1500),
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < notes.length) {
                  final note = notes[index];
                  final isRecent = animNotifier.isRecent(note.id);
                  final isHighlighted = animNotifier.isHighlighted(note.id);

                  Widget card = ModernNoteCard(
                    key: ValueKey(note.id),
                    note: note,
                    timelineType: widget.timelineType,
                    isHighlighted: isHighlighted,
                    onHighlightEnd: () {
                      animNotifier.clearHighlight(note.id);
                    },
                  );

                  if (isRecent) {
                    card = card
                        .animate(onComplete: (c) => c.stop())
                        .slideY(begin: -0.4, end: 0, duration: 350.ms,
                            curve: Curves.easeOutCubic)
                        .fadeIn(duration: 350.ms, curve: Curves.easeOut);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      animNotifier.dismissRecent(note.id);
                    });
                  }

                  return card;
                }
                return _buildLoadMoreIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        context.push('/search');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              '搜索帖子、用户...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.auto_awesome_motion_outlined,
            title: 'timeline_no_notes_found'.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object err) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            message: 'Error: $err',
            retryLabel: 'common_reload'.tr(),
            onRetry: () {
              ref.read(timelineAnimationProvider.notifier).reset();
              ref
                  .read(misskeyTimelineProvider(widget.timelineType).notifier)
                  .refresh();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return _isLoadingMore
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CyaniLoadingIndicator(size: 30),
            ),
          )
        : const SizedBox(height: 80);
  }
}
