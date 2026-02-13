// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_navigation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeySubIndex)
final misskeySubIndexProvider = MisskeySubIndexProvider._();

final class MisskeySubIndexProvider
    extends $NotifierProvider<MisskeySubIndex, int> {
  MisskeySubIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeySubIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeySubIndexHash();

  @$internal
  @override
  MisskeySubIndex create() => MisskeySubIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$misskeySubIndexHash() => r'6cc6a1b7aeccd324fb25bccf565d867630e10d7a';

abstract class _$MisskeySubIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ForumSubIndex)
final forumSubIndexProvider = ForumSubIndexProvider._();

final class ForumSubIndexProvider
    extends $NotifierProvider<ForumSubIndex, int> {
  ForumSubIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forumSubIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forumSubIndexHash();

  @$internal
  @override
  ForumSubIndex create() => ForumSubIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$forumSubIndexHash() => r'a8e6c5a89f11f6a7ed77b26e23fb3a4a3687dd4b';

abstract class _$ForumSubIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
