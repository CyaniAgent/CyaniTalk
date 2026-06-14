// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioEngine)
final audioEngineProvider = AudioEngineProvider._();

final class AudioEngineProvider
    extends $FunctionalProvider<AudioEngine, AudioEngine, AudioEngine>
    with $Provider<AudioEngine> {
  AudioEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioEngineHash();

  @$internal
  @override
  $ProviderElement<AudioEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioEngine create(Ref ref) {
    return audioEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioEngine>(value),
    );
  }
}

String _$audioEngineHash() => r'3037776547ea7e369db84a9936973dab7db402ba';
