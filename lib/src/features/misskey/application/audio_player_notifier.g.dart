// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioPlayerController)
final audioPlayerControllerProvider = AudioPlayerControllerFamily._();

final class AudioPlayerControllerProvider
    extends
        $FunctionalProvider<
          AudioPlayerController,
          AudioPlayerController,
          AudioPlayerController
        >
    with $Provider<AudioPlayerController> {
  AudioPlayerControllerProvider._({
    required AudioPlayerControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'audioPlayerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerControllerHash();

  @override
  String toString() {
    return r'audioPlayerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AudioPlayerController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioPlayerController create(Ref ref) {
    final argument = this.argument as String;
    return audioPlayerController(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayerController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayerController>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AudioPlayerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$audioPlayerControllerHash() =>
    r'88f14c855cdf72097cae0af42bb26e6dcbb9653b';

final class AudioPlayerControllerFamily extends $Family
    with $FunctionalFamilyOverride<AudioPlayerController, String> {
  AudioPlayerControllerFamily._()
    : super(
        retry: null,
        name: r'audioPlayerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AudioPlayerControllerProvider call(String audioUrl) =>
      AudioPlayerControllerProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'audioPlayerControllerProvider';
}

@ProviderFor(audioPlayerState)
final audioPlayerStateProvider = AudioPlayerStateFamily._();

final class AudioPlayerStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioPlayerState>,
          AudioPlayerState,
          Stream<AudioPlayerState>
        >
    with $FutureModifier<AudioPlayerState>, $StreamProvider<AudioPlayerState> {
  AudioPlayerStateProvider._({
    required AudioPlayerStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'audioPlayerStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerStateHash();

  @override
  String toString() {
    return r'audioPlayerStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AudioPlayerState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AudioPlayerState> create(Ref ref) {
    final argument = this.argument as String;
    return audioPlayerState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AudioPlayerStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$audioPlayerStateHash() => r'f1bc658e4e20d8e84cf4002da5ccb4730c48c942';

final class AudioPlayerStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AudioPlayerState>, String> {
  AudioPlayerStateFamily._()
    : super(
        retry: null,
        name: r'audioPlayerStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AudioPlayerStateProvider call(String audioUrl) =>
      AudioPlayerStateProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'audioPlayerStateProvider';
}
