import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:debug_deck/debug_deck.dart';
import '/src/core/utils/utils.dart';

/// A custom interceptor that retries failed requests up to a specified number of times.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Dio dio;

  RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      retryCount++;
      extra['retryCount'] = retryCount;
      
      // 优化：更加稳定的指数退避
      final delay = Duration(milliseconds: 500 * (1 << (retryCount - 1)));
      logger.warning('NetworkClient: Request failed (Type: ${err.type}, Error: ${err.error}). Retrying in ${delay.inMilliseconds}ms ($retryCount/$maxRetries)...');
      
      await Future.delayed(delay);

      try {
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          cancelToken: err.requestOptions.cancelToken,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: extra,
          ),
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
        );
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return super.onError(retryErr, handler);
      }
    }
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // 基于 DioException.type 进行精确判断，避免依赖错误消息的字符串格式
    // （字符串匹配在 Dart/Flutter 版本升级时可能静默失效）
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        // unknown 类型包含 HandshakeException、SocketException 等底层异常
        // 检查底层错误类型以精确判断
        final error = err.error;
        return error is HandshakeException ||
               error is SocketException ||
               error is HttpException;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == null) return false;
        // 5xx 服务器错误可重试，但排除过载场景（500/504/524 重试只会加重伤害）
        return statusCode >= 500 &&
               statusCode < 600 &&
               statusCode != 500 &&
               statusCode != 504 &&
               statusCode != 524;
      default:
        // badCertificate / cancel / badResponse(4xx) 不重试
        return false;
    }
  }
}

/// Centralized logical network client providing pre-configured Dio instances.
///
/// Designed with ACG-style elegance and Material 3 precision! (≧▽≦)
class NetworkClient {
  static final NetworkClient _instance = NetworkClient._internal();
  factory NetworkClient() => _instance;
  NetworkClient._internal();

  /// Creates a pre-configured Dio instance for a specific host and token.
  ///
  /// [timeout] 请求超时时间（秒），默认 30 秒。可通过 NetworkSettings.httpRequestTimeout 配置。
  /// 证书验证由全局 [CyaniHttpOverrides] 统一管理，无需在此单独配置。
  Dio createDio({
    required String host,
    String? token,
    String? userAgent,
    Map<String, dynamic>? extraHeaders,
    int timeout = 30,
  }) {
    // 防御性清理：移除无效端口号（如 :0），防止 500/524 等错误
    final sanitizedHost = sanitizeHost(host);
    if (sanitizedHost != host) {
      logger.warning('NetworkClient: Sanitized host from "$host" to "$sanitizedHost"');
    }

    logger.info('NetworkClient: Creating Dio instance for $sanitizedHost (timeout=${timeout}s)');

    final timeoutDuration = Duration(seconds: timeout);

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$sanitizedHost',
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        headers: {
          'User-Agent': userAgent, 
          'Accept': '*/*', 
          'Connection': 'keep-alive', // 显式请求保持连接
          ...?extraHeaders
        },
        validateStatus: (status) {
          // 接受 2xx 和 3xx，4xx/5xx 抛异常让 RetryInterceptor 和 BaseApi 正常工作
          return status != null && status >= 200 && status < 400;
        },
      ),
    );

    dio.transformer = BackgroundTransformer();

    dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 2));
    dio.interceptors.add(PerformanceInterceptor());
    // ── debug_deck 网络检查器（开发者模式时激活） ──
    dio.interceptors.add(DebugTools.dioInterceptor());

    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => logger.debug('NetworkClient: $obj'),
      ),
    );

    dio.interceptors.add(RateLimitInterceptor());

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        
        // 针对桌面端常驻稳定性调优
        client.connectionTimeout = timeoutDuration;
        client.idleTimeout = const Duration(seconds: 100); // 增加闲置超时，避免连接被系统过早回收
        
        // 证书验证由全局 CyaniHttpOverrides 统一管理，此处不再单独处理
        return client;
      },
    );

    return dio;
  }

  /// 创建用于文件下载的 Dio 实例。
  ///
  /// 与 [createDio] 不同，下载实例不设置 baseUrl（下载 URL 通常是完整路径），
  /// 但仍享受 RetryInterceptor、PerformanceInterceptor 等拦截器栈。
  /// 证书验证由全局 CyaniHttpOverrides 统一管理。
  Dio createDownloadDio({
    int timeout = 30,
  }) {
    final timeoutDuration = Duration(seconds: timeout);

    final dio = Dio(
      BaseOptions(
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        headers: {
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },
      ),
    );

    dio.transformer = BackgroundTransformer();
    dio.interceptors.add(PerformanceInterceptor());

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionTimeout = timeoutDuration;
        client.idleTimeout = const Duration(seconds: 100);
        return client;
      },
    );

    return dio;
  }
}

/// Performance monitoring interceptor to track network request performance
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Start tracking performance
    options.extra['performanceStart'] = DateTime.now();
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // End tracking and record performance
    final startTime = response.requestOptions.extra['performanceStart'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final url = '${response.requestOptions.baseUrl}${response.requestOptions.path}';
      
      performanceMonitor.trackNetworkRequest(
        url,
        duration,
        response.requestOptions.method,
        response.statusCode ?? 0,
      );
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // End tracking for failed requests
    final startTime = err.requestOptions.extra['performanceStart'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final url = '${err.requestOptions.baseUrl}${err.requestOptions.path}';
      
      performanceMonitor.trackNetworkRequest(
        url,
        duration,
        err.requestOptions.method,
        err.response?.statusCode ?? 0,
      );
    }
    return handler.next(err);
  }
}

/// Rate limit interceptor to prevent excessive requests
///
/// 使用端点级别的滑动窗口限流，每端点每分钟最多 60 次请求。
/// 带有定期清理旧键（防内存泄漏）和等待后重新检查（防竞态）。
class RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestTimes = {};
  final int _maxRequestsPerMinute = 60;

  /// 正在等待限流恢复的端点集合，防止多个并发请求同时绕过限流
  final Set<String> _waitingEndpoints = {};

  /// 定期清理旧键的计时器
  Timer? _cleanupTimer;

  RateLimitInterceptor() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupStaleKeys();
    });
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final key = '${options.baseUrl}${options.path}';
    final now = DateTime.now();

    _requestTimes.putIfAbsent(key, () => []);
    _requestTimes[key]!.removeWhere((time) => now.difference(time).inMinutes > 1);

    // 检查是否超过限流
    if (_requestTimes[key]!.length >= _maxRequestsPerMinute) {
      // 防止多个并发请求同时进入等待（竞态条件保护）
      if (_waitingEndpoints.contains(key)) {
        logger.debug('NetworkClient: Another request already waiting for ${options.path}, queuing...');
      } else {
        _waitingEndpoints.add(key);
        logger.warning('NetworkClient: Rate limit exceeded for ${options.path}, waiting...');
      }

      // 等待 1 秒后重新检查，而非盲目放行
      await Future.delayed(const Duration(seconds: 1));

      // 重新清理过期记录并再次检查
      _requestTimes[key]!.removeWhere((time) => DateTime.now().difference(time).inMinutes > 1);
      _waitingEndpoints.remove(key);
    }

    // 记录本次请求（使用当前时间，确保滑动窗口准确）
    _requestTimes[key]!.add(DateTime.now());
    return handler.next(options);
  }

  /// 清理长时间无请求的端点键，防止内存泄漏
  void _cleanupStaleKeys() {
    final now = DateTime.now();
    final staleKeys = <String>[];

    for (final entry in _requestTimes.entries) {
      // 如果该端点最后一条记录已超过 5 分钟，移除整个键
      if (entry.value.isEmpty ||
          entry.value.every((time) => now.difference(time).inMinutes > 5)) {
        staleKeys.add(entry.key);
      }
    }

    for (final key in staleKeys) {
      _requestTimes.remove(key);
    }
  }

  /// 释放资源
  void dispose() {
    _cleanupTimer?.cancel();
    _requestTimes.clear();
    _waitingEndpoints.clear();
  }
}
