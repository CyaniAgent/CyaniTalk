import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// 全屏图片查看器页面
class ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;

  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 图片画廊
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: _onPageChanged,
              builder: (context, index) {
                final imageUrl = widget.imageUrls[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  heroAttributes: widget.heroTag != null
                      ? PhotoViewHeroAttributes(tag: '${widget.heroTag}_$index')
                      : null,
                );
              },
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                  ),
                ),
              ),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            // 控制层
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(178), // 0.7 * 255
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withAlpha(178), // 0.7 * 255
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 顶部栏
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.surface,
                                size: 32,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            // 图片索引
                            if (widget.imageUrls.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.shadow
                                      .withAlpha(128), // 0.5 * 255
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 48), // 占位保持对称
                          ],
                        ),
                      ),
                      // 底部信息栏
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 左滑/右滑提示
                            if (widget.imageUrls.length > 1)
                              Row(
                                children: [
                                  Icon(
                                    Icons.chevron_left,
                                    color: Theme.of(context).colorScheme.surface
                                        .withAlpha(178), // 0.7 * 255
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '滑动切换图片',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withAlpha(178), // 0.7 * 255
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context).colorScheme.surface
                                        .withAlpha(178), // 0.7 * 255
                                  ),
                                ],
                              ),
                            // 缩放提示
                            Row(
                              children: [
                                Icon(
                                  Icons.zoom_in,
                                  color: Theme.of(context).colorScheme.surface
                                      .withAlpha(178), // 0.7 * 255
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '双指缩放',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.surface
                                        .withAlpha(178), // 0.7 * 255
                                    fontSize: 14,
                                  ),
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
}
