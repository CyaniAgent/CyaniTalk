// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_jump_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 用于在时间线中跳转到特定笔记的信号提供者

@ProviderFor(TimelineJump)
final timelineJumpProvider = TimelineJumpFamily._();

/// 用于在时间线中跳转到特定笔记的信号提供者
final class TimelineJumpProvider
    extends $NotifierProvider<TimelineJump, String?> {
  /// 用于在时间线中跳转到特定笔记的信号提供者
  TimelineJumpProvider._({
    required TimelineJumpFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'timelineJumpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$timelineJumpHash();

  @override
  String toString() {
    return r'timelineJumpProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TimelineJump create() => TimelineJump();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineJumpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$timelineJumpHash() => r'dff7faf6f453790ec08f518d1498abf24ee4a81e';

/// 用于在时间线中跳转到特定笔记的信号提供者

final class TimelineJumpFamily extends $Family
    with $ClassFamilyOverride<TimelineJump, String?, String?, String?, String> {
  TimelineJumpFamily._()
    : super(
        retry: null,
        name: r'timelineJumpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 用于在时间线中跳转到特定笔记的信号提供者

  TimelineJumpProvider call(String timelineType) =>
      TimelineJumpProvider._(argument: timelineType, from: this);

  @override
  String toString() => r'timelineJumpProvider';
}

/// 用于在时间线中跳转到特定笔记的信号提供者

abstract class _$TimelineJump extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get timelineType => _$args;

  String? build(String timelineType);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
