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
    r'8dda75be5c772100265aad2868271d07a17a2161';

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
