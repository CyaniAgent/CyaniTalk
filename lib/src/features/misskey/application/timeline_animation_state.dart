import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 时间线动画状态
class TimelineAnimationState {
  final Set<String> recentNoteIds;
  final Set<String> highlightedNoteIds;

  const TimelineAnimationState({
    this.recentNoteIds = const {},
    this.highlightedNoteIds = const {},
  });
}

/// 时间线动画 Notifier
///
/// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
/// 与列表数据解耦，只管理动画状态。
class TimelineAnimationNotifier extends Notifier<TimelineAnimationState> {
  final Set<String> _recent = {};
  final Set<String> _highlighted = {};

  @override
  TimelineAnimationState build() {
    ref.onDispose(() {
      _recent.clear();
      _highlighted.clear();
    });
    return const TimelineAnimationState();
  }

  bool isRecent(String noteId) => _recent.contains(noteId);
  bool isHighlighted(String noteId) => _highlighted.contains(noteId);

  void markRecent(String noteId) {
    _recent.add(noteId);
    _emit();
  }

  void markJustPosted(String noteId) {
    _highlighted.add(noteId);
    _recent.add(noteId);
    _emit();
  }

  void dismissRecent(String noteId) {
    _recent.remove(noteId);
    _emit();
  }

  void clearHighlight(String noteId) {
    _highlighted.remove(noteId);
    _emit();
  }

  void reset() {
    _recent.clear();
    _highlighted.clear();
    _emit();
  }

  void _emit() {
    state = TimelineAnimationState(
      recentNoteIds: Set.of(_recent),
      highlightedNoteIds: Set.of(_highlighted),
    );
  }
}

final timelineAnimationProvider =
    NotifierProvider<TimelineAnimationNotifier, TimelineAnimationState>(
  TimelineAnimationNotifier.new,
);
