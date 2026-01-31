import 'package:flutter/material.dart';
import '../widgets/retryable_network_image.dart';

/// Fullscreen image viewer with semi-transparent background
class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImageViewerPage({super.key, required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Swipe down to dismiss
          if (details.primaryVelocity! > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Image with zoom/pan
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: RetryableNetworkImage(
                          url: imageUrl,
                          fit: BoxFit.contain,
                          maxHeight: null, // No height restriction in viewer
                        ),
                      )
                    : RetryableNetworkImage(
                        url: imageUrl, 
                        fit: BoxFit.contain,
                        maxHeight: null, // No height restriction in viewer
                      ),
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
