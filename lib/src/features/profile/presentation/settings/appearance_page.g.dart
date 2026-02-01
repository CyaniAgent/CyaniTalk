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
    extends
        $AsyncNotifierProvider<AppearanceSettingsNotifier, AppearanceSettings> {
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
}

String _$appearanceSettingsNotifierHash() =>
    r'2e74466bc7438eb88f9b691d6d28cb1be7ede5de';

/// 外观设置状态管理器

abstract class _$AppearanceSettingsNotifier
    extends $AsyncNotifier<AppearanceSettings> {
  FutureOr<AppearanceSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AppearanceSettings>, AppearanceSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppearanceSettings>, AppearanceSettings>,
              AsyncValue<AppearanceSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
