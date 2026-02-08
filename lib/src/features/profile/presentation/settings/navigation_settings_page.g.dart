// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_settings_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 导航设置状态管理器

@ProviderFor(NavigationSettingsNotifier)
final navigationSettingsProvider = NavigationSettingsNotifierProvider._();

/// 导航设置状态管理器
final class NavigationSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<NavigationSettingsNotifier, NavigationSettings> {
  /// 导航设置状态管理器
  NavigationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationSettingsNotifierHash();

  @$internal
  @override
  NavigationSettingsNotifier create() => NavigationSettingsNotifier();
}

String _$navigationSettingsNotifierHash() =>
    r'9172a7a87ea0f73b32e2afd77084fb2ac8e16682';

/// 导航设置状态管理器

abstract class _$NavigationSettingsNotifier
    extends $AsyncNotifier<NavigationSettings> {
  FutureOr<NavigationSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NavigationSettings>, NavigationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NavigationSettings>, NavigationSettings>,
              AsyncValue<NavigationSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
