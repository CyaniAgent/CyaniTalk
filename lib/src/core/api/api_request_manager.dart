import 'dart:async';
import '../utils/logger.dart';

/// API 请求缓存项
class ApiCacheItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration? ttl;

  const ApiCacheItem({required this.data, required this.timestamp, this.ttl});

  /// 检查缓存是否有效
  bool get isValid {
    if (ttl == null) return true;
    return DateTime.now().difference(timestamp) < ttl!;
  }
}

/// API 请求去重项
class ApiRequestItem<T> {
  final Completer<T> completer;
  final DateTime timestamp;

  ApiRequestItem(this.completer) : timestamp = DateTime.now();
}

/// API 请求管理器
class ApiRequestManager {
  /// 单例实例
  static final ApiRequestManager _instance = ApiRequestManager._();
  factory ApiRequestManager() => _instance;
  ApiRequestManager._();

  /// 请求缓存
  final Map<String, ApiCacheItem<dynamic>> _cache = {};

  /// 正在进行的请求
  final Map<String, ApiRequestItem<dynamic>> _pendingRequests = {};

  /// 缓存清理定时器
  Timer? _cacheCleanupTimer;

  /// 初始化
  void initialize() {
    // 启动缓存清理定时器，每5分钟清理一次过期缓存
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupCache();
    });
  }

  /// 生成请求键
  String _generateKey(String endpoint, [Map<String, dynamic>? params]) {
    final paramsString = params != null ? params.toString() : '';
    return '$endpoint:$paramsString';
  }

  /// 执行 API 请求，支持缓存和去重
  Future<T> execute<T>(
    String endpoint,
    Future<T> Function() request, {
    Map<String, dynamic>? params,
    Duration? cacheTtl,
    bool useCache = true,
    bool useDeduplication = true,
  }) async {
    final key = _generateKey(endpoint, params);

    // 检查是否有缓存且缓存有效
    if (useCache) {
      final cachedItem = _cache[key];
      if (cachedItem != null && cachedItem.isValid) {
        logger.debug('ApiRequestManager: Using cached response for $key');
        return cachedItem.data as T;
      }
    }

    // 检查是否有正在进行的相同请求
    if (useDeduplication) {
      final pendingRequest = _pendingRequests[key];
      if (pendingRequest != null) {
        logger.debug('ApiRequestManager: Deduplicating request for $key');
        return pendingRequest.completer.future as Future<T>;
      }
    }

    // 创建新的请求
    final completer = Completer<T>();
    _pendingRequests[key] = ApiRequestItem(completer);

    try {
      logger.debug('ApiRequestManager: Executing request for $key');
      final result = await request();

      // 缓存结果
      if (useCache && cacheTtl != null) {
        _cache[key] = ApiCacheItem(
          data: result,
          timestamp: DateTime.now(),
          ttl: cacheTtl,
        );
        logger.debug(
          'ApiRequestManager: Cached response for $key with TTL $cacheTtl',
        );
      }

      completer.complete(result);
      return result;
    } catch (e) {
      logger.error('ApiRequestManager: Error executing request for $key', e);
      // 这里不直接 rethrow，而是通过 completer.completeError 传递错误
      // 这样可以确保即使请求失败，也能正确清理 pendingRequests
      completer.completeError(e);
      rethrow;
    } finally {
      // 移除正在进行的请求
      _pendingRequests.remove(key);
    }
  }

  /// 清理过期缓存
  void _cleanupCache() {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (!entry.value.isValid) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      logger.debug('ApiRequestManager: Removed expired cache for $key');
    }

    logger.debug(
      'ApiRequestManager: Cache cleanup completed, removed ${keysToRemove.length} items',
    );
  }

  /// 手动清理缓存
  void clearCache([String? endpoint]) {
    if (endpoint != null) {
      // 清理特定端点的缓存
      final keysToRemove = _cache.keys
          .where((key) => key.startsWith(endpoint))
          .toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
      logger.debug(
        'ApiRequestManager: Cleared cache for endpoint $endpoint, removed ${keysToRemove.length} items',
      );
    } else {
      // 清理所有缓存
      final cacheSize = _cache.length;
      _cache.clear();
      logger.debug(
        'ApiRequestManager: Cleared all cache, removed $cacheSize items',
      );
    }
  }

  /// 获取缓存大小
  int get cacheSize => _cache.length;

  /// 获取正在进行的请求数量
  int get pendingRequestsCount => _pendingRequests.length;

  /// 清理资源
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _cache.clear();
    _pendingRequests.clear();
    logger.debug('ApiRequestManager: Disposed, cleared all resources');
  }
}

/// API 请求管理器实例
final apiRequestManager = ApiRequestManager();
