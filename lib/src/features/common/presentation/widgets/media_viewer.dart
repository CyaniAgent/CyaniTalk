import 'package:flutter/material.dart';
import './media/media_item.dart';
import './media/media_preloader.dart';
import './media/image_viewer.dart';
import './media/video_viewer.dart';
import './media/audio_viewer.dart';

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
  bool _showControls = true;
  late MediaPreloader _preloader;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloader = MediaPreloader(context);

    // 检查是否为音频类型，如果是则保持控制栏始终显示
    if (widget.mediaItems.isNotEmpty &&
        widget.mediaItems[_currentIndex].type == MediaType.audio) {
      _showControls = true;
    }

    // 预加载初始媒体和相邻媒体
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloader.preloadInitialMedia(widget.mediaItems, _currentIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 释放媒体播放器资源
    MediaPreloader.disposeMediaResources(widget.mediaItems);
    super.dispose();
  }

  // 切换控制栏显示状态
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          // 只有非音频类型才响应点击非媒体区域关闭
          if (widget.mediaItems.isNotEmpty) {
            final currentMedia = widget.mediaItems[_currentIndex];
            if (currentMedia.type != MediaType.audio) {
              // 点击非媒体区域关闭
              Navigator.of(context).pop();
            }
          } else {
            // 如果没有媒体项，正常关闭
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // 媒体浏览区域
            GestureDetector(
              onTap: () {
                // 只有非音频类型才响应点击切换控制栏
                final currentMedia = widget.mediaItems[_currentIndex];
                if (currentMedia.type != MediaType.audio) {
                  _toggleControls();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaItems.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    // 检查是否为音频类型，如果是则保持控制栏始终显示
                    if (widget.mediaItems[index].type == MediaType.audio) {
                      _showControls = true;
                    }
                  });
                  // 预加载相邻的媒体
                  _preloader.preloadMedia(widget.mediaItems, index);
                },
                physics: const BouncingScrollPhysics(),
                pageSnapping: true,
                itemBuilder: (context, index) {
                  final mediaItem = widget.mediaItems[index];
                  final isInitialItem = index == widget.initialIndex;
                  final currentHeroTag = isInitialItem ? widget.heroTag : null;

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
                          child: isIncoming
                              ? child
                              : ExcludeSemantics(child: child),
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(index),
                      color: Colors.transparent,
                      child: () {
                        if (mediaItem.type == MediaType.image) {
                          return ImageViewer(
                            mediaItem: mediaItem,
                            heroTag: currentHeroTag,
                          );
                        } else if (mediaItem.type == MediaType.video) {
                          return VideoViewer(
                            mediaItem: mediaItem,
                            showControls: _showControls,
                            onControlsToggle: (show) {
                              setState(() {
                                _showControls = show;
                              });
                            },
                          );
                        } else if (mediaItem.type == MediaType.audio) {
                          return AudioViewer(mediaItem: mediaItem);
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

            // 左侧翻页按钮 - 仅在宽屏显示
            if (_currentIndex > 0 && MediaQuery.of(context).size.width > 600)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withAlpha(150),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_left, size: 24),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(56, 56),
                      ),
                    ),
                  ),
                ),
              ),

            // 右侧翻页按钮 - 仅在宽屏显示
            if (_currentIndex < widget.mediaItems.length - 1 &&
                MediaQuery.of(context).size.width > 600)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withAlpha(150),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_right, size: 24),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(56, 56),
                      ),
                    ),
                  ),
                ),
              ),

            // 顶部控件 - 带动画效果
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _showControls ? null : 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 关闭按钮 - 半透明圆形样式
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white.withAlpha(150),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      // 媒体索引指示器 - 半透明样式
                      if (widget.mediaItems.length > 1)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withAlpha(150),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            '${_currentIndex + 1}/${widget.mediaItems.length}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),

                      // 占位
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
