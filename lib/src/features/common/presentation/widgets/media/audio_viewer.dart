import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/performance_monitor.dart';
import 'media_item.dart';

/// 音频查看器组件
class AudioViewer extends StatefulWidget {
  final MediaItem mediaItem;

  const AudioViewer({super.key, required this.mediaItem});

  @override
  State<AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<AudioViewer> {
  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  bool _isLoading = true;
  String? _errorMessage;

  void _initializeAudio() {
    if (widget.mediaItem.audioPlayer == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      widget.mediaItem.audioPlayer = AudioPlayer();

      // 优先使用网络直接播放，不等待缓存
      _initializeAudioFromNetwork();

      // 后台缓存，下次使用时可以本地播放
      if (!widget.mediaItem.isCached && widget.mediaItem.cachedPath == null) {
        _cacheAudioInBackground();
      }
    }
  }

  /// 后台缓存音频文件
  void _cacheAudioInBackground() async {
    try {
      final cachedPath = await cacheManager.cacheFile(
        widget.mediaItem.url,
        widget.mediaItem.cacheCategory,
      );
      if (mounted) {
        setState(() {
          widget.mediaItem.cachedPath = cachedPath;
          widget.mediaItem.isCached = true;
        });
      }
      logger.debug('Audio cached in background: ${widget.mediaItem.url}');
    } catch (error) {
      logger.error('Error caching audio in background', error);
      // 后台缓存失败不影响用户体验
    }
  }

  void _initializeAudioFromNetwork() {
    final startTime = DateTime.now();
    try {
      widget.mediaItem.audioPlayer
          ?.setSource(UrlSource(widget.mediaItem.url))
          .then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              widget.mediaItem.audioPlayer?.resume();
              
              // 记录音频加载性能
              final duration = DateTime.now().difference(startTime);
              performanceMonitor.trackMediaLoading(
                widget.mediaItem.url,
                duration,
                'audio',
              );
            }
          })
          .catchError((error) {
            logger.error('Error loading audio from network', error);
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = error.toString();
              });
            }
            
            // 记录失败的音频加载性能
            final duration = DateTime.now().difference(startTime);
            performanceMonitor.trackMediaLoading(
              widget.mediaItem.url,
              duration,
              'audio',
            );
          });
    } catch (error) {
      logger.error('Exception loading audio from network', error);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      }
      
      // 记录异常情况下的音频加载性能
      final duration = DateTime.now().difference(startTime);
      performanceMonitor.trackMediaLoading(
        widget.mediaItem.url,
        duration,
        'audio',
      );
    }
  }

  // 格式化时间
  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // 处理进度条拖动
  void handleSeek(double sliderValue, Duration duration) {
    try {
      final newPosition = (duration.inMilliseconds * (sliderValue / 100))
          .toInt();
      widget.mediaItem.audioPlayer?.seek(Duration(milliseconds: newPosition));
    } catch (error) {
      logger.error('Error seeking audio', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem.url.isEmpty) {
      return const Center(child: Text('Invalid audio URL'));
    }

    final theme = Theme.of(context);
    final audioPlayer = widget.mediaItem.audioPlayer;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(240),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _errorMessage != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '音频加载失败',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 尝试重新加载
                      audioPlayer?.dispose();
                      widget.mediaItem.audioPlayer = null;
                      _initializeAudio();
                    },
                    child: const Text('重试'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 音频图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.music_note, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 音频标题
                  if (widget.mediaItem.fileName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        widget.mediaItem.fileName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),

                  // 进度条和时间显示
                  StreamBuilder<Duration>(
                    stream: audioPlayer?.onDurationChanged,
                    builder: (context, durationSnapshot) {
                      final duration =
                          durationSnapshot.data ?? Duration(seconds: 1);

                      return StreamBuilder<Duration>(
                        stream: audioPlayer?.onPositionChanged,
                        builder: (context, positionSnapshot) {
                          final position =
                              positionSnapshot.data ?? Duration.zero;
                          final initialValue = duration.inMilliseconds > 0
                              ? ((position.inMilliseconds /
                                            duration.inMilliseconds) *
                                        100)
                                    .clamp(0.0, 100.0)
                              : 0.0;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              double sliderValue = initialValue;

                              // 当播放位置变化时，更新滑块位置
                              if (positionSnapshot.hasData) {
                                final newPosition = positionSnapshot.data!;
                                final newValue = duration.inMilliseconds > 0
                                    ? ((newPosition.inMilliseconds /
                                                  duration.inMilliseconds) *
                                              100)
                                          .clamp(0.0, 100.0)
                                    : 0.0;
                                if ((newValue - sliderValue).abs() > 1.0) {
                                  sliderValue = newValue;
                                }
                              }

                              return Column(
                                children: [
                                  // 进度条
                                  Opacity(
                                    opacity: _isLoading ? 0.5 : 1.0,
                                    child: Slider(
                                      value: sliderValue,
                                      min: 0,
                                      max: 100,
                                      onChanged: _isLoading
                                          ? null
                                          : (newValue) {
                                              // 实时更新UI
                                              setState(() {
                                                sliderValue = newValue;
                                              });
                                            },
                                      onChangeEnd: _isLoading
                                          ? null
                                          : (newValue) {
                                              // 只在拖动结束时seek，避免频繁调用导致异常
                                              handleSeek(newValue, duration);
                                            },
                                      activeColor: theme.colorScheme.primary,
                                      inactiveColor: theme.colorScheme.onSurface.withAlpha(100),
                                      thumbColor: theme.colorScheme.primary,
                                    ),
                                  ),

                                  // 时间显示
                                  Opacity(
                                    opacity: _isLoading ? 0.5 : 1.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(position),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          formatDuration(duration),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withAlpha(128),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 播放/暂停按钮或加载动画
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? theme.colorScheme.primary.withAlpha(180)
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : StreamBuilder<PlayerState>(
                            stream: audioPlayer?.onPlayerStateChanged,
                            builder: (context, snapshot) {
                              final playerState =
                                  snapshot.data ?? PlayerState.stopped;
                              final isPlaying =
                                  playerState == PlayerState.playing;

                              return IconButton(
                                onPressed: () {
                                  try {
                                    if (isPlaying) {
                                      audioPlayer?.pause();
                                    } else {
                                      audioPlayer?.resume();
                                    }
                                  } catch (error) {
                                    logger.error(
                                      'Error toggling play/pause',
                                      error,
                                    );
                                  }
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: theme.colorScheme.onPrimary,
                                  size: 32,
                                ),
                                iconSize: 32,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
