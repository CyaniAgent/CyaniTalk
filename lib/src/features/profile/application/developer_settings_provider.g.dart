// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeveloperSettingsNotifier)
final developerSettingsProvider = DeveloperSettingsNotifierProvider._();

final class DeveloperSettingsNotifierProvider
    extends $AsyncNotifierProvider<DeveloperSettingsNotifier, bool> {
  DeveloperSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developerSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developerSettingsNotifierHash();

  @$internal
  @override
  DeveloperSettingsNotifier create() => DeveloperSettingsNotifier();
}

String _$developerSettingsNotifierHash() =>
    r'8941e1c449abe97f9ab530ae9292aa81f660bb9e';

abstract class _$DeveloperSettingsNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
