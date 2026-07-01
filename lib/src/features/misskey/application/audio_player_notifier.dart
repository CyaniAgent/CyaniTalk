import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/core/utils/logger.dart';

part 'audio_player_notifier.g.dart';

class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration duration;
  final Duration position;
  final String error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.error = '',
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? duration,
    Duration? position,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AudioPlayerState{isPlaying: $isPlaying, isLoading: $isLoading, duration: $duration, position: $position, error: $error}';
  }
}

class AudioPlayerController {
  final String audioUrl;
  final _soloud = SoLoud.instance;

  AudioSource? _source;
  SoundHandle _handle = const SoundHandle(0);
  bool _pausedByUser = false;

  AudioPlayerState _state = const AudioPlayerState();
  Function(AudioPlayerState)? onStateChanged;
  Timer? _pollTimer;

  AudioPlayerController(this.audioUrl);

  AudioPlayerState get state => _state;

  void _setState(AudioPlayerState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_handle == const SoundHandle(0) || _pausedByUser) return;
      final isValid = (_handle != const SoundHandle(0)) && _soloud.getIsValidVoiceHandle(_handle);
      if (!isValid && _handle != const SoundHandle(0)) {
        _setState(_state.copyWith(isPlaying: false, position: Duration.zero));
        _pollTimer?.cancel();
        _pausedByUser = false;
      } else {
        final pos = _soloud.getPosition(_handle);
        _setState(_state.copyWith(isPlaying: true, position: pos));
      }
    });
  }

  Future<void> togglePlayPause() async {
    try {
      if (_state.isPlaying) {
        _soloud.pauseSwitch(_handle);
        _pausedByUser = true;
        _setState(_state.copyWith(isPlaying: false));
      } else if (_pausedByUser && _handle != const SoundHandle(0)) {
        _soloud.pauseSwitch(_handle);
        _pausedByUser = false;
        _startPolling();
        _setState(_state.copyWith(isPlaying: true));
      } else {
        _setState(_state.copyWith(isLoading: true, error: ''));
        if (!_soloud.isInitialized) await _soloud.init();
        _source = await _soloud.loadUrl(audioUrl, mode: LoadMode.disk);
        final dur = _soloud.getLength(_source!);
        _handle = _soloud.play(_source!);
        _pausedByUser = false;
        _setState(
          _state.copyWith(isLoading: false, duration: dur, isPlaying: true),
        );
        _startPolling();
      }
    } catch (e) {
      logger.error('AudioPlayerController: Error toggling play/pause: $e');
      _setState(
        _state.copyWith(isLoading: false, error: 'Failed to play audio: $e'),
      );
    }
  }

  Future<void> seek(double value) async {
    if (_handle != const SoundHandle(0)) {
      final position = Duration(seconds: value.toInt());
      _soloud.seek(_handle, position);
      _setState(_state.copyWith(position: position));
    }
  }

  Future<void> dispose() async {
    onStateChanged = null;
    _pollTimer?.cancel();
    if (_handle != const SoundHandle(0)) await _soloud.stop(_handle);
    if (_source != null) await _soloud.disposeSource(_source!);
  }
}

@riverpod
AudioPlayerController audioPlayerController(Ref ref, String audioUrl) {
  final controller = AudioPlayerController(audioUrl);

  ref.onDispose(controller.dispose);

  return controller;
}

@riverpod
Stream<AudioPlayerState> audioPlayerState(Ref ref, String audioUrl) async* {
  final controller = ref.watch(audioPlayerControllerProvider(audioUrl));

  final streamController = StreamController<AudioPlayerState>();

  controller.onStateChanged = (state) {
    if (!streamController.isClosed) {
      streamController.add(state);
    }
  };

  yield controller.state;

  await for (final state in streamController.stream) {
    yield state;
  }

  ref.onDispose(streamController.close);
}
