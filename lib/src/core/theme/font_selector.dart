import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/shared/widgets/toast_helper.dart';
import '/src/features/profile/presentation/settings/appearance_page.dart';
import 'font_manager.dart';
import 'font_settings_notifier.dart';
import 'font_refresh_notifier.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

/// 字体选择器对话框
class FontSelectorDialog extends ConsumerStatefulWidget {
  const FontSelectorDialog({super.key});

  @override
  ConsumerState<FontSelectorDialog> createState() => _FontSelectorDialogState();
}

class _FontSelectorDialogState extends ConsumerState<FontSelectorDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fontSettingsProvider.notifier).refreshCacheStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(fontSettingsProvider);

    return AlertDialog(
      title: Text('settings_font_selector_title'.tr()),
      contentPadding: const EdgeInsets.only(top: 16, bottom: 0),
      content: settingsAsync.when(
        data: (settings) {
          final fonts = FontManager.getAllFonts();

          return SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fonts.length,
                    itemBuilder: (context, index) {
                      final font = fonts[index];
                      final isSelected = settings.selectedFontId == font.id;
                      final isCached = settings.cacheStatus[font.id] ?? false;
                      final isDownloading = settings.downloadingFontId == font.id;
                      final downloadProgress = settings.downloadProgress;

                      return FontListTile(
                        font: font,
                        isSelected: isSelected,
                        isCached: isCached,
                        isDownloading: isDownloading,
                        downloadProgress: downloadProgress,
                        onTap: () => _handleFontTap(font, isCached),
                        onDownload: () => _handleDownload(font),
                      );
                    },
                  ),
                ),
                _buildAddLocalFontTile(context),
              ],
            ),
          );
        },
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CyaniLoadingIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 200,
          child: Center(child: Text('settings_font_load_error'.tr())),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('settings_font_close'.tr()),
        ),
      ],
    );
  }

  Widget _buildAddLocalFontTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: FilledButton.tonalIcon(
        onPressed: _pickLocalFont,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('从本地添加字体'),
      ),
    );
  }

  Future<void> _pickLocalFont() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      final fontId = await FontManager.registerLocalFont(filePath);
      if (fontId == null) {
        if (mounted) {
          showToast(
            title: '字体加载失败，请确认文件格式为 .ttf 或 .otf',
            type: ToastificationType.error,
          );
        }
        return;
      }

      if (!mounted) return;

      ref.read(fontSettingsProvider.notifier).refreshCacheStatus();

      final fontFamily = await ref
          .read(fontSettingsProvider.notifier)
          .selectFont(fontId);

      if (!mounted) return;

      if (fontFamily != null) {
        await ref
            .read(appearanceSettingsProvider.notifier)
            .updateFontFamily(fontFamily);

        if (!mounted) return;

        Navigator.of(context).pop();
        _applyFontChange(filePath.split(Platform.pathSeparator).last);
      }
    } catch (e) {
      if (mounted) {
        showToast(title: '选择字体文件时出错', type: ToastificationType.error);
      }
    }
  }

  Future<void> _handleFontTap(FontInfo font, bool isCached) async {
    if (font.type == FontType.downloadedFont && !isCached) {
      _showDownloadPrompt(font);
      return;
    }

    final fontFamily = await ref
        .read(fontSettingsProvider.notifier)
        .selectFont(font.id);

    if (!mounted) return;

    if (fontFamily != null || font.type == FontType.systemFont) {
      await ref
          .read(appearanceSettingsProvider.notifier)
          .updateFontFamily(
            font.type == FontType.systemFont ? '' : fontFamily!,
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      _applyFontChange(font.displayName);
    }
  }

  Future<void> _handleDownload(FontInfo font) async {
    final success = await ref
        .read(fontSettingsProvider.notifier)
        .downloadFont(font.id);
    if (success && mounted) {
      showToast(
        title: 'settings_font_downloaded'.tr(
          namedArgs: {'font': font.displayName},
        ),
        type: ToastificationType.success,
      );
    } else if (mounted) {
      showToast(
        title: 'settings_font_download_failed'.tr(
          namedArgs: {'font': font.displayName},
        ),
        type: ToastificationType.error,
      );
    }
  }

  void _showDownloadPrompt(FontInfo font) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_font_download_title'.tr()),
        content: Text(
          'settings_font_download_prompt'.tr(
            namedArgs: {'font': font.displayName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('settings_font_download_cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _handleDownload(font);
            },
            child: Text('settings_font_download_confirm'.tr()),
          ),
        ],
      ),
    );
  }

  void _applyFontChange(String fontName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fontRefreshProvider.notifier).triggerRefresh();
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        showToast(
          title: 'settings_font_change_success'.tr(
            namedArgs: {'font': fontName},
          ),
          type: ToastificationType.success,
        );
      }
    });
  }
}

/// 字体列表项组件
class FontListTile extends StatelessWidget {
  final FontInfo font;
  final bool isSelected;
  final bool isCached;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback? onTap;
  final VoidCallback onDownload;
  final bool isDisabled;
  final String? disabledMessage;

  const FontListTile({
    super.key,
    required this.font,
    required this.isSelected,
    required this.isCached,
    required this.isDownloading,
    required this.downloadProgress,
    this.onTap,
    required this.onDownload,
    this.isDisabled = false,
    this.disabledMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(context),
      title: Text(
        font.displayName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDisabled ? Theme.of(context).colorScheme.outline : null,
        ),
      ),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      selected: isSelected,
      enabled: !isDisabled,
      onTap: isDownloading ? null : onTap,
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final theme = Theme.of(context);

    if (font.type == FontType.appFont) {
      return Icon(
        Icons.font_download,
        color: isSelected ? theme.colorScheme.primary : null,
      );
    } else if (font.type == FontType.systemFont) {
      return Icon(
        Icons.devices,
        color: isSelected
            ? theme.colorScheme.primary
            : isDisabled
            ? theme.colorScheme.outline
            : null,
      );
    } else {
      return Icon(
        Icons.cloud_download_outlined,
        color: isSelected
            ? theme.colorScheme.primary
            : isCached
            ? theme.colorScheme.secondary
            : theme.colorScheme.outline,
      );
    }
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);

    if (isDisabled && disabledMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          disabledMessage!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      );
    }

    if (font.type == FontType.appFont) {
      return Text(
        'settings_font_type_app'.tr(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      );
    } else if (font.type == FontType.systemFont) {
      return Text(
        'settings_font_type_system'.tr(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      );
    } else {
      if (isDownloading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'settings_font_downloading'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: downloadProgress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ],
        );
      } else if (isCached) {
        return Text(
          'settings_font_cached'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        );
      } else {
        return Text(
          'settings_font_need_download'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        );
      }
    }
  }

  Widget? _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);

    if (isDisabled) {
      return Icon(Icons.block, color: theme.colorScheme.outline, size: 20);
    }

    if (isSelected) {
      return Icon(Icons.check_circle, color: theme.colorScheme.primary);
    }

    if (font.type == FontType.downloadedFont && !isCached && !isDownloading) {
      return IconButton(
        icon: Icon(Icons.download, color: theme.colorScheme.primary),
        onPressed: onDownload,
        tooltip: 'settings_font_download'.tr(),
      );
    }

    return null;
  }
}

/// 字体选择器按钮
class FontSelectorButton extends ConsumerWidget {
  const FontSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(fontSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final font = settings.selectedFont;
        return ListTile(
          leading: const Icon(Icons.text_fields),
          title: Text('settings_font_title'.tr()),
          subtitle: Text(font?.displayName ?? 'Linar Sans'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFontSelector(context),
        );
      },
      loading: () => ListTile(
        leading: const Icon(Icons.text_fields),
        title: Text('settings_font_title'.tr()),
        subtitle: const Text('...'),
        onTap: () => _showFontSelector(context),
      ),
      error: (error, stackTrace) => ListTile(
        leading: const Icon(Icons.text_fields),
        title: Text('settings_font_title'.tr()),
        subtitle: const Text('Linar Sans'),
        onTap: () => _showFontSelector(context),
      ),
    );
  }

  void _showFontSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FontSelectorDialog(),
    );
  }
}
