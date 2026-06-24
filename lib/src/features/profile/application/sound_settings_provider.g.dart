// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SoundSettingsNotifier)
final soundSettingsProvider = SoundSettingsNotifierProvider._();

final class SoundSettingsNotifierProvider
    extends $AsyncNotifierProvider<SoundSettingsNotifier, SoundSettings> {
  SoundSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundSettingsNotifierHash();

  @$internal
  @override
  SoundSettingsNotifier create() => SoundSettingsNotifier();
}

String _$soundSettingsNotifierHash() =>
    r'71389e9124bfa00be55bebb6a26adce7d9aa1419';

abstract class _$SoundSettingsNotifier extends $AsyncNotifier<SoundSettings> {
  FutureOr<SoundSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SoundSettings>, SoundSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SoundSettings>, SoundSettings>,
              AsyncValue<SoundSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
