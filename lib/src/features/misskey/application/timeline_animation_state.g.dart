// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_animation_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 时间线动画 Notifier
///
/// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
/// 与列表数据解耦，只管理动画状态。

@ProviderFor(TimelineAnimation)
final timelineAnimationProvider = TimelineAnimationProvider._();

/// 时间线动画 Notifier
///
/// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
/// 与列表数据解耦，只管理动画状态。
final class TimelineAnimationProvider
    extends $NotifierProvider<TimelineAnimation, TimelineAnimationState> {
  /// 时间线动画 Notifier
  ///
  /// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
  /// 与列表数据解耦，只管理动画状态。
  TimelineAnimationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineAnimationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineAnimationHash();

  @$internal
  @override
  TimelineAnimation create() => TimelineAnimation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineAnimationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineAnimationState>(value),
    );
  }
}

String _$timelineAnimationHash() => r'b0f57955199869f54ca33cc1ec809286b562a185';

/// 时间线动画 Notifier
///
/// 追踪新收到的帖子 ID 和待高亮帖子 ID，驱动卡片入场动画和高亮效果。
/// 与列表数据解耦，只管理动画状态。

abstract class _$TimelineAnimation extends $Notifier<TimelineAnimationState> {
  TimelineAnimationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<TimelineAnimationState, TimelineAnimationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimelineAnimationState, TimelineAnimationState>,
              TimelineAnimationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
