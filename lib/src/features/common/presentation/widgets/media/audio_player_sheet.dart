import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/shared/widgets/toast_helper.dart';
import 'package:slider_m3e/slider_m3e.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/core/theme/design_tokens.dart';
import '/src/shared/widgets/adaptive_sheet.dart';
import '/src/core/utils/download_utils.dart';
import '/src/features/misskey/application/audio_player_notifier.dart';
import '/src/features/common/presentation/widgets/media/media_item.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

/// Shows a M3E-styled bottom-sheet audio player.
Future<void> showAudioPlayerSheet(
  BuildContext context, {
  required MediaItem mediaItem,
}) async {
  await showAdaptiveSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.m3eShape.bottomSheet),
      ),
    ),
    builder: (_) => _AudioPlayerSheetContent(
      key: ValueKey('audio_${mediaItem.hashCode}'),
      mediaItem: mediaItem,
    ),
  );
}

class _AudioPlayerSheetContent extends ConsumerStatefulWidget {
  final MediaItem mediaItem;

  const _AudioPlayerSheetContent({super.key, required this.mediaItem});

  @override
  ConsumerState<_AudioPlayerSheetContent> createState() =>
      _AudioPlayerSheetContentState();
}

class _AudioPlayerSheetContentState
    extends ConsumerState<_AudioPlayerSheetContent> {
  String get _audioUrl => widget.mediaItem.url;

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withAlpha(80),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final m3eShape = context.m3eShape;

    final audioController =
        ref.watch(audioPlayerControllerProvider(_audioUrl));
    final asyncState = ref.watch(audioPlayerStateProvider(_audioUrl));

    return asyncState.when(
      data: (state) {
        final isPlaying = state.isPlaying;
        final isLoading = state.isLoading;
        final position = state.position;
        final duration =
            state.duration.inSeconds > 0 ? state.duration : const Duration(seconds: 1);
        final sliderValue = duration.inSeconds > 0
            ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
            : 0.0;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(m3eShape.bottomSheet),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildDragHandle(colorScheme),
                  const SizedBox(height: 8),
                  _TopBar(audioUrl: _audioUrl, colorScheme: colorScheme),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _AlbumArt(theme: theme, colorScheme: colorScheme),
                          const SizedBox(height: 28),
                          _TrackInfo(
                            fileName: widget.mediaItem.fileName,
                            theme: theme,
                          ),
                          const SizedBox(height: 32),
                          _M3ESlider(
                            value: sliderValue,
                            isLoading: isLoading,
                            onChanged: (v) {
                              audioController.seek(
                                (v * duration.inSeconds).roundToDouble(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _TimeLabels(
                            position: position,
                            duration: duration,
                            theme: theme,
                          ),
                          const SizedBox(height: 24),
                          _PlaybackControls(
                            audioUrl: _audioUrl,
                            fileName: widget.mediaItem.fileName,
                            isPlaying: isPlaying,
                            isLoading: isLoading,
                            colorScheme: colorScheme,
                            m3eShape: m3eShape,
                            onPlayPause: () => audioController.togglePlayPause(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => _LoadingState(colorScheme: colorScheme, m3eShape: m3eShape),
      error: (error, _) => _ErrorState(
        error: error,
        colorScheme: colorScheme,
        m3eShape: m3eShape,
        onRetry: () => audioController.togglePlayPause(),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String audioUrl;
  final ColorScheme colorScheme;

  const _TopBar({required this.audioUrl, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _TopBarButton(
            icon: Icons.open_in_browser_rounded,
            tooltip: '在浏览器打开',
            colorScheme: colorScheme,
            onPressed: () async {
              final uri = Uri.tryParse(audioUrl);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  const _TopBarButton({
    required this.icon,
    required this.tooltip,
    required this.colorScheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.onSurface.withAlpha(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _AlbumArt({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(180),
        borderRadius: BorderRadius.circular(context.m3eShape.container),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(40),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 80,
          color: colorScheme.onPrimaryContainer.withAlpha(180),
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final String? fileName;
  final ThemeData theme;

  const _TrackInfo({required this.fileName, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          fileName ?? 'Unknown Track',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        Text(
          'Audio File',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _M3ESlider extends StatelessWidget {
  final double value;
  final bool isLoading;
  final ValueChanged<double> onChanged;

  const _M3ESlider({
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: SliderM3E(
        value: value,
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }
}

class _TimeLabels extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ThemeData theme;

  const _TimeLabels({
    required this.position,
    required this.duration,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDuration(position),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            _formatDuration(duration),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }
}

class _PlaybackControls extends StatelessWidget {
  final String audioUrl;
  final String? fileName;
  final bool isPlaying;
  final bool isLoading;
  final ColorScheme colorScheme;
  final M3EShapeTokens m3eShape;
  final VoidCallback onPlayPause;

  const _PlaybackControls({
    required this.audioUrl,
    this.fileName,
    required this.isPlaying,
    required this.isLoading,
    required this.colorScheme,
    required this.m3eShape,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ExtraControlButton(
          icon: Icons.link_rounded,
          tooltip: '复制链接',
          colorScheme: colorScheme,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: audioUrl));
            showToast(title: '链接已复制', type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2));
          },
        ),
        const SizedBox(width: 8),
        _SecondaryControlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: () {},
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 72,
          height: 72,
          child: FilledButton(
            onPressed: isLoading ? null : onPlayPause,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(m3eShape.button),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 36,
                  ),
          ),
        ),
        const SizedBox(width: 24),
        _SecondaryControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: () {},
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        _ExtraControlButton(
          icon: Icons.download_rounded,
          tooltip: '下载',
          colorScheme: colorScheme,
          onPressed: () async {
            final result = await DownloadUtils.downloadFile(
              config: DownloadConfig(
                url: audioUrl,
                fileName: fileName ?? 'audio_${DateTime.now().millisecondsSinceEpoch}',
              ),
            );
            if (context.mounted) {
              showToast(
                title: result.status == DownloadStatus.completed
                    ? '下载完成'
                    : '下载失败: ${result.errorMessage ?? "未知错误"}',
                type: result.status == DownloadStatus.completed
                    ? ToastificationType.success
                    : ToastificationType.error,
                autoCloseDuration: const Duration(seconds: 2),
              );
            }
          },
        ),
      ],
    );
  }
}

class _ExtraControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  const _ExtraControlButton({
    required this.icon,
    required this.tooltip,
    required this.colorScheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final m3eShape = context.m3eShape;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(m3eShape.button),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        padding: EdgeInsets.zero,
      ),
      child: Icon(icon, size: 22),
    );
  }
}

class _SecondaryControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _SecondaryControlButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final m3eShape = context.m3eShape;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(m3eShape.button),
        ),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        padding: EdgeInsets.zero,
      ),
      child: Icon(icon, size: 28),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final ColorScheme colorScheme;
  final M3EShapeTokens m3eShape;

  const _LoadingState({required this.colorScheme, required this.m3eShape});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(m3eShape.bottomSheet),
        ),
      ),
      child: Center(
        child: CyaniLoadingIndicator(color: colorScheme.primary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final ColorScheme colorScheme;
  final M3EShapeTokens m3eShape;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.colorScheme,
    required this.m3eShape,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(m3eShape.bottomSheet),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              '$error',
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(m3eShape.button),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
