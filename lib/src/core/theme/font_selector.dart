import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/presentation/settings/appearance_page.dart';
import 'font_manager.dart';
import 'font_settings_notifier.dart';
import 'font_refresh_notifier.dart';

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
    // 每次打开对话框时刷新缓存状态
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
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: FontManager.availableFonts.length,
              itemBuilder: (context, index) {
                final font = FontManager.availableFonts[index];
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
          );
        },
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 200,
          child: Center(
            child: Text('settings_font_load_error'.tr()),
          ),
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

  Future<void> _handleFontTap(FontInfo font, bool isCached) async {
    if (font.type == FontType.downloadedFont && !isCached) {
      // 需要先下载
      _showDownloadPrompt(font);
      return;
    }

    // 选择字体并获取字体族名
    final fontFamily = await ref.read(fontSettingsProvider.notifier).selectFont(font.id);
    
    if (!mounted) return;
    
    // 字体选择成功（fontFamily 为 null 表示系统字体，也是有效的）
    if (fontFamily != null || font.type == FontType.systemFont) {
      // 同步更新 AppearanceSettings 中的字体设置
      // 对于系统字体，使用特殊标识
      await ref.read(appearanceSettingsProvider.notifier).updateFontFamily(
        font.type == FontType.systemFont ? '' : fontFamily!,
      );
      
      if (!mounted) return;
      
      // 关闭对话框
      Navigator.of(context).pop();
      
      // 直接应用字体更改，无需重启
      _applyFontChange(font.displayName);
    }
  }

  Future<void> _handleDownload(FontInfo font) async {
    final success = await ref.read(fontSettingsProvider.notifier).downloadFont(font.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings_font_downloaded'.tr(namedArgs: {'font': font.displayName})),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings_font_download_failed'.tr(namedArgs: {'font': font.displayName})),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showDownloadPrompt(FontInfo font) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_font_download_title'.tr()),
        content: Text('settings_font_download_prompt'.tr(namedArgs: {'font': font.displayName})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('settings_font_download_cancel'.tr()),
          ),
          FilledButton(
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
    // 触发字体刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 使用字体刷新provider触发全局重建
        ref.read(fontRefreshProvider.notifier).triggerRefresh();
      }
    });
    
    // 延迟一点时间再显示成功提示
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings_font_change_success'.tr(namedArgs: {'font': fontName})),
          ),
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
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const FontListTile({
    super.key,
    required this.font,
    required this.isSelected,
    required this.isCached,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(context),
      title: Text(
        font.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      selected: isSelected,
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
        color: isSelected ? theme.colorScheme.primary : null,
      );
    } else {
      // 下载字体
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

    if (font.type == FontType.appFont) {
      return Text(
        'settings_font_type_app'.tr(),
        style: TextStyle(
          color: theme.colorScheme.outline,
        ),
      );
    } else if (font.type == FontType.systemFont) {
      return Text(
        'settings_font_type_system'.tr(),
        style: TextStyle(
          color: theme.colorScheme.outline,
        ),
      );
    } else {
      // 下载字体
      if (isDownloading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'settings_font_downloading'.tr(),
              style: TextStyle(
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
          style: TextStyle(
            color: theme.colorScheme.secondary,
          ),
        );
      } else {
        return Text(
          'settings_font_need_download'.tr(),
          style: TextStyle(
            color: theme.colorScheme.outline,
          ),
        );
      }
    }
  }

  Widget? _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);

    if (isSelected) {
      return Icon(
        Icons.check_circle,
        color: theme.colorScheme.primary,
      );
    }

    if (font.type == FontType.downloadedFont && !isCached && !isDownloading) {
      return IconButton(
        icon: Icon(
          Icons.download,
          color: theme.colorScheme.primary,
        ),
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
          subtitle: Text(font?.displayName ?? 'MiSans'),
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
        subtitle: Text('MiSans'),
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
