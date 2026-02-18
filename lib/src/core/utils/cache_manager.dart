import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';

/// 缓存类别枚举
///
/// 用于区分不同类型的缓存，以便进行针对性的管理和清理。
enum CacheCategory {
  /// 音频缓存，用于存储音频文件
  audio,

  /// 图片缓存，用于存储图片文件
  image,

  /// 其他缓存，用于存储其他类型的文件
  other,
}

/// 缓存优先级枚举
///
/// 用于标识缓存项的优先级，影响缓存清理的顺序。
enum CachePriority {
  /// 高优先级，例如用户正在查看的内容
  high,

  /// 中优先级，例如用户可能很快会查看的内容
  medium,

  /// 低优先级，例如后台预加载的内容
  low,
}

/// 音频缓存类型枚举
///
/// 用于指定音频文件的缓存策略。
enum AudioCacheType {
  /// 持久化缓存，音频文件会一直保留，不会自动清理
  persistent,

  /// 非持久化缓存，音频文件会根据缓存大小限制自动清理
  temporary,
}

/// 文件锁类，用于同步文件操作
///
/// 确保同一时间只有一个操作可以访问指定的文件或资源，
/// 防止并发访问导致的文件损坏或数据不一致。
class _FileLock {
  /// 存储文件锁的映射，键为文件标识符，值为对应的Completer
  final Map<String, Completer<void>> _locks = {};

  /// 获取文件锁
  ///
  /// 如果锁已存在，会等待其释放后再获取。
  ///
  /// @param key 文件或资源的唯一标识符
  Future<void> lock(String key) async {
    // 如果锁已存在，等待其释放
    while (_locks.containsKey(key)) {
      await _locks[key]!.future;
    }

    // 创建新锁
    _locks[key] = Completer<void>();
  }

  /// 释放文件锁
  ///
  /// @param key 文件或资源的唯一标识符
  void unlock(String key) {
    if (_locks.containsKey(key)) {
      _locks[key]!.complete();
      _locks.remove(key);
    }
  }

  /// 执行带锁的操作
  ///
  /// 在获取锁后执行操作，操作完成后自动释放锁。
  ///
  /// @param key 文件或资源的唯一标识符
  /// @param operation 需要在锁定状态下执行的异步操作
  /// @return 操作的返回值
  Future<T> withLock<T>(String key, Future<T> Function() operation) async {
    await lock(key);
    try {
      return await operation();
    } finally {
      unlock(key);
    }
  }
}

/// 缓存项信息类
///
/// 用于存储单个缓存项的详细信息，包括名称、路径、大小、修改时间等。
class CacheItem {
  /// 缓存项的名称
  final String name;

  /// 缓存项的文件路径
  final String path;

  /// 缓存项的大小（字节）
  final int size;

  /// 缓存项的最后修改时间
  final DateTime modified;

  /// 缓存项的类别
  final CacheCategory category;

  /// 音频缓存类型，仅音频缓存使用
  final AudioCacheType? audioCacheType;

  /// 缓存项是否可以被清理
  final bool canBeCleared;

  /// 创建缓存项信息
  ///
  /// @param name 缓存项的名称
  /// @param path 缓存项的文件路径
  /// @param size 缓存项的大小（字节）
  /// @param modified 缓存项的最后修改时间
  /// @param category 缓存项的类别
  /// @param audioCacheType 音频缓存类型，仅音频缓存使用
  /// @param canBeCleared 缓存项是否可以被清理，默认为true
  CacheItem({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.category,
    this.audioCacheType,
    this.canBeCleared = true,
  });

  /// 将缓存项信息转换为Map
  ///
  /// @return 包含缓存项信息的Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'modified': modified,
      'category': category.toString(),
      'audioCacheType': audioCacheType?.toString(),
      'canBeCleared': canBeCleared,
    };
  }

  /// 从Map创建缓存项信息
  ///
  /// @param map 包含缓存项信息的Map
  /// @return 缓存项信息对象
  factory CacheItem.fromMap(Map<String, dynamic> map) {
    AudioCacheType? audioCacheType;
    if (map['audioCacheType'] != null) {
      try {
        audioCacheType = AudioCacheType.values.firstWhere(
          (e) => e.toString() == map['audioCacheType'],
          orElse: () => AudioCacheType.temporary,
        );
      } catch (e) {
        audioCacheType = null;
      }
    }

    return CacheItem(
      name: map['name'],
      path: map['path'],
      size: map['size'],
      modified: map['modified'],
      category: CacheCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => CacheCategory.other,
      ),
      audioCacheType: audioCacheType,
      canBeCleared: map['canBeCleared'] ?? true,
    );
  }
}

/// 统一缓存管理器，用于处理不同类型的缓存
///
/// 提供了缓存目录管理、缓存大小控制、文件下载与缓存等功能，
/// 支持不同类型缓存的分类管理和自动清理。
class CacheManager {
  /// 缓存目录名称
  static const String _cacheDirName = 'CyaniTalk Cached Files';

  /// 首选项键：缓存目录路径
  static const String _prefKey = 'cache_directory_path';

  /// 首选项键：最大缓存大小
  static const String _maxCacheSizeKey = 'max_cache_size';

  /// 首选项键前缀：类别最大大小
  static const String _categoryMaxSizeKey = 'category_max_size_';

  /// 用于同步文件操作的锁
  final _fileLock = _FileLock();

  /// 默认最大缓存大小 (100MB)
  static const int defaultMaxCacheSize = 100 * 1024 * 1024;

  /// 最大单个缓存文件大小 (50MB)
  static const int maxCacheFileSize = 50 * 1024 * 1024;

  /// 下载超时时间
  static const Duration downloadTimeout = Duration(seconds: 30);

  /// 正在进行的下载任务
  final Map<String, Future<String>> _activeDownloads = {};

  /// 缓存统计信息，用于减少文件系统访问
  final Map<String, int> _cacheSizeCache = {};
  final DateTime _lastCacheSizeUpdate = DateTime.now();
  static const Duration _cacheSizeCacheValidity = Duration(minutes: 5);

  /// 获取缓存目录
  ///
  /// 首先尝试从首选项中获取保存的缓存目录路径，
  /// 如果不存在或路径无效，则使用默认路径（下载目录下的CyaniTalk Cached Files文件夹）。
  ///
  /// @return 缓存目录的Directory对象
  /// @throws Exception 如果无法获取缓存目录
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

  /// 获取指定类别的缓存子目录
  ///
  /// 根据缓存类别获取对应的子目录，如果目录不存在则创建。
  ///
  /// @param category 缓存类别
  /// @return 对应类别的缓存子目录
  Future<Directory> getCategoryCacheDirectory(CacheCategory category) async {
    final cacheDir = await getCacheDirectory();
    final categoryDir = Directory('${cacheDir.path}/${category.name}');
    if (!await categoryDir.exists()) {
      await categoryDir.create(recursive: true);
    }
    return categoryDir;
  }

  /// 设置自定义缓存目录
  ///
  /// 设置用户指定的缓存目录路径，并在路径不存在时创建目录。
  ///
  /// @param path 自定义缓存目录的路径
  Future<void> setCustomCacheDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  /// 获取最大缓存大小
  ///
  /// 从首选项中获取最大缓存大小，如果未设置则返回默认值（100MB）。
  ///
  /// @return 最大缓存大小（字节）
  Future<int> getMaxCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxCacheSizeKey) ?? defaultMaxCacheSize;
  }

  /// 设置最大缓存大小
  ///
  /// 设置缓存的最大大小限制，并在设置后检查并清理超出限制的缓存。
  ///
  /// @param sizeInBytes 最大缓存大小（字节）
  Future<void> setMaxCacheSize(int sizeInBytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxCacheSizeKey, sizeInBytes);

    // 检查并清理超出限制的缓存
    await _ensureCacheSizeLimit();
  }

  /// 获取指定类别的最大缓存大小
  Future<int?> getCategoryMaxSize(CacheCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_categoryMaxSizeKey${category.name}');
  }

  /// 设置指定类别的最大缓存大小
  Future<void> setCategoryMaxSize(
    CacheCategory category,
    int sizeInBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_categoryMaxSizeKey${category.name}', sizeInBytes);

    // 检查并清理该类别超出限制的缓存
    await _ensureCategorySizeLimit(category);
  }

  /// 获取音频缓存类型
  Future<AudioCacheType> getAudioCacheType() async {
    final prefs = await SharedPreferences.getInstance();
    final typeString = prefs.getString('audio_cache_type');
    if (typeString == 'persistent') {
      return AudioCacheType.persistent;
    } else {
      return AudioCacheType.temporary;
    }
  }

  /// 设置音频缓存类型
  Future<void> setAudioCacheType(AudioCacheType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_cache_type', type.name);

    // 如果设置为非持久化，清理临时音频缓存
    if (type == AudioCacheType.temporary) {
      await _cleanupTemporaryAudioCache();
    }
  }

  /// 根据URL和类别获取缓存文件路径
  Future<String> getCacheFilePath(String url, CacheCategory category) async {
    final categoryDir = await getCategoryCacheDirectory(category);
    final fileName = _getFileNameFromUrl(url);
    return '${categoryDir.path}/$fileName';
  }

  /// 从URL中提取文件名
  String _getFileNameFromUrl(String url) {
    try {
      if (url.isEmpty) return 'unknown_${DateTime.now().millisecondsSinceEpoch}.cache';
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (pathSegments.isNotEmpty) {
        String fileName = pathSegments.last;
        // 如果文件名不包含扩展名，尝试从Content-Type推断
        if (!fileName.contains('.')) {
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
    String url,
    CacheCategory category, {
    Duration maxAge = const Duration(days: 7),
  }) async {
    try {
      final cacheFilePath = await getCacheFilePath(url, category);

      // 使用文件锁确保文件操作的原子性
      return await _fileLock.withLock(cacheFilePath, () async {
        final file = File(cacheFilePath);

        if (!await file.exists()) {
          return false;
        }

        final lastModified = await file.lastModified();
        final now = DateTime.now();

        return now.difference(lastModified) < maxAge;
      });
    } catch (e) {
      return false;
    }
  }

  /// 缓存文件
  Future<String> cacheFile(
    String url,
    CacheCategory category, {
    AudioCacheType? audioCacheType,
  }) async {
    // 检查是否已有相同的下载任务正在进行
    if (_activeDownloads.containsKey(url)) {
      logger.debug('CacheManager: Using active download for $url');
      return _activeDownloads[url]!;
    }

    final downloadFuture = _doCacheFile(url, category, audioCacheType);
    _activeDownloads[url] = downloadFuture;

    try {
      final result = await downloadFuture;
      return result;
    } finally {
      _activeDownloads.remove(url);
    }
  }

  Future<String> _doCacheFile(
    String url,
    CacheCategory category,
    AudioCacheType? audioCacheType,
  ) async {
    try {
      final cacheFilePath = await getCacheFilePath(url, category);

      // 使用文件锁确保文件操作的原子性
      return await _fileLock.withLock(cacheFilePath, () async {
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

        // 检查缓存大小限制
        await _ensureCacheSizeLimit();
        await _ensureCategorySizeLimit(category);

        // 清除对应类别的缓存大小缓存和总缓存大小缓存
        _cacheSizeCache.remove('category_${category.name}');
        _cacheSizeCache.remove('total');

        return cacheFilePath;
      });
    } catch (e) {
      // 如果下载失败，抛出异常
      throw Exception('缓存文件失败: $e');
    }
  }

  /// 清理临时音频缓存
  Future<void> _cleanupTemporaryAudioCache() async {
    try {
      final items = await getCategoryCacheItems(CacheCategory.audio);
      for (final item in items) {
        if (item.audioCacheType == AudioCacheType.temporary) {
          await clearCacheItem(item);
        }
      }
      logger.info('CacheManager: Cleaned up temporary audio cache');
    } catch (e) {
      logger.error('CacheManager: Error cleaning up temporary audio cache', e);
    }
  }

  /// 获取总缓存大小
  Future<int> getTotalCacheSize() async {
    try {
      // 检查缓存是否有效
      final now = DateTime.now();
      if (now.difference(_lastCacheSizeUpdate) < _cacheSizeCacheValidity && _cacheSizeCache.containsKey('total')) {
        return _cacheSizeCache['total']!;
      }

      final cacheDir = await getCacheDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      // 更新缓存
      _cacheSizeCache['total'] = totalSize;
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 获取设备存储统计信息 (总空间, 已用空间, 剩余空间)
  /// 根据操作系统逻辑实时监测盘符或分区空间
  Future<Map<String, int>> getDeviceStorageStats() async {
    try {
      if (Platform.isWindows) {
        // Windows: 检查安装所在的盘符 (如 D:\)
        final String drive = Platform.resolvedExecutable.substring(0, 2); // 获取 "C:" 或 "D:"
        final result = await Process.run('powershell', [
          '-Command',
          'Get-CimInstance Win32_LogicalDisk -Filter "DeviceID=\'$drive\'" | Select-Object Size, FreeSpace | ConvertTo-Json'
        ]);
        
        if (result.exitCode == 0) {
          final Map<String, dynamic> data = jsonDecode(result.stdout);
          final int total = data['Size'] ?? 0;
          final int free = data['FreeSpace'] ?? 0;
          return {
            'total': total,
            'available': free,
            'usedByOthers': total - free, // 这里暂存，后面在 UI 层会减去本 App 占用的部分
          };
        }
      } else {
        // macOS, Linux, Android, iOS: 检查目录所在分区
        final dir = await getApplicationDocumentsDirectory();
        final result = await Process.run('df', ['-k', dir.path]);
        
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              final int total = (int.tryParse(parts[1]) ?? 0) * 1024;
              final int available = (int.tryParse(parts[3]) ?? 0) * 1024;
              return {
                'total': total,
                'available': available,
                'usedByOthers': total - available,
              };
            }
          }
        }
      }
    } catch (e) {
      logger.error('CacheManager: Failed to get storage stats', e);
    }
    
    // Fallback: 实在获取不到时返回 0，避免虚假数据
    return {'total': 0, 'available': 0, 'usedByOthers': 0};
  }

  /// 获取本 App 占用的总空间 (应用二进制 + 配置文件 + 缓存)
  Future<int> getAppTotalUsage() async {
    int totalUsage = 0;
    try {
      // 1. 获取安装/执行目录占用 (Desktop)
      final exeDir = Directory(Platform.resolvedExecutable).parent;
      totalUsage += await _getDirectorySize(exeDir);

      // 2. 获取文档目录占用
      final docDir = await getApplicationDocumentsDirectory();
      totalUsage += await _getDirectorySize(docDir);

      // 3. 获取支持目录占用
      final supportDir = await getApplicationSupportDirectory();
      totalUsage += await _getDirectorySize(supportDir);

      // 4. 临时/缓存目录占用 (通常已包含在 getTotalCacheSize 中，但为了严谨单独计算)
      final tempDir = await getTemporaryDirectory();
      totalUsage += await _getDirectorySize(tempDir);
      
    } catch (e) {
      logger.warning('CacheManager: Error calculating app total usage', e);
    }
    return totalUsage;
  }

  /// 递归计算目录大小
  Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (_) {}
    return size;
  }

  /// 获取指定类别的缓存大小
  Future<int> getCategoryCacheSize(CacheCategory category) async {
    try {
      // 检查缓存是否有效
      final cacheKey = 'category_${category.name}';
      final now = DateTime.now();
      if (now.difference(_lastCacheSizeUpdate) < _cacheSizeCacheValidity && _cacheSizeCache.containsKey(cacheKey)) {
        return _cacheSizeCache[cacheKey]!;
      }

      final categoryDir = await getCategoryCacheDirectory(category);
      int totalSize = 0;

      if (await categoryDir.exists()) {
        await for (final entity in categoryDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      // 更新缓存
      _cacheSizeCache[cacheKey] = totalSize;
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 获取所有缓存项信息
  Future<List<CacheItem>> getAllCacheItems() async {
    try {
      final cacheDir = await getCacheDirectory();
      final List<CacheItem> items = [];

      if (await cacheDir.exists()) {
        await for (final categoryEntity in cacheDir.list()) {
          if (categoryEntity is Directory) {
            final categoryName = categoryEntity.path.split('/').last;
            CacheCategory category;

            try {
              category = CacheCategory.values.firstWhere(
                (e) => e.name == categoryName,
              );
            } catch (e) {
              category = CacheCategory.other;
            }

            await for (final fileEntity in categoryEntity.list()) {
              if (fileEntity is File) {
                final stat = await fileEntity.stat();
                items.add(
                  CacheItem(
                    name: fileEntity.path.split('/').last,
                    path: fileEntity.path,
                    size: await fileEntity.length(),
                    modified: stat.modified,
                    category: category,
                    canBeCleared: true,
                  ),
                );
              }
            }
          }
        }
      }

      return items;
    } catch (e) {
      return [];
    }
  }

  /// 获取指定类别的缓存项信息
  Future<List<CacheItem>> getCategoryCacheItems(CacheCategory category) async {
    try {
      final categoryDir = await getCategoryCacheDirectory(category);
      final List<CacheItem> items = [];

      if (await categoryDir.exists()) {
        await for (final entity in categoryDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            items.add(
              CacheItem(
                name: entity.path.split('/').last,
                path: entity.path,
                size: await entity.length(),
                modified: stat.modified,
                category: category,
                canBeCleared: true,
              ),
            );
          }
        }
      }

      return items;
    } catch (e) {
      return [];
    }
  }

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        // 重新创建目录结构
        await cacheDir.create(recursive: true);
        for (final category in CacheCategory.values) {
          await getCategoryCacheDirectory(category);
        }
      }
      // 清除缓存大小缓存
      _cacheSizeCache.clear();
    } catch (e) {
      // 清除缓存失败，忽略错误
    }
  }

  /// 清除指定类别的缓存
  Future<void> clearCategoryCache(CacheCategory category) async {
    try {
      final categoryDir = await getCategoryCacheDirectory(category);
      if (await categoryDir.exists()) {
        await categoryDir.delete(recursive: true);
        // 重新创建目录
        await categoryDir.create(recursive: true);
      }
      // 清除对应类别的缓存大小缓存和总缓存大小缓存
      _cacheSizeCache.remove('category_${category.name}');
      _cacheSizeCache.remove('total');
    } catch (e) {
      // 清除缓存失败，忽略错误
    }
  }

  /// 清除指定的缓存项
  Future<void> clearCacheItem(CacheItem item) async {
    try {
      if (item.canBeCleared) {
        final file = File(item.path);
        if (await file.exists()) {
          await file.delete();
          // 清除对应类别的缓存大小缓存和总缓存大小缓存
          _cacheSizeCache.remove('category_${item.category.name}');
          _cacheSizeCache.remove('total');
        }
      }
    } catch (e) {
      // 清除缓存项失败，忽略错误
    }
  }

  /// 缓存预热
  ///
  /// 提前缓存可能需要的文件，提升用户体验
  /// [urls] - 要预热的URL列表
  /// [category] - 缓存类别
  /// [priority] - 预热优先级，默认为中优先级
  Future<void> warmupCache(
    List<String> urls,
    CacheCategory category, {
    CachePriority priority = CachePriority.medium,
  }) async {
    logger.info(
      'CacheManager: Starting cache warmup for ${urls.length} items in ${category.name} with $priority priority',
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
            if (!await isFileCachedAndValid(url, category)) {
              await cacheFile(url, category);
              logger.debug(
                'CacheManager: Warmed up cache for $url in ${category.name}',
              );
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
  /// [category] - 缓存类别
  /// [maxItems] - 最大预加载数量
  Future<void> smartPreload(
    List<String> contextUrls,
    CacheCategory category, {
    int maxItems = 5,
  }) async {
    logger.info(
      'CacheManager: Starting smart preload for up to $maxItems items in ${category.name}',
    );

    try {
      // 限制预加载数量
      final urlsToPreload = contextUrls.take(maxItems).toList();

      // 执行预加载
      await warmupCache(urlsToPreload, category, priority: CachePriority.low);

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
  /// [category] - 缓存类别
  /// [onProgress] - 进度回调
  Future<Map<String, String?>> batchCache(
    List<String> urls,
    CacheCategory category, {
    void Function(int, int)? onProgress,
  }) async {
    logger.info(
      'CacheManager: Starting batch cache for ${urls.length} items in ${category.name}',
    );

    final results = <String, String?>{};
    int completed = 0;

    try {
      for (final url in urls) {
        try {
          final cachedPath = await cacheFile(url, category);
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
        await for (final categoryEntity in cacheDir.list()) {
          if (categoryEntity is Directory) {
            await for (final fileEntity in categoryEntity.list()) {
              if (fileEntity is File) {
                final lastModified = await fileEntity.lastModified();
                if (DateTime.now().difference(lastModified) > maxAge) {
                  await fileEntity.delete();
                  deletedCount++;
                  logger.debug(
                    'CacheManager: Deleted expired cache file: ${fileEntity.path}',
                  );
                }
              }
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

  /// 确保缓存大小不超过限制
  Future<void> _ensureCacheSizeLimit() async {
    try {
      final maxSize = await getMaxCacheSize();
      final currentSize = await getTotalCacheSize();

      if (currentSize > maxSize) {
        logger.info('CacheManager: Cache size exceeds limit, cleaning up...');

        // 获取所有缓存项并按修改时间排序（最旧的在前）
        final items = await getAllCacheItems();
        items.sort((a, b) => a.modified.compareTo(b.modified));

        int sizeToRemove = currentSize - maxSize;
        int removedSize = 0;

        for (final item in items) {
          if (removedSize >= sizeToRemove) break;

          if (item.canBeCleared) {
            final file = File(item.path);
            if (await file.exists()) {
              final fileSize = await file.length();
              await file.delete();
              removedSize += fileSize;
              logger.debug(
                'CacheManager: Removed old cache file: ${item.name} ($fileSize bytes)',
              );
            }
          }
        }

        logger.info(
          'CacheManager: Cache cleanup completed, removed $removedSize bytes',
        );
        // 清除缓存大小缓存
        _cacheSizeCache.clear();
      }
    } catch (e) {
      logger.error('CacheManager: Error ensuring cache size limit', e);
    }
  }

  /// 确保指定类别的缓存大小不超过限制
  Future<void> _ensureCategorySizeLimit(CacheCategory category) async {
    try {
      final maxSize = await getCategoryMaxSize(category);
      if (maxSize != null) {
        final currentSize = await getCategoryCacheSize(category);

        if (currentSize > maxSize) {
          logger.info(
            'CacheManager: ${category.name} cache size exceeds limit, cleaning up...',
          );

          // 获取该类别所有缓存项并按修改时间排序（最旧的在前）
          final items = await getCategoryCacheItems(category);
          items.sort((a, b) => a.modified.compareTo(b.modified));

          int sizeToRemove = currentSize - maxSize;
          int removedSize = 0;

          for (final item in items) {
            if (removedSize >= sizeToRemove) break;

            if (item.canBeCleared) {
              final file = File(item.path);
              if (await file.exists()) {
                final fileSize = await file.length();
                await file.delete();
                removedSize += fileSize;
                logger.debug(
                  'CacheManager: Removed old ${category.name} cache file: ${item.name} ($fileSize bytes)',
                );
              }
            }
          }

          logger.info(
            'CacheManager: ${category.name} cache cleanup completed, removed $removedSize bytes',
          );
          // 清除对应类别的缓存大小缓存和总缓存大小缓存
          _cacheSizeCache.remove('category_${category.name}');
          _cacheSizeCache.remove('total');
        }
      }
    } catch (e) {
      logger.error('CacheManager: Error ensuring category cache size limit', e);
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

/// 全局缓存管理器实例
final cacheManager = CacheManager();
