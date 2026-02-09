import 'package:flutter/material.dart';
import '../../application/audio_player_notifier.dart';

/// Inline audio player widget for Misskey posts using flutter_soloud
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? fileName;

  const AudioPlayerWidget({super.key, required this.audioUrl, this.fileName});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayerController _controller;
  late AudioPlayerState _state;

  @override
  void initState() {
    super.initState();
    _controller = AudioPlayerController(widget.audioUrl, widget.fileName);
    _state = _controller.state;
    _controller.onStateChanged = (newState) {
      if (mounted) {
        setState(() {
          _state = newState;
        });
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 监听错误状态
    if (_state.error.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _state.error,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name
          if (widget.fileName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.fileName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // Controls
          Row(
            children: [
              // 播放/暂停按钮和加载指示器
              if (_state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    _state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => _controller.togglePlayPause(),
                ),
                // 进度滑块
                Expanded(
                  child: Slider(
                    value: _state.position.inSeconds.toDouble().clamp(0, _state.duration.inSeconds.toDouble()),
                    max: _state.duration.inSeconds.toDouble().clamp(
                      0.001, // 避免 max 为 0
                      double.infinity,
                    ),
                    onChanged: _controller.seek,
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              // 时间显示
              Text(
                '${_formatDuration(_state.position)} / ${_formatDuration(_state.duration)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
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