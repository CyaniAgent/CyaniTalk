// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 外观设置状态管理器

@ProviderFor(AppearanceSettingsNotifier)
final appearanceSettingsProvider = AppearanceSettingsNotifierProvider._();

/// 外观设置状态管理器
final class AppearanceSettingsNotifierProvider
    extends $NotifierProvider<AppearanceSettingsNotifier, AppearanceSettings> {
  /// 外观设置状态管理器
  AppearanceSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceSettingsNotifierHash();

  @$internal
  @override
  AppearanceSettingsNotifier create() => AppearanceSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppearanceSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppearanceSettings>(value),
    );
  }
}

String _$appearanceSettingsNotifierHash() =>
    r'17779e9c1f1168693c16368db2b1cd04de576f28';

/// 外观设置状态管理器

abstract class _$AppearanceSettingsNotifier
    extends $Notifier<AppearanceSettings> {
  AppearanceSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppearanceSettings, AppearanceSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppearanceSettings, AppearanceSettings>,
              AppearanceSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
