import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../utils/logger.dart';
import '../utils/performance_monitor.dart';

/// A custom interceptor that retries failed requests up to a specified number of times.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Dio dio;

  RetryInterceptor({required this.dio, this.maxRetries = 5});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      retryCount++;
      extra['retryCount'] = retryCount;
      
      final delay = Duration(milliseconds: 500 * (1 << (retryCount - 1)));
      logger.warning('NetworkClient: Request failed. Retrying in ${delay.inMilliseconds}ms ($retryCount/$maxRetries)...');
      
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
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.badResponse && 
            (err.response?.statusCode == 502 || 
             err.response?.statusCode == 503 || 
             err.response?.statusCode == 504));
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
  /// @param host The hostname for the base URL.
  /// @param token Optional authorization token.
  /// @param userAgent Custom User-Agent string.
  /// @param enableCertificateValidation Whether to enable SSL certificate validation.
  Dio createDio({
    required String host,
    String? token,
    String? userAgent,
    Map<String, dynamic>? extraHeaders,
    bool enableCertificateValidation = true,
  }) {
    logger.info('NetworkClient: Creating Dio instance for $host');

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'User-Agent': userAgent, 'Accept': '*/*', ...?extraHeaders},
      ),
    );

    // Add BackgroundTransformer for isolated JSON decoding (S-rank performance! ✧)
    dio.transformer = BackgroundTransformer();

    // Attach interceptors
    dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 5));
    dio.interceptors.add(PerformanceInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => logger.debug('NetworkClient: $obj'),
      ),
    );

    if (token != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Many APIs (like Misskey) expect 'i' in the body for POST,
            // but we can also set headers if needed.
            // For now, we'll keep the token available for the specific API implementations.
            return handler.next(options);
          },
        ),
      );
    }

    // Add rate limiting interceptor
    dio.interceptors.add(
      RateLimitInterceptor(),
    );

    // Handle SSL/TLS for local/development instances (HandshakeException fix)
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        
        if (!enableCertificateValidation) {
          logger.warning('NetworkClient: SSL certificate validation disabled for $host');
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        }
        
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
class RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestTimes = {};
  final int _maxRequestsPerMinute = 60; // Adjust based on API limits

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final key = '${options.baseUrl}${options.path}';
    final now = DateTime.now();

    // Clean up old requests
    _requestTimes.putIfAbsent(key, () => []);
    _requestTimes[key]?.removeWhere((time) => now.difference(time).inMinutes > 1);

    // Check if we've exceeded the rate limit
    if (_requestTimes[key]!.length >= _maxRequestsPerMinute) {
      logger.warning('NetworkClient: Rate limit exceeded for ${options.path}, waiting...');
      // Wait for 1 second before retrying
      await Future.delayed(const Duration(seconds: 1));
    }

    // Record this request
    _requestTimes[key]?.add(now);
    return handler.next(options);
  }
}
