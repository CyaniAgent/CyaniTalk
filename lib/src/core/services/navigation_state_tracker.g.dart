// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_state_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 导航路径状态

@ProviderFor(NavigationPath)
final navigationPathProvider = NavigationPathProvider._();

/// 导航路径状态
final class NavigationPathProvider
    extends $NotifierProvider<NavigationPath, String> {
  /// 导航路径状态
  NavigationPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationPathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationPathHash();

  @$internal
  @override
  NavigationPath create() => NavigationPath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$navigationPathHash() => r'4d672cd58866ad2469fa70019d59b30ac1d06b89';

/// 导航路径状态

abstract class _$NavigationPath extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
