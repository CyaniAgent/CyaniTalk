import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/misskey/application/timeline_animation_state.dart';
import '/src/features/misskey/presentation/widgets/modern_note_card.dart';

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

    return timelineAsync.maybeWhen(
      data: (notes) => _buildList(notes),
      loading: () {
        if (timelineAsync.hasValue) {
          return _buildList(timelineAsync.value!);
        }
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        if (timelineAsync.hasValue) {
          return _buildList(timelineAsync.value!);
        }
        return _buildErrorState(err);
      },
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildList(List<dynamic> notes) {
    if (notes.isEmpty) return _buildEmptyState(context);

    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    final animNotifier = ref.read(timelineAnimationProvider.notifier);

    return RefreshIndicator(
      onRefresh: () {
        animNotifier.reset();
        return ref
            .read(misskeyTimelineProvider(widget.timelineType).notifier)
            .refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: notes.length + 1,
        cacheExtent: isWindows ? 500 : 1500,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $err', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(timelineAnimationProvider.notifier).reset();
                ref
                    .read(misskeyTimelineProvider(widget.timelineType).notifier)
                    .refresh();
              },
              child: Text('common_reload'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return _isLoadingMore
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        : const SizedBox(height: 80);
  }
}
