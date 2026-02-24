// Misskey时间线内容页面
//
// 重构说明：引入了数据保留机制防止刷新白屏，并使用 flutter_animate 实现阶梯入场。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/misskey_notifier.dart';
import '../widgets/modern_note_card.dart';

class MisskeyTimelinePage extends ConsumerStatefulWidget {
  const MisskeyTimelinePage({super.key});

  @override
  ConsumerState<MisskeyTimelinePage> createState() => _MisskeyTimelinePageState();
}

class _MisskeyTimelinePageState extends ConsumerState<MisskeyTimelinePage> {
  Set<String> _selectedTimeline = {'Global'};
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      await ref.read(misskeyTimelineProvider(_selectedTimeline.first).notifier).loadMore();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineType = _selectedTimeline.first;
    final timelineAsync = ref.watch(misskeyTimelineProvider(timelineType));

    return Column(
      children: [
        // 时间线切换器
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(value: 'Global', label: Text('timeline_global'.tr()), icon: const Icon(Icons.public)),
                ButtonSegment<String>(value: 'Local', label: Text('timeline_local'.tr()), icon: const Icon(Icons.location_city)),
                ButtonSegment<String>(value: 'Social', label: Text('timeline_social'.tr()), icon: const Icon(Icons.group_outlined)),
              ],
              selected: _selectedTimeline,
              onSelectionChanged: (newSelection) {
                setState(() => _selectedTimeline = newSelection);
                ref.read(misskeyTimelineProvider(newSelection.first).notifier).refresh();
              },
            ),
          ),
        ),
        
        // 列表区域
        Expanded(
          child: timelineAsync.maybeWhen(
            data: (notes) => _buildList(notes, timelineType),
            loading: () {
              // [关键修复] 如果原本有数据，加载时不显示全屏加载器，防止白屏
              if (timelineAsync.hasValue) {
                return _buildList(timelineAsync.value!, timelineType);
              }
              return const Center(child: CircularProgressIndicator());
            },
            error: (err, stack) {
              if (timelineAsync.hasValue) {
                return _buildList(timelineAsync.value!, timelineType);
              }
              return _buildErrorState(err);
            },
            orElse: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<dynamic> notes, String timelineType) {
    if (notes.isEmpty) return _buildEmptyState(context);
    
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;

    return RefreshIndicator(
      onRefresh: () => ref.read(misskeyTimelineProvider(timelineType).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: notes.length + 1,
        // 优化：在 Windows 上显著降低 cacheExtent 以减少 AXTree 压力
        cacheExtent: isWindows ? 500 : 1500,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index < notes.length) {
            final note = notes[index];
            return ModernNoteCard(
              key: ValueKey(note.id),
              note: note,
              timelineType: timelineType,
            ).animate(
              // 关键：动画完成后停止更新，减少 AXTree 负担
              onComplete: (controller) => controller.stop(),
            )
             .fadeIn(duration: 400.ms, curve: Curves.easeOut)
             .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutBack);
          } else {
            return _buildLoadMoreIndicator();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_outlined, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('timeline_no_notes_found'.tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
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
              onPressed: () => ref.read(misskeyTimelineProvider(_selectedTimeline.first).notifier).refresh(),
              child: Text('common_reload'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return _isLoadingMore 
      ? const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
      : const SizedBox(height: 80);
  }
}
