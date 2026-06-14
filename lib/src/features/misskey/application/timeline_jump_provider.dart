import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_jump_provider.g.dart';

/// 用于在时间线中跳转到特定笔记的信号提供者
@riverpod
class TimelineJump extends _$TimelineJump {
  @override
  String? build(String timelineType) => null;

  void trigger(String? noteId) {
    state = noteId;
  }
}
