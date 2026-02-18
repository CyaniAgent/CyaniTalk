import 'package:flutter/material.dart';
import '../widgets/media_viewer.dart';
import '../widgets/media/media_item.dart';

/// 媒体浏览器页面，用于全屏浏览图片和视频
class MediaViewerPage extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final String? heroTag;

  const MediaViewerPage({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return MediaViewer(
      mediaItems: mediaItems,
      initialIndex: initialIndex,
      heroTag: heroTag,
    );
  }
}
