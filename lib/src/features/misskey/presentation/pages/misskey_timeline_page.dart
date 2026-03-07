import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/core/theme/desktop_semantic_colors.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
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
    final desktopColors = context.desktopSemanticColors;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: desktopColors.timelineBackground),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: desktopColors.timelineContainerBackground,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: desktopColors.timelineBorder),
              boxShadow: [
                BoxShadow(
                  color: desktopColors.timelineShadow,
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: timelineAsync.maybeWhen(
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<dynamic> notes) {
    if (notes.isEmpty) return _buildEmptyState(context);

    final isWindows = Theme.of(context).platform == TargetPlatform.windows;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(misskeyTimelineProvider(widget.timelineType).notifier)
          .refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: notes.length + 1,
        cacheExtent: isWindows ? 500 : 1500,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index < notes.length) {
            final note = notes[index];
            return Column(
              children: [
                ModernNoteCard(
                      key: ValueKey(note.id),
                      note: note,
                      timelineType: widget.timelineType,
                      useListLayout: true,
                    )
                    .animate(onComplete: (controller) => controller.stop())
                    .fadeIn(duration: 280.ms, curve: Curves.easeOut),
                if (index != notes.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    thickness: 0.6,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            );
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
              onPressed: () => ref
                  .read(misskeyTimelineProvider(widget.timelineType).notifier)
                  .refresh(),
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
