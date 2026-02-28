import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/download_utils.dart';
import 'font_manager.dart';

part 'font_settings_notifier.g.dart';

/// 字体设置状态
class FontSettings {
  /// 当前选中的字体ID
  final String selectedFontId;

  /// 当前选中的字体信息
  final FontInfo? selectedFont;

  /// 字体缓存状态映射（fontId -> isCached）
  final Map<String, bool> cacheStatus;

  /// 正在下载的字体ID
  final String? downloadingFontId;

  /// 下载进度（0.0 - 1.0）
  final double downloadProgress;

  const FontSettings({
    required this.selectedFontId,
    this.selectedFont,
    this.cacheStatus = const {},
    this.downloadingFontId,
    this.downloadProgress = 0.0,
  });

  FontSettings copyWith({
    String? selectedFontId,
    FontInfo? selectedFont,
    Map<String, bool>? cacheStatus,
    String? downloadingFontId,
    double? downloadProgress,
  }) {
    return FontSettings(
      selectedFontId: selectedFontId ?? this.selectedFontId,
      selectedFont: selectedFont ?? this.selectedFont,
      cacheStatus: cacheStatus ?? this.cacheStatus,
      downloadingFontId: downloadingFontId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

/// 字体设置状态管理器
@Riverpod(keepAlive: true)
class FontSettingsNotifier extends _$FontSettingsNotifier {
  @override
  Future<FontSettings> build() async {
    // 预加载所有已缓存的字体
    await FontManager.preloadCachedFonts();

    // 加载当前选中的字体
    final selectedFontId = await FontManager.getSelectedFontId();
    final selectedFont = FontManager.getFontById(selectedFontId);

    // 加载所有字体的缓存状态
    final fontsWithStatus = await FontManager.getFontsWitCacheStatus();
    final cacheStatus = <String, bool>{};
    for (final (font, isCached) in fontsWithStatus) {
      cacheStatus[font.id] = isCached;
    }

    return FontSettings(
      selectedFontId: selectedFontId,
      selectedFont: selectedFont,
      cacheStatus: cacheStatus,
    );
  }

  /// 选择字体
  /// 返回字体族名用于主题设置，如果需要热重启则返回 null
  Future<String?> selectFont(String fontId) async {
    final font = FontManager.getFontById(fontId);
    if (font == null) {
      logger.warning('FontSettingsNotifier: Font not found: $fontId');
      return null;
    }

    // 如果是下载字体，检查是否已缓存并加载
    if (font.type == FontType.downloadedFont) {
      final isCached = await FontManager.isFontCached(font);
      if (!isCached) {
        logger.warning('FontSettingsNotifier: Font not cached: $fontId');
        return null;
      }
      // 加载字体
      await FontManager.registerFont(font);
    }

    await FontManager.setSelectedFontId(fontId);

    state = AsyncData(state.value!.copyWith(
      selectedFontId: fontId,
      selectedFont: font,
    ));

    logger.info('FontSettingsNotifier: Font selected: $fontId');

    // 返回字体族名
    return _getFontFamilyName(font);
  }

  /// 获取字体族名
  String? _getFontFamilyName(FontInfo font) {
    if (font.type == FontType.systemFont) {
      return null; // 系统字体，返回 null 让 Flutter 使用默认
    }
    if (font.type == FontType.appFont) {
      return font.localPath; // 内置字体族名
    }
    // 下载字体，使用字体 ID 作为字体族名
    return font.id;
  }

  /// 下载字体
  Future<bool> downloadFont(String fontId) async {
    final font = FontManager.getFontById(fontId);
    if (font == null || font.type != FontType.downloadedFont) {
      logger.warning('FontSettingsNotifier: Invalid font for download: $fontId');
      return false;
    }

    // 检查是否已缓存
    final isCached = await FontManager.isFontCached(font);
    if (isCached) {
      logger.info('FontSettingsNotifier: Font already cached: $fontId');
      // 更新缓存状态
      _updateCacheStatus(fontId, true);
      return true;
    }

    // 设置下载状态
    state = AsyncData(state.value!.copyWith(
      downloadingFontId: fontId,
      downloadProgress: 0.0,
    ));

    try {
      final result = await FontManager.downloadFont(
        font,
        onProgress: (received, total, progress) {
          state = AsyncData(state.value!.copyWith(
            downloadProgress: progress,
          ));
        },
        onStatusChange: (status, message) {
          logger.debug('FontSettingsNotifier: Download status: $status - $message');
        },
      );

      if (result.status == DownloadStatus.completed) {
        logger.info('FontSettingsNotifier: Font downloaded: $fontId');

        // 更新缓存状态
        _updateCacheStatus(fontId, true);

        // 清除下载状态
        state = AsyncData(state.value!.copyWith(
          downloadingFontId: null,
          downloadProgress: 0.0,
        ));

        return true;
      } else {
        logger.error('FontSettingsNotifier: Font download failed: ${result.errorMessage}');

        // 清除下载状态
        state = AsyncData(state.value!.copyWith(
          downloadingFontId: null,
          downloadProgress: 0.0,
        ));

        return false;
      }
    } catch (e) {
      logger.error('FontSettingsNotifier: Font download error', e);

      // 清除下载状态
      state = AsyncData(state.value!.copyWith(
        downloadingFontId: null,
        downloadProgress: 0.0,
      ));

      return false;
    }
  }

  /// 刷新缓存状态
  Future<void> refreshCacheStatus() async {
    final fontsWithStatus = await FontManager.getFontsWitCacheStatus();
    final cacheStatus = <String, bool>{};
    for (final (font, isCached) in fontsWithStatus) {
      cacheStatus[font.id] = isCached;
    }

    state = AsyncData(state.value!.copyWith(cacheStatus: cacheStatus));
  }

  /// 更新单个字体的缓存状态
  void _updateCacheStatus(String fontId, bool isCached) {
    final newCacheStatus = Map<String, bool>.from(state.value!.cacheStatus);
    newCacheStatus[fontId] = isCached;

    state = AsyncData(state.value!.copyWith(cacheStatus: newCacheStatus));
  }

  /// 删除缓存的字体
  Future<bool> deleteCachedFont(String fontId) async {
    final font = FontManager.getFontById(fontId);
    if (font == null || font.type != FontType.downloadedFont) {
      return false;
    }

    // 如果当前正在使用这个字体，不允许删除
    if (state.value!.selectedFontId == fontId) {
      logger.warning('FontSettingsNotifier: Cannot delete currently selected font');
      return false;
    }

    final success = await FontManager.deleteCachedFont(font);
    if (success) {
      _updateCacheStatus(fontId, false);
    }
    return success;
  }
}

/// 提供当前字体族名的 Provider
@riverpod
String? currentFontFamily(Ref ref) {
  final settingsAsync = ref.watch(fontSettingsProvider);

  return settingsAsync.when(
    data: (settings) {
      final font = settings.selectedFont;
      if (font == null) return 'MiSans'; // 默认字体

      if (font.type == FontType.systemFont) {
        return null; // 使用系统默认字体
      }

      if (font.type == FontType.appFont) {
        return font.localPath; // 返回内置字体族名
      }

      // 下载字体，返回字体 ID 作为字体族名
      return font.id;
    },
    loading: () => 'MiSans',
    error: (error, stackTrace) => 'MiSans',
  );
}
