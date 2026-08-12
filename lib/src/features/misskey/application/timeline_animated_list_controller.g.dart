// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_animated_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 标记发帖时间的 Provider，用于在发帖后将新收到的笔记标记为"刚发布的"

@ProviderFor(PostCreation)
final postCreationProvider = PostCreationProvider._();

/// 标记发帖时间的 Provider，用于在发帖后将新收到的笔记标记为"刚发布的"
final class PostCreationProvider
    extends $NotifierProvider<PostCreation, DateTime?> {
  /// 标记发帖时间的 Provider，用于在发帖后将新收到的笔记标记为"刚发布的"
  PostCreationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postCreationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postCreationHash();

  @$internal
  @override
  PostCreation create() => PostCreation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$postCreationHash() => r'b45898079b66d3e421c91b87cb5b32624cef64d4';

/// 标记发帖时间的 Provider，用于在发帖后将新收到的笔记标记为"刚发布的"

abstract class _$PostCreation extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
