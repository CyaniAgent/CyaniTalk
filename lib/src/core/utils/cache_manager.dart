import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';

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
  Future<bool> isFileCachedAndValid(
    String url, {
    Duration maxAge = const Duration(days: 7),
  }) async {
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

      // 处理 SSL/TLS 证书验证 (HandshakeException fix)
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

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

  /// 缓存预热
  ///
  /// 提前缓存可能需要的文件，提升用户体验
  /// [urls] - 要预热的URL列表
  /// [priority] - 预热优先级，默认为中优先级
  Future<void> warmupCache(
    List<String> urls, {
    CachePriority priority = CachePriority.medium,
  }) async {
    logger.info(
      'CacheManager: Starting cache warmup for ${urls.length} items with $priority priority',
    );

    try {
      // 根据优先级确定并发数
      final concurrency = _getConcurrencyForPriority(priority);

      // 分批处理
      final batches = _splitListIntoBatches(urls, concurrency);

      for (final batch in batches) {
        final futures = batch.map((url) async {
          try {
            // 检查是否已经缓存
            if (!await isFileCachedAndValid(url)) {
              await cacheFile(url);
              logger.debug('CacheManager: Warmed up cache for $url');
            }
          } catch (e) {
            logger.warning('CacheManager: Failed to warmup cache for $url: $e');
          }
        });

        await Future.wait(futures);
      }

      logger.info('CacheManager: Cache warmup completed');
    } catch (e) {
      logger.error('CacheManager: Error during cache warmup', e);
    }
  }

  /// 智能预加载
  ///
  /// 根据用户行为和上下文智能预加载可能需要的文件
  /// [contextUrls] - 上下文相关的URL列表
  /// [maxItems] - 最大预加载数量
  Future<void> smartPreload(
    List<String> contextUrls, {
    int maxItems = 5,
  }) async {
    logger.info(
      'CacheManager: Starting smart preload for up to $maxItems items',
    );

    try {
      // 限制预加载数量
      final urlsToPreload = contextUrls.take(maxItems).toList();

      // 按优先级排序（这里可以根据实际情况实现更复杂的排序逻辑）
      // 例如：基于文件大小、访问频率等

      // 执行预加载
      await warmupCache(urlsToPreload, priority: CachePriority.low);

      logger.info(
        'CacheManager: Smart preload completed for ${urlsToPreload.length} items',
      );
    } catch (e) {
      logger.error('CacheManager: Error during smart preload', e);
    }
  }

  /// 批量缓存
  ///
  /// 批量处理多个缓存请求，提高效率
  /// [urls] - 要缓存的URL列表
  /// [onProgress] - 进度回调
  Future<Map<String, String?>> batchCache(
    List<String> urls, {
    void Function(int, int)? onProgress,
  }) async {
    logger.info('CacheManager: Starting batch cache for ${urls.length} items');

    final results = <String, String?>{};
    int completed = 0;

    try {
      for (final url in urls) {
        try {
          final cachedPath = await cacheFile(url);
          results[url] = cachedPath;
        } catch (e) {
          logger.warning('CacheManager: Failed to cache $url: $e');
          results[url] = null;
        } finally {
          completed++;
          onProgress?.call(completed, urls.length);
        }
      }

      logger.info(
        'CacheManager: Batch cache completed, ${results.values.where((v) => v != null).length}/${urls.length} successful',
      );
    } catch (e) {
      logger.error('CacheManager: Error during batch cache', e);
    }

    return results;
  }

  /// 清理过期缓存
  ///
  /// 清理超过指定时间的缓存文件
  /// [maxAge] - 最大缓存时间
  Future<int> cleanupExpiredCache({
    Duration maxAge = const Duration(days: 7),
  }) async {
    logger.info('CacheManager: Starting cleanup of expired cache');

    try {
      final cacheDir = await getCacheDirectory();
      int deletedCount = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            final lastModified = await entity.lastModified();
            if (DateTime.now().difference(lastModified) > maxAge) {
              await entity.delete();
              deletedCount++;
              logger.debug(
                'CacheManager: Deleted expired cache file: ${entity.path}',
              );
            }
          }
        }
      }

      logger.info(
        'CacheManager: Cleanup completed, deleted $deletedCount expired files',
      );
      return deletedCount;
    } catch (e) {
      logger.error('CacheManager: Error during cache cleanup', e);
      return 0;
    }
  }

  /// 根据优先级获取并发数
  int _getConcurrencyForPriority(CachePriority priority) {
    switch (priority) {
      case CachePriority.high:
        return 3;
      case CachePriority.medium:
        return 2;
      case CachePriority.low:
        return 1;
    }
  }

  /// 将列表分割成批次
  List<List<T>> _splitListIntoBatches<T>(List<T> list, int batchSize) {
    final batches = <List<T>>[];
    for (int i = 0; i < list.length; i += batchSize) {
      final end = (i + batchSize < list.length) ? i + batchSize : list.length;
      batches.add(list.sublist(i, end));
    }
    return batches;
  }
}

/// 缓存优先级枚举
enum CachePriority {
  high, // 高优先级，例如用户正在查看的内容
  medium, // 中优先级，例如用户可能很快会查看的内容
  low, // 低优先级，例如后台预加载的内容
}

/// 全局缓存管理器实例
final cacheManager = CacheManager();
