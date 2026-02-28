// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 网络设置状态管理器

@ProviderFor(NetworkSettingsNotifier)
final networkSettingsProvider = NetworkSettingsNotifierProvider._();

/// 网络设置状态管理器
final class NetworkSettingsNotifierProvider
    extends $AsyncNotifierProvider<NetworkSettingsNotifier, NetworkSettings> {
  /// 网络设置状态管理器
  NetworkSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkSettingsNotifierHash();

  @$internal
  @override
  NetworkSettingsNotifier create() => NetworkSettingsNotifier();
}

String _$networkSettingsNotifierHash() =>
    r'8a607f2ba8f6eac6de24f5bbe8b6e7f6b3a10410';

/// 网络设置状态管理器

abstract class _$NetworkSettingsNotifier
    extends $AsyncNotifier<NetworkSettings> {
  FutureOr<NetworkSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NetworkSettings>, NetworkSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NetworkSettings>, NetworkSettings>,
              AsyncValue<NetworkSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
