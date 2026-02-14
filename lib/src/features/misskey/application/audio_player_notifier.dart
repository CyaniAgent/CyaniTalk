import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';

/// 音频播放器状态
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

/// 音频播放器状态管理类
class AudioPlayerController {
  /// 音频URL
  final String audioUrl;

  /// AudioPlayer 实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 状态
  AudioPlayerState _state = const AudioPlayerState();

  /// 状态变化回调
  Function(AudioPlayerState)? onStateChanged;

  /// 监听器订阅
  final List<StreamSubscription> _subscriptions = [];

  /// 构造函数
  AudioPlayerController(this.audioUrl) {
    _initListeners();
  }

  /// 获取当前状态
  AudioPlayerState get state => _state;

  /// 设置状态并通知监听器
  void _setState(AudioPlayerState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  /// 初始化监听器
  void _initListeners() {
    _subscriptions.add(
      _audioPlayer.onPositionChanged.listen((pos) {
        _setState(_state.copyWith(position: pos));
      }),
    );

    _subscriptions.add(
      _audioPlayer.onDurationChanged.listen((dur) {
        _setState(_state.copyWith(duration: dur));
      }),
    );

    _subscriptions.add(
      _audioPlayer.onPlayerStateChanged.listen((playerState) {
        _setState(
          _state.copyWith(isPlaying: playerState == PlayerState.playing),
        );
      }),
    );

    _subscriptions.add(
      _audioPlayer.onPlayerComplete.listen((event) {
        _setState(_state.copyWith(isPlaying: false, position: Duration.zero));
      }),
    );
  }

  /// 切换播放/暂停状态
  Future<void> togglePlayPause() async {
    try {
      if (_state.isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.source == null) {
          _setState(_state.copyWith(isLoading: true, error: ''));
          await _audioPlayer.setSource(UrlSource(audioUrl));
          _setState(_state.copyWith(isLoading: false));
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      logger.error('AudioPlayerController: Error toggling play/pause: $e');
      _setState(
        _state.copyWith(isLoading: false, error: 'Failed to play audio: $e'),
      );
    }
  }

  /// 跳转播放位置
  Future<void> seek(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  /// 清理资源
  Future<void> dispose() async {
    onStateChanged = null;
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    await _audioPlayer.dispose();
  }
}

/// 音频播放器控制器提供者
final audioPlayerControllerProvider =
    Provider.family<AudioPlayerController, String>((ref, audioUrl) {
      final controller = AudioPlayerController(audioUrl);

      ref.onDispose(() {
        controller.dispose();
      });

      return controller;
    });

/// 音频播放器状态提供者
final audioPlayerStateProvider =
    StreamProvider.family<AudioPlayerState, String>((ref, audioUrl) async* {
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

      ref.onDispose(() {
        streamController.close();
      });
    });
