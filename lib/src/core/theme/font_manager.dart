import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/download_utils.dart';

/// 字体类型枚举
enum FontType {
  /// 应用内置字体
  appFont,

  /// 系统字体
  systemFont,

  /// 网络下载字体
  downloadedFont,
}

/// 字体信息模型
class FontInfo {
  /// 字体唯一标识符
  final String id;

  /// 字体元数据ID（用于内部索引）
  final int metadataId;

  /// 字体显示名称
  final String displayName;

  /// 字体类型
  final FontType type;

  /// 字体下载URL（仅下载字体需要）
  final String? downloadUrl;

  /// 字体文件名
  final String? fileName;

  /// 字体本地路径（内置字体使用字体族名，下载字体使用文件路径）
  final String? localPath;

  /// 是否需要下载
  bool get needsDownload => type == FontType.downloadedFont && downloadUrl != null;

  const FontInfo({
    required this.id,
    required this.metadataId,
    required this.displayName,
    required this.type,
    this.downloadUrl,
    this.fileName,
    this.localPath,
  });
}

/// 字体管理器
///
/// 负责字体的下载、缓存和管理
class FontManager {
  static const String _prefSelectedFont = 'selected_font_id';

  /// 已注册的字体集合
  static final Set<String> _registeredFonts = {};

  /// 预定义字体列表
  static const List<FontInfo> availableFonts = [
    FontInfo(
      id: 'misans',
      metadataId: 0,
      displayName: 'MiSans (App Font)',
      type: FontType.appFont,
      localPath: 'MiSans',
    ),
    FontInfo(
      id: 'system',
      metadataId: 1,
      displayName: 'System Font',
      type: FontType.systemFont,
      localPath: null,
    ),
    FontInfo(
      id: 'star_rail',
      metadataId: 2,
      displayName: 'Star Rail',
      type: FontType.downloadedFont,
      downloadUrl: 'https://bavoice.imikufans.cn/cyanitalk_data/fonts/StarRailFont.ttf',
      fileName: 'StarRailFont.ttf',
    ),
    FontInfo(
      id: 'gakumas_sans',
      metadataId: 3,
      displayName: 'Gakumas Sans',
      type: FontType.downloadedFont,
      downloadUrl: 'https://bavoice.imikufans.cn/cyanitalk_data/fonts/gakumas-font.ttf',
      fileName: 'gakumas-font.ttf',
    ),
  ];

  /// 获取字体缓存目录
  static Future<String> getFontCacheDir() async {
    late String basePath;

    if (Platform.isWindows) {
      // Windows: {程序路径}\cache\fonts
      final exePath = Platform.resolvedExecutable;
      final exeDir = File(exePath).parent.path;
      basePath = '$exeDir\\cache\\fonts';
    } else if (Platform.isMacOS || Platform.isLinux) {
      // macOS/Linux: {程序路径}/cache/fonts
      final exePath = Platform.resolvedExecutable;
      final exeDir = File(exePath).parent.path;
      basePath = '$exeDir/cache/fonts';
    } else if (Platform.isAndroid) {
      // Android: /storage/emulated/0/Android/data/{应用包名}/cache/fonts
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        basePath = '${extDir.path}/fonts';
      } else {
        // 回退到应用缓存目录
        final cacheDir = await getApplicationCacheDirectory();
        basePath = '${cacheDir.path}/fonts';
      }
    } else {
      // 其他平台使用应用缓存目录
      final cacheDir = await getApplicationCacheDirectory();
      basePath = '${cacheDir.path}/fonts';
    }

    // 确保目录存在
    final dir = Directory(basePath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    return basePath;
  }

  /// 检查字体是否已缓存
  static Future<bool> isFontCached(FontInfo font) async {
    if (font.type != FontType.downloadedFont || font.fileName == null) {
      return true; // 内置字体和系统字体不需要缓存
    }

    final cacheDir = await getFontCacheDir();
    final fontFile = File('$cacheDir${Platform.pathSeparator}${font.fileName}');
    return fontFile.existsSync() && fontFile.lengthSync() > 0;
  }

  /// 获取字体文件路径
  static Future<String?> getFontFilePath(FontInfo font) async {
    if (font.type == FontType.appFont) {
      return font.localPath; // 返回字体族名
    }

    if (font.type == FontType.systemFont) {
      return null; // 系统字体
    }

    if (font.type == FontType.downloadedFont && font.fileName != null) {
      final cacheDir = await getFontCacheDir();
      final fontFile = File('$cacheDir${Platform.pathSeparator}${font.fileName}');
      if (fontFile.existsSync()) {
        return fontFile.path;
      }
    }

    return null;
  }

  /// 注册字体到 Flutter
  static Future<bool> registerFont(FontInfo font) async {
    if (font.type != FontType.downloadedFont || font.fileName == null) {
      return false;
    }

    // 检查是否已注册
    if (_registeredFonts.contains(font.id)) {
      return true;
    }

    final cacheDir = await getFontCacheDir();
    final fontFile = File('$cacheDir${Platform.pathSeparator}${font.fileName}');

    if (!fontFile.existsSync()) {
      logger.warning('FontManager: Font file not found: ${font.fileName}');
      return false;
    }

    try {
      // 读取字体数据
      final fontData = await fontFile.readAsBytes();
      
      // 注册字体家族
      final fontLoader = FontLoader(font.id);
      fontLoader.addFont(Future.value(fontData.buffer.asByteData()));
      await fontLoader.load();
      
      _registeredFonts.add(font.id);
      logger.info('FontManager: Font registered: ${font.displayName}');
      return true;
    } catch (e) {
      logger.error('FontManager: Failed to register font: ${font.displayName}', e);
      return false;
    }
  }

  /// 预加载所有已缓存的下载字体
  static Future<void> preloadCachedFonts() async {
    for (final font in availableFonts) {
      if (font.type == FontType.downloadedFont) {
        final isCached = await isFontCached(font);
        if (isCached) {
          await registerFont(font);
        }
      }
    }
  }

  /// 获取字体的 TextTheme
  static TextTheme? getTextTheme(String fontId, TextTheme baseTheme) {
    if (fontId == 'system' || fontId.isEmpty) {
      return null; // 使用系统默认
    }
    
    if (fontId == 'misans') {
      return baseTheme; // 使用内置 MiSans
    }

    // 检查是否已注册
    if (!_registeredFonts.contains(fontId)) {
      return null;
    }

    // 创建具有新字体的 TextTheme
    try {
      return baseTheme.copyWith(
        displayLarge: baseTheme.displayLarge?.copyWith(fontFamily: fontId),
        displayMedium: baseTheme.displayMedium?.copyWith(fontFamily: fontId),
        displaySmall: baseTheme.displaySmall?.copyWith(fontFamily: fontId),
        headlineLarge: baseTheme.headlineLarge?.copyWith(fontFamily: fontId),
        headlineMedium: baseTheme.headlineMedium?.copyWith(fontFamily: fontId),
        headlineSmall: baseTheme.headlineSmall?.copyWith(fontFamily: fontId),
        titleLarge: baseTheme.titleLarge?.copyWith(fontFamily: fontId),
        titleMedium: baseTheme.titleMedium?.copyWith(fontFamily: fontId),
        titleSmall: baseTheme.titleSmall?.copyWith(fontFamily: fontId),
        bodyLarge: baseTheme.bodyLarge?.copyWith(fontFamily: fontId),
        bodyMedium: baseTheme.bodyMedium?.copyWith(fontFamily: fontId),
        bodySmall: baseTheme.bodySmall?.copyWith(fontFamily: fontId),
        labelLarge: baseTheme.labelLarge?.copyWith(fontFamily: fontId),
        labelMedium: baseTheme.labelMedium?.copyWith(fontFamily: fontId),
        labelSmall: baseTheme.labelSmall?.copyWith(fontFamily: fontId),
      );
    } catch (e) {
      logger.error('FontManager: Failed to get text theme for $fontId', e);
      return null;
    }
  }

  /// 下载字体
  static Future<DownloadResult> downloadFont(
    FontInfo font, {
    DownloadProgressCallback? onProgress,
    DownloadStatusCallback? onStatusChange,
  }) async {
    if (font.type != FontType.downloadedFont || font.downloadUrl == null || font.fileName == null) {
      return const DownloadResult(
        status: DownloadStatus.failed,
        errorMessage: 'Invalid font configuration',
      );
    }

    final cacheDir = await getFontCacheDir();

    final config = DownloadConfig(
      url: font.downloadUrl!,
      fileName: font.fileName!,
      saveDir: cacheDir,
      allowOverwrite: true,
    );

    return DownloadUtils.downloadFile(
      config: config,
      onProgress: onProgress,
      onStatusChange: onStatusChange,
    );
  }

  /// 获取当前选中的字体ID
  static Future<String> getSelectedFontId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefSelectedFont) ?? 'misans'; // 默认使用 MiSans
    } catch (e) {
      logger.error('FontManager: Failed to get selected font ID', e);
      return 'misans';
    }
  }

  /// 设置当前选中的字体
  static Future<void> setSelectedFontId(String fontId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefSelectedFont, fontId);
      logger.info('FontManager: Selected font set to $fontId');
    } catch (e) {
      logger.error('FontManager: Failed to set selected font ID', e);
    }
  }

  /// 根据ID获取字体信息
  static FontInfo? getFontById(String id) {
    try {
      return availableFonts.firstWhere((font) => font.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有字体及其缓存状态
  static Future<List<(FontInfo, bool)>> getFontsWitCacheStatus() async {
    final result = <(FontInfo, bool)>[];

    for (final font in availableFonts) {
      final isCached = await isFontCached(font);
      result.add((font, isCached));
    }

    return result;
  }

  /// 删除缓存的字体
  static Future<bool> deleteCachedFont(FontInfo font) async {
    if (font.type != FontType.downloadedFont || font.fileName == null) {
      return false;
    }

    try {
      final cacheDir = await getFontCacheDir();
      final fontFile = File('$cacheDir${Platform.pathSeparator}${font.fileName}');
      if (fontFile.existsSync()) {
        await fontFile.delete();
        // 从已注册集合中移除
        _registeredFonts.remove(font.id);
        logger.info('FontManager: Deleted cached font: ${font.fileName}');
      }
      return true;
    } catch (e) {
      logger.error('FontManager: Failed to delete cached font', e);
      return false;
    }
  }

  /// 清除字体缓存
  static void clearFontCache() {
    _registeredFonts.clear();
  }
}
