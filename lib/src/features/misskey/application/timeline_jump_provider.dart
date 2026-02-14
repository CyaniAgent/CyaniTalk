import 'package:flutter_riverpod/legacy.dart';

/// 用于在时间线中跳转到特定笔记的信号提供者
final timelineJumpProvider = StateProvider.family<String?, String>(
  (ref, timelineType) => null,
);
