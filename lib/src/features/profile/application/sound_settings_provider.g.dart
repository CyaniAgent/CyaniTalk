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
    r'd7dd5a91f30031e4e68ea2f7badd47e00660f0e2';

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
