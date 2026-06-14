// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 音频播放器控制器提供者

@ProviderFor(audioPlayerController)
final audioPlayerControllerProvider = AudioPlayerControllerFamily._();

/// 音频播放器控制器提供者

final class AudioPlayerControllerProvider
    extends
        $FunctionalProvider<
          AudioPlayerController,
          AudioPlayerController,
          AudioPlayerController
        >
    with $Provider<AudioPlayerController> {
  /// 音频播放器控制器提供者
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

/// 音频播放器控制器提供者

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

  /// 音频播放器控制器提供者

  AudioPlayerControllerProvider call(String audioUrl) =>
      AudioPlayerControllerProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'audioPlayerControllerProvider';
}

/// 音频播放器状态提供者

@ProviderFor(audioPlayerState)
final audioPlayerStateProvider = AudioPlayerStateFamily._();

/// 音频播放器状态提供者

final class AudioPlayerStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioPlayerState>,
          AudioPlayerState,
          Stream<AudioPlayerState>
        >
    with $FutureModifier<AudioPlayerState>, $StreamProvider<AudioPlayerState> {
  /// 音频播放器状态提供者
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

/// 音频播放器状态提供者

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

  /// 音频播放器状态提供者

  AudioPlayerStateProvider call(String audioUrl) =>
      AudioPlayerStateProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'audioPlayerStateProvider';
}
