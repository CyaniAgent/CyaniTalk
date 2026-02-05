import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Fullscreen image viewer with semi-transparent background, similar to WeChat/QQ
class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImageViewerPage({super.key, required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo viewer with zoom/pan functionality and hero animation support
          heroTag != null
              ? PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  initialScale: PhotoViewComputedScale.contained,
                  basePosition: Alignment.center,
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  heroAttributes: PhotoViewHeroAttributes(tag: heroTag!),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error_outline, size: 50, color: Colors.white),
                  ),
                )
              : PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  initialScale: PhotoViewComputedScale.contained,
                  basePosition: Alignment.center,
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error_outline, size: 50, color: Colors.white),
                  ),
                ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Double tap to zoom hint (appears briefly)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '双击可放大图片',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
