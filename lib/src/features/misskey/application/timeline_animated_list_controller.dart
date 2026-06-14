import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_animated_list_controller.g.dart';

/// 标记发帖时间的 Provider，用于在发帖后将新收到的笔记标记为"刚发布的"
@riverpod
class PostCreation extends _$PostCreation {
  @override
  DateTime? build() => null;

  void markPosted() {
    state = DateTime.now();
  }

  void clear() {
    state = null;
  }
}

/// 时间线列表状态控制器
///
/// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
/// 不管理列表数据本身（列表数据由 Riverpod 状态管理），只管理动画状态。
class TimelineListController {
  final Set<String> _recentNoteIds = {};
  final Set<String> _pendingHighlightIds = {};

  Set<String> get recentNoteIds => _recentNoteIds;
  Set<String> get pendingHighlightIds => _pendingHighlightIds;

  bool isRecent(String noteId) => _recentNoteIds.contains(noteId);
  bool isHighlighted(String noteId) => _pendingHighlightIds.contains(noteId);

  /// 标记为新收到的帖子（入场动画用）
  void markRecent(String noteId) {
    _recentNoteIds.add(noteId);
  }

  /// 标记为刚发布的帖子（高亮动画用）
  void markJustPosted(String noteId) {
    _pendingHighlightIds.add(noteId);
  }

  /// 清除单个高亮
  void clearHighlight(String noteId) {
    _pendingHighlightIds.remove(noteId);
  }

  /// 重置所有状态（切换时间线 / 下拉刷新时调用）
  void reset() {
    _recentNoteIds.clear();
    _pendingHighlightIds.clear();
  }
}
