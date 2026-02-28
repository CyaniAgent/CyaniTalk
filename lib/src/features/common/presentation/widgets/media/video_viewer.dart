import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/performance_monitor.dart';
import 'media_item.dart';

/// 视频查看器组件
class VideoViewer extends StatefulWidget {
  final MediaItem mediaItem;
  final bool showControls;
  final Function(bool) onControlsToggle;

  const VideoViewer({
    super.key,
    required this.mediaItem,
    required this.showControls,
    required this.onControlsToggle,
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _initializeVideo() {
    if (widget.mediaItem.videoController == null) {
      if (widget.mediaItem.cachedPath != null) {
        final startTime = DateTime.now();
        widget.mediaItem.videoController = VideoPlayerController.file(
          File(widget.mediaItem.cachedPath!),
        )..initialize().then((_) {
            if (mounted) {
              setState(() {
                widget.mediaItem.videoController?.play();
                _resetHideTimer();
              });
              
              // 记录本地视频加载性能
              final duration = DateTime.now().difference(startTime);
              performanceMonitor.trackMediaLoading(
                widget.mediaItem.cachedPath!,
                duration,
                'video_local',
              );
            }
          }).catchError((error) {
            logger.error('Error initializing video controller from file', error);
            // Fallback to network if file initialization fails
            if (mounted) {
              _initializeVideoFromNetwork();
            }
            
            // 记录本地视频加载失败性能
            final duration = DateTime.now().difference(startTime);
            performanceMonitor.trackMediaLoading(
              widget.mediaItem.cachedPath!,
              duration,
              'video_local',
            );
          });
      } else {
        _initializeVideoFromNetwork();
      }
    }
  }

    void _initializeVideoFromNetwork() {
      final startTime = DateTime.now();
      widget.mediaItem.videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaItem.url),
      )..initialize().then((_) {
          if (mounted) {
            setState(() {
              widget.mediaItem.videoController?.play();
              _resetHideTimer();
            });
            
            // 记录网络视频加载性能
            final duration = DateTime.now().difference(startTime);
            performanceMonitor.trackMediaLoading(
              widget.mediaItem.url,
              duration,
              'video_network',
            );
          }
        }).catchError((error) {
          logger.error('Error initializing video controller from network', error);
          if (mounted) {
            setState(() {
              // Video initialization failed, handle error state
            });
          }
          
          // 记录网络视频加载失败性能
          final duration = DateTime.now().difference(startTime);
          performanceMonitor.trackMediaLoading(
            widget.mediaItem.url,
            duration,
            'video_network',
          );
        });
  
      // 设置视频播放器的音频流类型为媒体类型
      // 注意：video_player插件在Android上通常会自动使用适当的音频流类型
      // 但我们可以尝试确保其使用正确的音频会话
    }
  // 重置自动隐藏定时器
  void _resetHideTimer() {
    _hideControlsTimer?.cancel();
    if (widget.mediaItem.videoController?.value.isPlaying ?? false) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onControlsToggle(false);
        }
      });
    }
  }

  // 切换播放/暂停状态
  void _togglePlayPause() {
    if (widget.mediaItem.videoController == null) return;

    setState(() {
      if (widget.mediaItem.videoController!.value.isPlaying) {
        widget.mediaItem.videoController?.pause();
      } else {
        widget.mediaItem.videoController?.play();
        _resetHideTimer();
      }
    });
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final videoController = widget.mediaItem.videoController;
    final isInitialized = videoController?.value.isInitialized ?? false;
    final hasError = videoController?.value.hasError ?? false;

    return Center(
      child: isInitialized
          ? GestureDetector(
              onTap: () {
                setState(() {
                  widget.onControlsToggle(!widget.showControls);
                  if (widget.showControls) {
                    _resetHideTimer();
                  }
                });
              },
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: videoController!.value.aspectRatio,
                        child: VideoPlayer(videoController),
                      ),
                    ),
                    // 底部控制栏 - 带动画效果
                    AnimatedOpacity(
                      opacity: widget.showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: widget.showControls ? null : 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 底部控制栏
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    // 进度条
                                    VideoProgressIndicator(
                                      videoController,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: Theme.of(context).colorScheme.primary,
                                        bufferedColor: Colors.white.withAlpha(100),
                                        backgroundColor: Colors.white.withAlpha(50),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // 播放/暂停按钮和时间显示
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 播放/暂停按钮
                                        IconButton(
                                          onPressed: _togglePlayPause,
                                          icon: Icon(
                                            videoController.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          style: IconButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                          ),
                                        ),
                                        // 时间显示
                                        Text(
                                          '${_formatDuration(videoController.value.position)} / ${_formatDuration(videoController.value.duration)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '视频加载失败',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        videoController?.value.errorDescription ?? '未知错误',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // 尝试重新加载
                          videoController?.dispose();
                          widget.mediaItem.videoController = null;
                          _initializeVideo();
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
