import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:slider_m3e/slider_m3e.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/performance_monitor.dart';
import 'media_item.dart';

class AudioViewer extends StatefulWidget {
  final MediaItem mediaItem;

  const AudioViewer({super.key, required this.mediaItem});

  @override
  State<AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<AudioViewer> {
  final _soloud = SoLoud.instance;
  AudioSource? _source;
  SoundHandle _handle = const SoundHandle(0);
  Timer? _pollTimer;

  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    if (_handle != const SoundHandle(0)) _soloud.stop(_handle);
    if (_source != null) _soloud.disposeSource(_source!);
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _handle == const SoundHandle(0)) return;
      final isValid = _soloud.getIsValidVoiceHandle(_handle);
      setState(() {
        if (isValid) {
          _position = _soloud.getPosition(_handle);
        } else {
          _isPlaying = false;
          _position = Duration.zero;
          _pollTimer?.cancel();
        }
      });
    });
  }

  void _initializeAudio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final startTime = DateTime.now();
      if (!_soloud.isInitialized) await _soloud.init();
      _source = await _soloud.loadUrl(widget.mediaItem.url, mode: LoadMode.disk);
      _duration = _soloud.getLength(_source!);
      _handle = _soloud.play(_source!);
      _isPlaying = true;
      _isLoading = false;
      if (mounted) setState(() {});

      performanceMonitor.trackMediaLoading(
        widget.mediaItem.url,
        DateTime.now().difference(startTime),
        'audio',
      );

      _startPolling();
    } catch (e) {
      logger.error('Error loading audio from network', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }

    if (!widget.mediaItem.isCached && widget.mediaItem.cachedPath == null) {
      _cacheAudioInBackground();
    }
  }

  void _togglePlayPause() {
    if (_handle == const SoundHandle(0)) return;
    if (_isPlaying) {
      _soloud.pauseSwitch(_handle);
      _isPlaying = false;
      setState(() {});
    } else {
      _soloud.pauseSwitch(_handle);
      _isPlaying = true;
      _startPolling();
      setState(() {});
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _cacheAudioInBackground() async {
    try {
      final cachedPath = await cacheManager.cacheFile(
        widget.mediaItem.url,
        widget.mediaItem.cacheCategory,
      );
      if (mounted) {
        setState(() {
          widget.mediaItem.cachedPath = cachedPath;
          widget.mediaItem.isCached = true;
        });
      }
      logger.debug('Audio cached in background: ${widget.mediaItem.url}');
    } catch (error) {
      logger.error('Error caching audio in background', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem.url.isEmpty) {
      return const Center(child: Text('Invalid audio URL'));
    }

    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(240),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _errorMessage != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '音频加载失败',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _handle = const SoundHandle(0);
                      _source = null;
                      _initializeAudio();
                    },
                    child: const Text('重试'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.music_note, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.mediaItem.fileName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        widget.mediaItem.fileName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: SliderM3E(
                      value: _duration.inMilliseconds > 0
                          ? (_position.inMilliseconds /
                                  _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: _isLoading || _handle == const SoundHandle(0)
                          ? null
                          : (v) {
                              final seekMs =
                                  (_duration.inMilliseconds * v).round();
                              _soloud.seek(
                                  _handle, Duration(milliseconds: seekMs));
                              setState(() {
                                _position = Duration(milliseconds: seekMs);
                              });
                            },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(_position),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          formatDuration(_duration),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? theme.colorScheme.primary.withAlpha(180)
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: theme.colorScheme.onPrimary,
                              size: 32,
                            ),
                            iconSize: 32,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
