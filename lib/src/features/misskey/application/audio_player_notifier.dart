import 'dart:async';
import 'dart:io';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../../../core/utils/cache_manager.dart';
import '../../../core/utils/logger.dart';

/// 音频播放器状态
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration duration;
  final Duration position;
  final String? cachedFilePath;
  final AudioSource? audioSource;
  final SoundHandle? soundHandle;
  final String error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.cachedFilePath,
    this.audioSource,
    this.soundHandle,
    this.error = '',
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? duration,
    Duration? position,
    String? cachedFilePath,
    AudioSource? audioSource,
    SoundHandle? soundHandle,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      cachedFilePath: cachedFilePath ?? this.cachedFilePath,
      audioSource: audioSource ?? this.audioSource,
      soundHandle: soundHandle ?? this.soundHandle,
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
  
  /// 文件名
  final String? fileName;
  
  /// 位置轮询定时器
  Timer? _positionTimer;
  
  /// 状态
  AudioPlayerState _state = const AudioPlayerState();
  
  /// 状态变化回调
  Function(AudioPlayerState)? onStateChanged;

  /// 构造函数
  AudioPlayerController(this.audioUrl, this.fileName);

  /// 获取当前状态
  AudioPlayerState get state => _state;

  /// 设置状态并通知监听器
  void _setState(AudioPlayerState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  /// 切换播放/暂停状态
  Future<void> togglePlayPause() async {
    final currentState = _state;

    if (currentState.isPlaying) {
      // 暂停播放
      if (currentState.soundHandle != null) {
        SoLoud.instance.setPause(currentState.soundHandle!, true);
        _setState(_state.copyWith(isPlaying: false));
        _stopPositionPolling();
      }
    } else {
      // 开始播放
      if (currentState.audioSource == null) {
        // 加载音频
        _setState(_state.copyWith(isLoading: true, error: ''));
        
        try {
          // 确保文件已缓存
          final cachedFilePath = currentState.cachedFilePath ?? await cacheManager.cacheFile(audioUrl);
          final file = File(cachedFilePath);
          
          if (await file.exists()) {
            final audioSource = await SoLoud.instance.loadFile(cachedFilePath);
            final duration = SoLoud.instance.getLength(audioSource);
            
            _setState(_state.copyWith(
              cachedFilePath: cachedFilePath,
              audioSource: audioSource,
              duration: duration,
              isLoading: false,
            ));
          } else {
            throw Exception('Cache file not found');
          }
        } catch (e) {
          logger.error('AudioPlayerController: Error loading audio: $e');
          _setState(_state.copyWith(
            isLoading: false,
            error: 'Failed to load audio: $e',
          ));
          return;
        }
      }

      // 播放音频
      final updatedState = _state;
      if (updatedState.audioSource != null) {
        SoundHandle soundHandle;
        
        if (updatedState.soundHandle != null && SoLoud.instance.getPause(updatedState.soundHandle!)) {
          // 恢复播放
          SoLoud.instance.setPause(updatedState.soundHandle!, false);
          soundHandle = updatedState.soundHandle!;
        } else {
          // 开始新的播放
          soundHandle = await SoLoud.instance.play(updatedState.audioSource!);
        }
        
        _setState(_state.copyWith(
          isPlaying: true,
          soundHandle: soundHandle,
        ));
        
        _startPositionPolling();
      }
    }
  }

  /// 开始位置轮询
  void _startPositionPolling() {
    _stopPositionPolling();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final currentState = _state;
      if (currentState.soundHandle != null && currentState.isPlaying) {
        final pos = SoLoud.instance.getPosition(currentState.soundHandle!);
        
        // 检查是否播放完成
        if (pos >= currentState.duration && currentState.duration > Duration.zero) {
          _stopAndReset();
          return;
        }
        
        _setState(_state.copyWith(position: pos));
      }
    });
  }

  /// 停止位置轮询
  void _stopPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  /// 停止并重置播放器
  Future<void> _stopAndReset() async {
    final currentState = _state;
    
    _stopPositionPolling();
    
    if (currentState.soundHandle != null) {
      await SoLoud.instance.stop(currentState.soundHandle!);
    }
    
    if (currentState.audioSource != null) {
      SoLoud.instance.disposeSource(currentState.audioSource!);
    }
    
    _setState(_state.copyWith(
      isPlaying: false,
      isLoading: false,
      position: Duration.zero,
      audioSource: null,
      soundHandle: null,
    ));
  }

  /// 跳转播放位置
  void seek(double value) {
    final currentState = _state;
    if (currentState.soundHandle == null) return;
    
    final position = Duration(seconds: value.toInt());
    SoLoud.instance.seek(currentState.soundHandle!, position);
    _setState(_state.copyWith(position: position));
  }

  /// 清理资源
  Future<void> dispose() async {
    await _stopAndReset();
  }
}
