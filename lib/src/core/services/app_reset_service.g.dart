// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_reset_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 应用程序重置服务

@ProviderFor(AppReset)
final appResetProvider = AppResetProvider._();

/// 应用程序重置服务
final class AppResetProvider extends $NotifierProvider<AppReset, void> {
  /// 应用程序重置服务
  AppResetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appResetHash();

  @$internal
  @override
  AppReset create() => AppReset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$appResetHash() => r'161932bdf89ff402bc7ffc992d056890b499cf65';

/// 应用程序重置服务

abstract class _$AppReset extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
