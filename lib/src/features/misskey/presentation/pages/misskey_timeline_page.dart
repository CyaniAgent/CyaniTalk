// Misskey时间线页面
//
// 该文件包含MisskeyTimelinePage组件，用于显示Misskey的不同类型时间线。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
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
  ConsumerState<MisskeyTimelinePage> createState() => _MisskeyTimelinePageState();
}

/// MisskeyTimelinePage的状态管理类
class _MisskeyTimelinePageState extends ConsumerState<MisskeyTimelinePage> {
  /// 当前选中的时间线类型集合
  Set<String> _selectedTimeline = {'Global'};
  
  final ScrollController _scrollController = ScrollController();

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(misskeyTimelineProvider(_selectedTimeline.first).notifier).loadMore();
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
          // 找到笔记，尝试滚动到该位置
          // 由于是动态高度，这里使用估算值或简单的动画
          _scrollController.animateTo(
            index * 250.0, // 估算每个卡片平均高度
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          // 清除跳转信号
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
                      return ModernNoteCard(
                        key: ValueKey(notes[index].id),
                        note: notes[index],
                        timelineType: timelineType,
                      );
                    } else {
                      return _buildLoadMoreIndicator();
                    }
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $err',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(misskeyTimelineProvider(timelineType).notifier)
                            .refresh(),
                        child: Text('timeline_retry'.tr()),
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