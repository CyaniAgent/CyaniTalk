import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/logger.dart';

/// 统一的媒体浏览器组件，支持图片和视频
class MediaViewer extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final String? heroTag;

  const MediaViewer({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // 预加载初始媒体和相邻媒体
    _preloadInitialMedia();
  }

  // 预加载初始媒体和相邻媒体
  void _preloadInitialMedia() {
    // 预加载初始媒体
    if (widget.mediaItems.isNotEmpty &&
        _currentIndex < widget.mediaItems.length) {
      _preloadSingleMedia(widget.mediaItems[_currentIndex]);
    }

    // 预加载下一个媒体
    if (widget.mediaItems.length > 1 &&
        _currentIndex + 1 < widget.mediaItems.length) {
      _preloadSingleMedia(widget.mediaItems[_currentIndex + 1]);
    }

    // 预加载上一个媒体
    if (_currentIndex > 0) {
      _preloadSingleMedia(widget.mediaItems[_currentIndex - 1]);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 释放媒体播放器资源
    for (var item in widget.mediaItems) {
      try {
        if (item.type == MediaType.video && item.videoController != null) {
          item.videoController?.dispose();
          item.videoController = null;
        } else if (item.type == MediaType.audio && item.audioPlayer != null) {
          item.audioPlayer?.dispose();
          item.audioPlayer = null;
        }
      } catch (e) {
        logger.warning('Error disposing media resources', e);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          // 点击非媒体区域关闭
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            // 媒体浏览区域
            GestureDetector(
              onTap: () {
                // 点击媒体区域不关闭
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaItems.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // 预加载相邻的媒体
                  _preloadMedia(index);
                },
                physics: const BouncingScrollPhysics(),
                pageSnapping: true,
                itemBuilder: (context, index) {
                  final mediaItem = widget.mediaItems[index];

                  // 添加页面切换动画
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      // 检查当前 child 是否为当前索引的页面（incoming）
                      final isIncoming = child.key == ValueKey<int>(index);

                      // 使用非线性动画曲线
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      );

                      // 实现缩放和淡入淡出动画
                      return ScaleTransition(
                        scale: curvedAnimation,
                        child: FadeTransition(
                          opacity: curvedAnimation,
                          // 如果是正在退出的组件，则屏蔽其辅助功能语义
                          child: isIncoming ? child : ExcludeSemantics(child: child),
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(index),
                      child: () {
                        if (mediaItem.type == MediaType.image) {
                          return _buildImageViewer(mediaItem, index);
                        } else if (mediaItem.type == MediaType.video) {
                          return _buildVideoViewer(mediaItem, index);
                        } else if (mediaItem.type == MediaType.audio) {
                          return _buildAudioViewer(mediaItem, index);
                        }
                        return const Center(
                          child: Text('Unsupported media type'),
                        );
                      }(),
                    ),
                  );
                },
              ),
            ),

            // 左侧翻页按钮
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(56, 56),
                    ),
                    child: const Icon(Icons.chevron_left, size: 24),
                  ),
                ),
              ),

            // 右侧翻页按钮
            if (_currentIndex < widget.mediaItems.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(56, 56),
                    ),
                    child: const Icon(Icons.chevron_right, size: 24),
                  ),
                ),
              ),

            // 顶部控件
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 关闭按钮
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.close),
                  ),

                  // 媒体索引指示器 - 遵循MD3规范
                  if (widget.mediaItems.length > 1)
                    FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.mediaItems.length}',
                      ),
                    ),

                  // 占位
                  const SizedBox(width: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图片查看器
  Widget _buildImageViewer(MediaItem mediaItem, int index) {
    final isInitialItem = index == widget.initialIndex;
    final currentHeroTag = isInitialItem ? widget.heroTag : null;

    return PhotoView(
      imageProvider: NetworkImage(mediaItem.url),
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2.0,
      initialScale: PhotoViewComputedScale.contained,
      basePosition: Alignment.center,
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      heroAttributes: currentHeroTag != null
          ? PhotoViewHeroAttributes(tag: currentHeroTag)
          : null,
      loadingBuilder: (context, event) =>
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.error_outline,
          size: 50,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  // 构建视频查看器
  Widget _buildVideoViewer(MediaItem mediaItem, int index) {
    bool showControls = true;

    mediaItem.videoController ??=
        VideoPlayerController.networkUrl(Uri.parse(mediaItem.url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                // 初始化完成后播放视频
                mediaItem.videoController?.play();
              });
            }
          });

    void togglePlayPause() {
      if (mediaItem.videoController == null) return;

      setState(() {
        if (mediaItem.videoController!.value.isPlaying) {
          mediaItem.videoController?.pause();
        } else {
          mediaItem.videoController?.play();
        }
      });
    }

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }

    return Center(
      child: mediaItem.videoController?.value.isInitialized ?? false
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showControls = !showControls;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: mediaItem.videoController!.value.aspectRatio,
                    child: VideoPlayer(mediaItem.videoController!),
                  ),
                  if (showControls)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(150),
                            Colors.transparent,
                            Colors.black.withAlpha(150),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 顶部空间，保持对称
                          SizedBox(height: 40),

                          // 中心播放/暂停按钮
                          IconButton(
                            icon: Icon(
                              mediaItem.videoController!.value.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: Colors.white,
                              size: 80,
                            ),
                            onPressed: togglePlayPause,
                          ),

                          // 底部控制栏
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(50),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  // 进度条
                                  VideoProgressIndicator(
                                    mediaItem.videoController!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      bufferedColor: Colors.white.withAlpha(
                                        100,
                                      ),
                                      backgroundColor: Colors.white.withAlpha(
                                        50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 时间显示
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(
                                          mediaItem
                                              .videoController!
                                              .value
                                              .position,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        formatDuration(
                                          mediaItem
                                              .videoController!
                                              .value
                                              .duration,
                                        ),
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
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // 构建音频播放器
  Widget _buildAudioViewer(MediaItem mediaItem, int index) {
    if (mediaItem.url.isEmpty) {
      return const Center(child: Text('Invalid audio URL'));
    }

    if (mediaItem.audioPlayer == null) {
      mediaItem.audioPlayer = AudioPlayer();
      // 预加载并播放音频
      mediaItem.audioPlayer
          ?.setSource(UrlSource(mediaItem.url))
          .then((_) {
            if (mounted) {
              mediaItem.audioPlayer?.resume();
            }
          })
          .catchError((error) {
            logger.error('Error loading audio', error);
          });
    }

    final theme = Theme.of(context);
    final audioPlayer = mediaItem.audioPlayer;

    // 格式化时间
    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(d.inMinutes.remainder(60));
      final seconds = twoDigits(d.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(240),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 音频图标和标题
            if (mediaItem.fileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mediaItem.fileName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // 控制按钮和进度条
            Row(
              children: [
                // 播放/暂停切换按钮
                StreamBuilder<PlayerState>(
                  stream: audioPlayer?.onPlayerStateChanged,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data ?? PlayerState.stopped;
                    final isPlaying = playerState == PlayerState.playing;

                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer?.pause();
                        } else {
                          audioPlayer?.resume();
                        }
                      },
                    );
                  },
                ),
                // 进度条和时间显示
                Expanded(
                  child: Column(
                    children: [
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
                              final value = duration.inMilliseconds > 0
                                  ? ((position.inMilliseconds /
                                                duration.inMilliseconds) *
                                            100)
                                        .clamp(0.0, 100.0)
                                  : 0.0;

                              return Column(
                                children: [
                                  // 进度条
                                  Slider(
                                    value: value,
                                    min: 0,
                                    max: 100,
                                    onChanged: (sliderValue) {
                                      // 实现进度调节
                                      final newPosition =
                                          (duration.inMilliseconds *
                                                  (sliderValue / 100))
                                              .toInt();
                                      audioPlayer?.seek(
                                        Duration(milliseconds: newPosition),
                                      );
                                    },
                                    activeColor: theme.colorScheme.primary,
                                    inactiveColor: theme.colorScheme.surface,
                                  ),
                                  // 时间显示
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${formatDuration(position)} / ${formatDuration(duration)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 预加载媒体
  void _preloadMedia(int currentIndex) {
    // 预加载下一个媒体
    if (currentIndex + 1 < widget.mediaItems.length) {
      final nextItem = widget.mediaItems[currentIndex + 1];
      _preloadSingleMedia(nextItem);
    }

    // 预加载上一个媒体
    if (currentIndex - 1 >= 0) {
      final prevItem = widget.mediaItems[currentIndex - 1];
      _preloadSingleMedia(prevItem);
    }
  }

  // 预加载单个媒体
  void _preloadSingleMedia(MediaItem mediaItem) async {
    if (mediaItem.url.isEmpty) return;

    try {
      // 检查是否已经缓存
      if (!mediaItem.isCached) {
        // 使用CacheManager缓存媒体文件
        // 这个异步操作即使在MediaViewer关闭后也会在后台继续完成
        final cachedPath = await cacheManager.cacheFile(
          mediaItem.url,
          mediaItem.cacheCategory,
        );
        mediaItem.cachedPath = cachedPath;
        mediaItem.isCached = true;
        logger.debug('Media background caching completed for: ${mediaItem.url}');
      }

      // 如果组件已经销毁，不再初始化控制器
      if (!mounted) return;

      if (mediaItem.type == MediaType.image) {
        // 预加载图片
        if (mediaItem.cachedPath != null) {
          precacheImage(FileImage(File(mediaItem.cachedPath!)), context);
        } else {
          precacheImage(NetworkImage(mediaItem.url), context);
        }
      } else if (mediaItem.type == MediaType.video &&
          mediaItem.videoController == null) {
        // 预加载视频
        if (mediaItem.cachedPath != null) {
          mediaItem.videoController = VideoPlayerController.file(
            File(mediaItem.cachedPath!),
          )..initialize();
        } else {
          mediaItem.videoController = VideoPlayerController.networkUrl(
            Uri.parse(mediaItem.url),
          )..initialize();
        }
      } else if (mediaItem.type == MediaType.audio &&
          mediaItem.audioPlayer == null) {
        // 预加载音频
        mediaItem.audioPlayer = AudioPlayer();
        if (mediaItem.cachedPath != null) {
          mediaItem.audioPlayer?.setSource(DeviceFileSource(mediaItem.cachedPath!));
        } else {
          mediaItem.audioPlayer?.setSource(UrlSource(mediaItem.url));
        }
      }
    } catch (error) {
      logger.error('Error preloading media', error);
      // 如果缓存失败，使用网络加载
      if (!mounted) return;

      if (mediaItem.type == MediaType.image) {
        precacheImage(NetworkImage(mediaItem.url), context);
      } else if (mediaItem.type == MediaType.video &&
          mediaItem.videoController == null) {
        mediaItem.videoController = VideoPlayerController.networkUrl(
          Uri.parse(mediaItem.url),
        )..initialize();
      } else if (mediaItem.type == MediaType.audio &&
          mediaItem.audioPlayer == null) {
        mediaItem.audioPlayer = AudioPlayer();
        mediaItem.audioPlayer?.setSource(UrlSource(mediaItem.url));
      }
    }
  }
}

/// 媒体类型枚举
enum MediaType { image, video, audio }

/// 媒体项类
class MediaItem {
  final String url;
  final MediaType type;
  final String? fileName;
  VideoPlayerController? videoController;
  AudioPlayer? audioPlayer;
  String? cachedPath;
  bool isCached = false;

  MediaItem({required this.url, required this.type, this.fileName});

  /// 获取对应的缓存类别
  CacheCategory get cacheCategory {
    switch (type) {
      case MediaType.image:
        return CacheCategory.image;
      case MediaType.audio:
        return CacheCategory.audio;
      case MediaType.video:
        return CacheCategory.other;
    }
  }
}
