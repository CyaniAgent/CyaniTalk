import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存管理器，用于处理多媒体文件的缓存
class CacheManager {
  static const String _cacheDirName = 'CyaniTalk Cached Files';
  static const String _prefKey = 'cache_directory_path';

  /// 获取缓存目录
  Future<Directory> getCacheDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_prefKey);
    
    if (savedPath != null && Directory(savedPath).existsSync()) {
      return Directory(savedPath);
    }

    // 如果没有设置自定义路径或路径不存在，使用默认路径
    final appDocDir = await getDownloadsDirectory();
    if (appDocDir != null) {
      final cacheDir = Directory('${appDocDir.path}/$_cacheDirName');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      // 保存路径到首选项
      await prefs.setString(_prefKey, cacheDir.path);
      return cacheDir;
    }

    throw Exception('无法获取缓存目录');
  }

  /// 设置自定义缓存目录
  Future<void> setCustomCacheDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  /// 根据URL获取缓存文件路径
  Future<String> getCacheFilePath(String url) async {
    final cacheDir = await getCacheDirectory();
    final fileName = _getFileNameFromUrl(url);
    return '${cacheDir.path}/$fileName';
  }

  /// 从URL中提取文件名
  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        String fileName = pathSegments.last;
        // 如果文件名不包含扩展名，尝试从Content-Type推断
        if (!fileName.contains('.')) {
          // 这里可以添加基于Content-Type推断扩展名的逻辑
          return '${fileName.hashCode}.cache';
        }
        return fileName;
      }
      return '${url.hashCode}.cache';
    } catch (e) {
      return '${url.hashCode}.cache';
    }
  }

  /// 检查文件是否已缓存且未过期
  Future<bool> isFileCachedAndValid(String url, {Duration maxAge = const Duration(days: 7)}) async {
    try {
      final cacheFilePath = await getCacheFilePath(url);
      final file = File(cacheFilePath);
      
      if (!await file.exists()) {
        return false;
      }

      final lastModified = await file.lastModified();
      final now = DateTime.now();
      
      return now.difference(lastModified) < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// 最大缓存文件大小 (50MB)
  static const int maxCacheFileSize = 50 * 1024 * 1024;

  /// 下载超时时间
  static const Duration downloadTimeout = Duration(seconds: 30);

  /// 缓存文件
  Future<String> cacheFile(String url) async {
    try {
      final cacheFilePath = await getCacheFilePath(url);
      final file = File(cacheFilePath);

      // 检查是否已存在有效缓存
      if (await file.exists()) {
        return cacheFilePath;
      }

      // 下载并缓存文件
      final dio = Dio()..options.connectTimeout = downloadTimeout;
      dio.options.receiveTimeout = downloadTimeout;
      
      // 先获取文件大小信息
      final response = await dio.head(url);
      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        final fileSize = int.tryParse(contentLength);
        if (fileSize != null && fileSize > maxCacheFileSize) {
          throw Exception('文件过大，超过缓存限制');
        }
      }
      
      await dio.download(url, cacheFilePath);
      
      // 下载后再次检查文件大小
      final finalSize = await file.length();
      if (finalSize > maxCacheFileSize) {
        await file.delete();
        throw Exception('文件过大，超过缓存限制');
      }
      
      return cacheFilePath;
    } catch (e) {
      // 如果下载失败，抛出异常
      throw Exception('缓存文件失败: $e');
    }
  }

  /// 获取缓存文件大小
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        // 重新创建目录
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      // 清除缓存失败，忽略错误
    }
  }

  /// 获取缓存文件信息
  Future<List<Map<String, dynamic>>> getCacheFilesInfo() async {
    try {
      final cacheDir = await getCacheDirectory();
      final List<Map<String, dynamic>> filesInfo = [];

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            filesInfo.add({
              'name': entity.path.split('/').last,
              'path': entity.path,
              'size': await entity.length(),
              'modified': stat.modified,
            });
          }
        }
      }

      return filesInfo;
    } catch (e) {
      return [];
    }
  }
}

/// 全局缓存管理器实例
final cacheManager = CacheManager();