import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/utils/cache_manager.dart';

/// Inline audio player widget for Misskey posts
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? fileName;

  const AudioPlayerWidget({super.key, required this.audioUrl, this.fileName});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with AutomaticKeepAliveClientMixin {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _cachedFilePath;

  @override
  bool get wantKeepAlive => _isPlaying || _isLoading;

  Future<void> _initializePlayer() async {
    if (_audioPlayer != null) return;

    _audioPlayer = AudioPlayer();

    _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer!.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        updateKeepAlive();
      }
    });
    
    // 注意：某些版本的audioplayers可能不支持onPlayerError
    // 如果遇到错误，请检查audioplayers版本
    // _audioPlayer!.onPlayerError.listen((error) {
    //   print('Audio player error: $error');
    //   if (mounted) {
    //     setState(() {
    //       _isPlaying = false;
    //       _isLoading = false;
    //     });
    //     updateKeepAlive();
    //   }
    // });
  }

  @override
  void dispose() {
    _audioPlayer?.stop(); // 在销毁前停止播放
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null) {
      await _initializePlayer();
    }

    if (_isPlaying) {
      await _audioPlayer!.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        updateKeepAlive();
      }
    } else {
      // 检查是否已有缓存文件，如果没有则先缓存
      if (_cachedFilePath == null) {
        setState(() {
          _isLoading = true;
        });
        updateKeepAlive();
        try {
          _cachedFilePath = await cacheManager.cacheFile(widget.audioUrl);
        } catch (e) {
          // 使用logger替代print
          debugPrint('Error caching audio file: $e');
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

      // 播放缓存的文件
      if (_cachedFilePath != null) {
        final file = File(_cachedFilePath!);
        if (await file.exists()) {
          await _audioPlayer!.play(DeviceFileSource(_cachedFilePath!));
        } else {
          // 使用logger替代print
          debugPrint('缓存文件不存在: $_cachedFilePath');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            updateKeepAlive();
          }
          return;
        }
      }
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
        updateKeepAlive();
      }
    }
  }

  void _seek(double value) {
    if (_audioPlayer == null) return;
    final position = Duration(seconds: value.toInt());
    _audioPlayer!.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

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
                    color: const Color(0xFF39C5BB),
                  ),
                  onPressed: _togglePlayPause,
                ),
              // 进度滑块
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble().clamp(
                    1.0,
                    double.infinity,
                  ),
                  onChanged: _seek,
                  activeColor: const Color(0xFF39C5BB),
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
