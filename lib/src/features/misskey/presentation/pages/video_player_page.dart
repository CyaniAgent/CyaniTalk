import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen video player with semi-transparent background
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
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
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),
            // Controls overlay
            if (_showControls)
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
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
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
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      // Bottom controls
                      if (_isInitialized)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Progress bar
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Color(0xFF39C5BB),
                                  bufferedColor: Colors.white30,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Time display
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_controller.value.position),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: const TextStyle(color: Colors.white),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
