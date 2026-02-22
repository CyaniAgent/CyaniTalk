import 'package:flutter/material.dart';

/// 文件图标管理器
///
/// 为不同类型的文件提供相应的图标，支持常见文件扩展名
class FileIconManager {
  /// 文件类型到图标的映射
  static final Map<String, IconData> _fileTypeIcons = {
    // 图像文件
    'jpg': Icons.image,
    'jpeg': Icons.image,
    'png': Icons.image,
    'gif': Icons.image,
    'webp': Icons.image,
    'bmp': Icons.image,
    'svg': Icons.image,
    'ico': Icons.image,
    
    // 文档文件
    'doc': Icons.description,
    'docx': Icons.description,
    'pdf': Icons.picture_as_pdf,
    'txt': Icons.text_snippet,
    'rtf': Icons.text_snippet,
    'md': Icons.text_snippet,
    'markdown': Icons.text_snippet,
    'html': Icons.code,
    'htm': Icons.code,
    'css': Icons.code,
    'js': Icons.code,
    'ts': Icons.code,
    'json': Icons.code,
    'xml': Icons.code,
    'yaml': Icons.code,
    'yml': Icons.code,
    'properties': Icons.code,
    
    // 电子表格
    'xls': Icons.table_chart,
    'xlsx': Icons.table_chart,
    'csv': Icons.table_chart,
    'ods': Icons.table_chart,
    
    // 演示文稿
    'ppt': Icons.slideshow,
    'pptx': Icons.slideshow,
    'odp': Icons.slideshow,
    
    // 音频文件
    'mp3': Icons.audiotrack,
    'wav': Icons.audiotrack,
    'ogg': Icons.audiotrack,
    'flac': Icons.audiotrack,
    'aac': Icons.audiotrack,
    'm4a': Icons.audiotrack,
    
    // 视频文件
    'mp4': Icons.movie,
    'avi': Icons.movie,
    'mov': Icons.movie,
    'wmv': Icons.movie,
    'flv': Icons.movie,
    'mkv': Icons.movie,
    'webm': Icons.movie,
    
    // 压缩文件
    'zip': Icons.archive,
    'rar': Icons.archive,
    '7z': Icons.archive,
    'tar': Icons.archive,
    'gz': Icons.archive,
    'bz2': Icons.archive,
    
    // 可执行文件
    'exe': Icons.run_circle,
    'app': Icons.run_circle,
    'dmg': Icons.run_circle,
    'apk': Icons.run_circle,
    'ipa': Icons.run_circle,
    
    // 脚本文件
    'sh': Icons.code,
    'bat': Icons.code,
    'cmd': Icons.code,
    'py': Icons.code,
    'java': Icons.code,
    'c': Icons.code,
    'cpp': Icons.code,
    'h': Icons.code,
    'cs': Icons.code,
    'go': Icons.code,
    'rb': Icons.code,
    'php': Icons.code,
  };

  /// 根据文件扩展名获取图标
  ///
  /// [extension] - 文件扩展名（不包含点号）
  /// [fallback] - 当没有找到对应图标时使用的默认图标
  ///
  /// 返回对应的图标，如果没有找到则返回默认图标
  static IconData getIconForExtension(String extension, {IconData fallback = Icons.insert_drive_file}) {
    final lowerExtension = extension.toLowerCase();
    return _fileTypeIcons.getOrDefault(lowerExtension, fallback);
  }

  /// 根据文件名获取图标
  ///
  /// [fileName] - 文件名
  /// [fallback] - 当没有找到对应图标时使用的默认图标
  ///
  /// 返回对应的图标，如果没有找到则返回默认图标
  static IconData getIconForFileName(String fileName, {IconData fallback = Icons.insert_drive_file}) {
    final extension = _getFileExtension(fileName);
    if (extension.isEmpty) {
      return fallback;
    }
    return getIconForExtension(extension, fallback: fallback);
  }

  /// 从文件名中提取扩展名
  ///
  /// [fileName] - 文件名
  ///
  /// 返回文件扩展名（不包含点号），如果没有扩展名则返回空字符串
  static String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }
}

/// 为Map添加getOrDefault方法的扩展
extension MapExtension<K, V> on Map<K, V> {
  /// 获取指定键的值，如果键不存在则返回默认值
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }
}
