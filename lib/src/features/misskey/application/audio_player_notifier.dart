import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/utils/cache_manager.dart';
import '../../../core/utils/logger.dart';

/// 音频播放器状态
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration duration;
  final Duration position;
  final String? cachedFilePath;
  final AudioPlayer? player;
  final String error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.cachedFilePath,
    this.player,
    this.error = '',
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? duration,
    Duration? position,
    String? cachedFilePath,
    AudioPlayer? player,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      cachedFilePath: cachedFilePath ?? this.cachedFilePath,
      player: player ?? this.player,
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

  /// 在平台线程上执行回调
  ///
  /// 确保回调在正确的线程上执行，避免平台通道线程错误
  void _runOnPlatformThread(VoidCallback callback) {
    if (SchedulerBinding.instance != null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        callback();
      });
    } else {
      // 如果 SchedulerBinding 不可用，直接执行
      callback();
    }
  }

  /// 预加载音频并获取总时长
  ///
  /// 在用户点击播放前预先准备音频，获取总时长并显示在控件上，减少播放时的延迟
  Future<void> preload() async {
    if (_state.player != null) return; // 已经加载过了

    logger.debug('AudioPlayerController: Preloading audio: $audioUrl');

    try {
      // 创建播放器实例
      final player = AudioPlayer();

      // 监听播放完成
      player.onPlayerComplete.listen((_) {
        try {
          _runOnPlatformThread(() {
            _stopAndReset();
          });
        } catch (e) {
          logger.error('AudioPlayerController: Error on player complete: $e');
        }
      });

      // 监听位置变化
      player.onPositionChanged.listen((position) {
        try {
          _runOnPlatformThread(() {
            _setState(_state.copyWith(position: position));
          });
        } catch (e) {
          logger.error('AudioPlayerController: Error on position changed: $e');
        }
      });

      // 监听持续时间变化
      player.onDurationChanged.listen((duration) {
        try {
          _runOnPlatformThread(() {
            _setState(_state.copyWith(duration: duration));
          });
        } catch (e) {
          logger.error('AudioPlayerController: Error on duration changed: $e');
        }
      });

      // 检查是否有本地缓存
      String? cachedFilePath;
      bool useCache = false;

      try {
        cachedFilePath = await cacheManager.cacheFile(
          audioUrl,
          CacheCategory.audio,
        );
        if (File(cachedFilePath).existsSync()) {
          useCache = true;
          logger.debug(
            'AudioPlayerController: Using cached audio: $cachedFilePath',
          );
        }
      } catch (cacheError) {
        logger.warning(
          'AudioPlayerController: Cache check failed: $cacheError',
        );
        // 缓存检查失败，继续使用网络流
      }

      // 设置音频源以获取总时长，但不自动播放
      try {
        if (useCache && cachedFilePath != null) {
          // 确保 Windows 平台的路径格式正确
          final windowsPath = cachedFilePath.replaceAll('/', '\\');
          await player.setSource(DeviceFileSource(windowsPath));
        } else {
          await player.setSource(UrlSource(audioUrl));
          // 异步缓存音频，不阻塞播放
          unawaited(_cacheAudioInBackground(audioUrl));
        }
      } catch (e) {
        logger.error(
          'AudioPlayerController: Error setting audio source during preload: $e',
        );
        // 预加载时设置音频源失败，不更新错误状态，避免影响用户体验
      }

      _setState(
        _state.copyWith(player: player, cachedFilePath: cachedFilePath),
      );

      logger.debug(
        'AudioPlayerController: Audio preloaded with duration: $audioUrl',
      );
    } catch (e) {
      logger.error('AudioPlayerController: Error preloading audio: $e');
      // 预加载失败不更新错误状态，避免影响用户体验
    }
  }

  /// 准备移除预加载的音频
  ///
  /// 在不需要音频时调用，释放相关资源
  Future<void> prepareRemove() async {
    final currentState = _state;

    if (currentState.player != null && !currentState.isPlaying) {
      logger.debug(
        'AudioPlayerController: Preparing to remove preloaded audio: $audioUrl',
      );

      try {
        await currentState.player!.dispose();
        _setState(
          _state.copyWith(
            player: null,
            cachedFilePath: null,
            position: Duration.zero,
            duration: Duration.zero,
          ),
        );
        logger.debug(
          'AudioPlayerController: Preloaded audio removed: $audioUrl',
        );
      } catch (e) {
        logger.error(
          'AudioPlayerController: Error removing preloaded audio: $e',
        );
      }
    }
  }

  /// 在后台缓存音频文件
  ///
  /// 异步缓存音频，不阻塞播放
  Future<void> _cacheAudioInBackground(String url) async {
    try {
      logger.debug('AudioPlayerController: Caching audio in background: $url');
      await cacheManager.cacheFile(url, CacheCategory.audio);
      logger.debug('AudioPlayerController: Audio cached successfully: $url');
    } catch (e) {
      logger.error(
        'AudioPlayerController: Error caching audio in background: $e',
      );
      // 缓存失败不影响播放
    }
  }

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
      if (currentState.player != null) {
        try {
          await currentState.player!.pause();
          _setState(_state.copyWith(isPlaying: false));
          _stopPositionPolling();
        } catch (e) {
          logger.error('AudioPlayerController: Error pausing audio: $e');
          _setState(
            _state.copyWith(
              isPlaying: false,
              error: 'Failed to pause audio: $e',
            ),
          );
        }
      }
    } else {
      // 开始播放
      if (currentState.player == null) {
        // 加载音频
        _setState(_state.copyWith(isLoading: true, error: ''));

        try {
          // 检查是否有本地缓存
          String? cachedFilePath;
          bool useCache = false;

          try {
            cachedFilePath = await cacheManager.cacheFile(
              audioUrl,
              CacheCategory.audio,
            );
            if (File(cachedFilePath).existsSync()) {
              useCache = true;
              logger.debug(
                'AudioPlayerController: Using cached audio: $cachedFilePath',
              );
            }
          } catch (cacheError) {
            logger.warning(
              'AudioPlayerController: Cache check failed: $cacheError',
            );
            // 缓存检查失败，继续使用网络流
          }

          final player = AudioPlayer();

          // 监听播放完成
          player.onPlayerComplete.listen((_) {
            try {
              _runOnPlatformThread(() {
                _stopAndReset();
              });
            } catch (e) {
              logger.error(
                'AudioPlayerController: Error on player complete: $e',
              );
            }
          });

          // 监听位置变化
          player.onPositionChanged.listen((position) {
            try {
              _runOnPlatformThread(() {
                _setState(_state.copyWith(position: position));
              });
            } catch (e) {
              logger.error(
                'AudioPlayerController: Error on position changed: $e',
              );
            }
          });

          // 监听持续时间变化
          player.onDurationChanged.listen((duration) {
            try {
              _runOnPlatformThread(() {
                _setState(_state.copyWith(duration: duration));
              });
            } catch (e) {
              logger.error(
                'AudioPlayerController: Error on duration changed: $e',
              );
            }
          });

          // 设置音频源
          try {
            if (useCache && cachedFilePath != null) {
              // 确保 Windows 平台的路径格式正确
              final windowsPath = cachedFilePath.replaceAll('/', '\\');
              await player.setSource(DeviceFileSource(windowsPath));
            } else {
              await player.setSource(UrlSource(audioUrl));
              // 异步缓存音频，不阻塞播放
              unawaited(_cacheAudioInBackground(audioUrl));
            }
          } catch (e) {
            logger.error(
              'AudioPlayerController: Error setting audio source: $e',
            );
            // 如果设置本地文件失败，尝试使用网络流
            if (useCache && cachedFilePath != null) {
              logger.debug(
                'AudioPlayerController: Falling back to network source',
              );
              await player.setSource(UrlSource(audioUrl));
              // 异步缓存音频，不阻塞播放
              unawaited(_cacheAudioInBackground(audioUrl));
            } else {
              throw e;
            }
          }

          _setState(
            _state.copyWith(
              player: player,
              cachedFilePath: cachedFilePath,
              isLoading: false,
            ),
          );
        } catch (e) {
          logger.error('AudioPlayerController: Error loading audio: $e');
          _setState(
            _state.copyWith(
              isLoading: false,
              error: 'Failed to load audio: $e',
            ),
          );
          return;
        }
      }

      // 播放音频
      final updatedState = _state;
      if (updatedState.player != null) {
        try {
          await updatedState.player!.resume();
          _setState(_state.copyWith(isPlaying: true));
          _startPositionPolling();
        } catch (e) {
          logger.error('AudioPlayerController: Error playing audio: $e');
          _setState(
            _state.copyWith(
              isPlaying: false,
              error: 'Failed to play audio: $e',
            ),
          );
        }
      }
    }
  }

  /// 开始位置轮询
  void _startPositionPolling() {
    _stopPositionPolling();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final currentState = _state;
      if (currentState.player != null && currentState.isPlaying) {
        // 位置更新由 onPositionChanged 监听处理
        // 这里主要是为了保持与原有代码结构的一致性
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

    if (currentState.player != null) {
      try {
        // 先暂停播放
        await currentState.player!.pause();
        // 然后停止
        await currentState.player!.stop();
        // 最后释放资源
        await currentState.player!.dispose();
      } catch (e) {
        logger.error(
          'AudioPlayerController: Error stopping or disposing player: $e',
        );
      } finally {
        // 确保状态被重置，即使发生错误
        try {
          _setState(
            _state.copyWith(
              isPlaying: false,
              isLoading: false,
              position: Duration.zero,
              duration: Duration.zero,
              player: null,
            ),
          );
        } catch (e) {
          logger.error('AudioPlayerController: Error resetting state: $e');
        }
      }
    } else {
      // 如果播放器为null，直接重置状态
      try {
        _setState(
          _state.copyWith(
            isPlaying: false,
            isLoading: false,
            position: Duration.zero,
            duration: Duration.zero,
            player: null,
          ),
        );
      } catch (e) {
        logger.error('AudioPlayerController: Error resetting state: $e');
      }
    }
  }

  /// 跳转播放位置
  void seek(double value) {
    final currentState = _state;
    if (currentState.player == null) return;

    try {
      final position = Duration(seconds: value.toInt());
      // 确保播放器状态正确，并且有有效的持续时间
      if (currentState.duration > Duration.zero) {
        // 对 seek 方法的返回值进行错误处理
        currentState.player!.seek(position).catchError((e) {
          logger.error(
            'AudioPlayerController: Error during seek operation: $e',
          );
          // 只在错误严重时更新错误状态，避免影响用户体验
        });
        // 先更新UI状态，提高响应速度
        _setState(_state.copyWith(position: position));
      } else {
        logger.warning(
          'AudioPlayerController: Cannot seek - duration not available',
        );
      }
    } catch (e) {
      logger.error('AudioPlayerController: Error seeking: $e');
      // 只在错误严重时更新错误状态，避免影响用户体验
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    try {
      // 取消所有监听器
      onStateChanged = null;
      // 停止并重置播放器
      await _stopAndReset();
      logger.info('AudioPlayerController: Disposed successfully');
    } catch (e) {
      logger.error('AudioPlayerController: Error disposing: $e');
      // 即使发生错误，也要确保状态被重置
      try {
        _setState(
          _state.copyWith(
            isPlaying: false,
            isLoading: false,
            position: Duration.zero,
            duration: Duration.zero,
            player: null,
          ),
        );
      } catch (e) {
        logger.error(
          'AudioPlayerController: Error resetting state during dispose: $e',
        );
      }
    }
  }
}

/// 音频播放器控制器提供者
///
/// 使用Riverpod的Provider来管理音频播放器控制器的生命周期
final audioPlayerControllerProvider =
    Provider.family<AudioPlayerController, String>((ref, audioUrl) {
      final controller = AudioPlayerController(audioUrl, null);

      // 当提供者被销毁时，清理资源
      ref.onDispose(() async {
        await controller.dispose();
      });

      return controller;
    });

/// 音频播放器状态提供者
///
/// 使用Riverpod的StreamProvider来管理音频播放器状态，实现自动生命周期管理
/// 避免内存泄漏和手动状态管理的复杂性
final audioPlayerStateProvider =
    StreamProvider.family<AudioPlayerState, String>((ref, audioUrl) async* {
      final controller = ref.watch(audioPlayerControllerProvider(audioUrl));

      // 创建一个流控制器
      final streamController = StreamController<AudioPlayerState>();

      // 监听状态变化并发送到流
      controller.onStateChanged = (state) {
        if (!streamController.isClosed) {
          streamController.add(state);
        }
      };

      // 初始状态
      yield controller.state;

      // 监听流
      await for (final state in streamController.stream) {
        yield state;
      }

      // 当提供者被销毁时，清理资源
      ref.onDispose(() {
        streamController.close();
      });
    });
