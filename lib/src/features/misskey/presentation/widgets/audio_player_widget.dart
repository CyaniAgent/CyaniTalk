import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../../../../core/utils/cache_manager.dart';

/// Inline audio player widget for Misskey posts using flutter_soloud
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? fileName;

  const AudioPlayerWidget({super.key, required this.audioUrl, this.fileName});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with AutomaticKeepAliveClientMixin {
  AudioSource? _audioSource;
  SoundHandle? _soundHandle;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _cachedFilePath;
  Timer? _positionTimer;

  @override
  bool get wantKeepAlive => _isPlaying || _isLoading;

  @override
  void dispose() {
    _positionTimer?.cancel();
    _stopAndDispose();
    super.dispose();
  }

  Future<void> _stopAndDispose() async {
    if (_soundHandle != null) {
      await SoLoud.instance.stop(_soundHandle!);
    }
    if (_audioSource != null) {
      SoLoud.instance.disposeSource(_audioSource!);
    }
  }

  void _startPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_soundHandle != null && _isPlaying) {
        final pos = SoLoud.instance.getPosition(_soundHandle!);
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      if (_soundHandle != null) {
        SoLoud.instance.setPause(_soundHandle!, true);
        setState(() {
          _isPlaying = false;
        });
        _positionTimer?.cancel();
        updateKeepAlive();
      }
    } else {
      if (_audioSource == null) {
        setState(() {
          _isLoading = true;
        });
        updateKeepAlive();

        try {
          // 确保文件已缓存
          _cachedFilePath ??= await cacheManager.cacheFile(widget.audioUrl);
          final file = File(_cachedFilePath!);
          
          if (await file.exists()) {
            _audioSource = await SoLoud.instance.loadFile(_cachedFilePath!);
            _duration = SoLoud.instance.getLength(_audioSource!);
          } else {
            throw Exception('Cache file not found');
          }
        } catch (e) {
          debugPrint('AudioPlayerWidget: Error loading audio: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            updateKeepAlive();
          }
          return;
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          updateKeepAlive();
        }
      }

      if (_audioSource != null) {
        if (_soundHandle != null && SoLoud.instance.getPause(_soundHandle!)) {
          SoLoud.instance.setPause(_soundHandle!, false); // toggle pause
        } else {
          _soundHandle = await SoLoud.instance.play(_audioSource!);
          
          // Listen for completion (SoLoud doesn't have a direct completion stream easily, 
          // but we can check position vs duration in polling)
        }
        
        setState(() {
          _isPlaying = true;
        });
        _startPositionPolling();
        updateKeepAlive();
      }
    }
  }

  void _seek(double value) {
    if (_soundHandle == null) return;
    final position = Duration(seconds: value.toInt());
    SoLoud.instance.seek(_soundHandle!, position);
    setState(() {
      _position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    // Auto-reset when finished
    if (_isPlaying && _position >= _duration && _duration > Duration.zero) {
      Future.microtask(() {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        _positionTimer?.cancel();
        updateKeepAlive();
      });
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
              if (_isLoading)
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
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _togglePlayPause,
                ),
                // 进度滑块
                Expanded(
                  child: Slider(
                    value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                    max: _duration.inSeconds.toDouble().clamp(
                      0.001, // 避免 max 为 0
                      double.infinity,
                    ),
                    onChanged: _seek,
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              // 时间显示
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
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