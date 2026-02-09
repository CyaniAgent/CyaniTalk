import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/logger.dart';

/// Fullscreen video player with semi-transparent background
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isLoading = true;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 初始化视频播放器
  Future<void> _initializeVideoPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 尝试从缓存加载视频
      final cachedFilePath = await _getCachedVideoPath();
      
      if (cachedFilePath != null) {
        // 使用缓存文件
        logger.info('VideoPlayer: Using cached video file');
        await _setupController(Uri.file(cachedFilePath));
      } else {
        // 直接使用网络URL
        logger.info('VideoPlayer: Using network URL');
        await _setupController(Uri.parse(widget.videoUrl));
      }
    } catch (e) {
      logger.error('VideoPlayer: Initialization error', e);
      _handleError('视频加载失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取缓存的视频路径
  Future<String?> _getCachedVideoPath() async {
    try {
      // 检查视频是否已缓存且有效
      final isCached = await cacheManager.isFileCachedAndValid(widget.videoUrl);
      if (isCached) {
        return await cacheManager.getCacheFilePath(widget.videoUrl);
      }
      
      // 尝试缓存视频
      return await cacheManager.cacheFile(widget.videoUrl);
    } catch (e) {
      logger.warning('VideoPlayer: Cache error', e);
      return null;
    }
  }

  /// 设置视频控制器
  Future<void> _setupController(Uri uri) async {
    // 释放旧控制器
    _controller?.dispose();
    
    // 创建新控制器
    _controller = VideoPlayerController.networkUrl(uri);
    
    // 初始化控制器
    await _controller!.initialize();
    
    // 开始播放
    await _controller!.play();
    
    // 更新状态
    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });
  }

  /// 处理错误
  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
      _isInitialized = false;
    });
  }

  /// 重试加载视频
  void _retry() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      _initializeVideoPlayer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video player
            Center(
              child: _buildVideoContent(),
            ),
            // Controls overlay
            if (_showControls && _isInitialized && _controller != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top bar with close button
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.surface,
                                size: 32,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      // Center play/pause button
                      Center(
                        child: IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Theme.of(context).colorScheme.surface,
                            size: 64,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      // Bottom controls
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Progress bar
                            VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Theme.of(context).colorScheme.primary,
                                bufferedColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Time display
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_controller!.value.position),
                                  style: TextStyle(color: Theme.of(context).colorScheme.surface),
                                ),
                                Text(
                                  _formatDuration(_controller!.value.duration),
                                  style: TextStyle(color: Theme.of(context).colorScheme.surface),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建视频内容区域
  Widget _buildVideoContent() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '加载视频中...',
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_retryCount < _maxRetries)
            ElevatedButton(
              onPressed: _retry,
              child: Text('重试 (${_retryCount + 1}/$_maxRetries)'),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('关闭'),
          ),
        ],
      );
    }

    if (_isInitialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }

    return const CircularProgressIndicator();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
