import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'media_item.dart';

/// 图片查看器组件
class ImageViewer extends StatelessWidget {
  final MediaItem mediaItem;
  final String? heroTag;

  const ImageViewer({
    super.key,
    required this.mediaItem,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: mediaItem.cachedPath != null
          ? FileImage(File(mediaItem.cachedPath!))
          : NetworkImage(mediaItem.url),
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2.0,
      initialScale: PhotoViewComputedScale.contained,
      basePosition: Alignment.center,
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      heroAttributes: heroTag != null
          ? PhotoViewHeroAttributes(tag: heroTag!)
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
}
