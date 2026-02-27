import 'package:dio/dio.dart';
import './api_request_manager.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// Base API class for common error handling and response validation
abstract class BaseApi {
  /// Handles common API response validation
  /// Throws exception if status code is not 200
  /// Returns data cast to the specified type
  T handleResponse<T>(
    Response response,
    String operationName, {
    T Function(dynamic)? parser,
  }) {
    if (response.statusCode == 200) {
      logger.debug('$operationName: Success');
      if (parser != null) {
        return parser(response.data);
      }
      return response.data as T;
    }
    throw Exception('$operationName failed: ${response.statusCode}');
  }

  /// Handles API errors with consistent logging and error wrapping
  /// Returns appropriate exception based on error type
  Exception handleError(
    dynamic error,
    String operationName, {
    String Function(DioException)? dioErrorParser,
  }) {
    // 使用 ErrorHandler 处理错误
    final appError = ErrorHandler.handleError(error);
    ErrorHandler.logError(operationName, error);

    if (error is DioException && dioErrorParser != null) {
      final message = dioErrorParser(error);
      return Exception('$operationName error: $message');
    }

    return Exception('$operationName error: ${appError.message}');
  }

  /// 初始化 API 请求管理器
  void initialize() {
    apiRequestManager.initialize();
  }

  /// Wraps a Future operation with consistent error handling, caching, and deduplication
  ///
  /// Usage:
  /// ```dart
  /// Future<T> myMethod() => executeApiCall(
  ///   'MyOperation',
  ///   () => _dio.post('/api/endpoint', data: {...}),
  ///   (response) => MyModel.fromJson(response.data),
  ///   params: {'id': 123},
  ///   cacheTtl: Duration(minutes: 5),
  ///   useCache: true,
  /// );
  /// ```
  Future<T> executeApiCall<T>(
    String operationName,
    Future<Response> Function() apiCall,
    T Function(Response) parser, {
    Map<String, dynamic>? params,
    Duration? cacheTtl,
    bool useCache = false,
    bool useDeduplication = true,
    String Function(DioException)? dioErrorParser,
    int maxRetries = 5,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    return apiRequestManager.execute(
      operationName,
      () async {
        int retryCount = 0;

        while (true) {
          try {
            if (retryCount > 0) {
              logger.info(
                '$operationName: Retrying (attempt ${retryCount + 1}/$maxRetries)',
              );
            } else {
              logger.info(
                '$operationName: Starting (attempt ${retryCount + 1}/$maxRetries)',
              );
            }
            final response = await apiCall();
            return handleResponse(
              response,
              operationName,
              parser: (_) => parser(response),
            );
          } catch (e) {
            if (e is DioException) {
              // 检查是否是可重试的错误
              if (_isRetryableError(e) && retryCount < maxRetries) {
                retryCount++;
                // 优化：更加积极的指数退避策略
                final delay = retryDelay * (1 << (retryCount - 1)); 
                logger.warning(
                  '$operationName: Transient error detected, retrying in ${delay.inSeconds}s (attempt $retryCount/$maxRetries): ${e.message}',
                );
                await Future.delayed(delay);
                continue;
              }
            }

            if (e is Exception) rethrow;
            throw handleError(e, operationName, dioErrorParser: dioErrorParser);
          }
        }
      },
      params: params,
      cacheTtl: cacheTtl,
      useCache: useCache,
      useDeduplication: useDeduplication,
    );
  }

  /// 检查错误是否可重试
  bool _isRetryableError(DioException error) {
    // 显式捕获 HandshakeException 和 Connection closed 错误喵！
    final errorStr = error.toString().toLowerCase();
    final isHandshakeError = errorStr.contains('handshake') || 
                             errorStr.contains('terminated') ||
                             errorStr.contains('connection closed');

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown ||
        isHandshakeError || // 关键：包含上述关键字即重试
        (error.response?.statusCode != null &&
            (error.response!.statusCode! >= 500 ||
                error.response!.statusCode ==
                    429)); // 500+ 错误或 429 (Too Many Requests)
  }

  /// Similar to executeApiCall but for operations that don't return data (void operations)
  Future<void> executeApiCallVoid(
    String operationName,
    Future<Response> Function() apiCall, {
    Map<String, dynamic>? params,
    bool useDeduplication = true,
    String Function(DioException)? dioErrorParser,
    int maxRetries = 5, // 统一提升至 5 次重试
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    await apiRequestManager.execute(
      operationName,
      () async {
        int retryCount = 0;

        while (true) {
          try {
            if (retryCount > 0) {
              logger.info(
                '$operationName: Retrying (attempt ${retryCount + 1}/$maxRetries)',
              );
            } else {
              logger.info(
                '$operationName: Starting (attempt ${retryCount + 1}/$maxRetries)',
              );
            }
            final response = await apiCall();
            handleResponse(response, operationName);
            return null;
          } catch (e) {
            if (e is DioException) {
              // 检查是否是可重试的错误
              if (_isRetryableError(e) && retryCount < maxRetries) {
                retryCount++;
                final delay = retryDelay * (1 << (retryCount - 1));
                logger.warning(
                  '$operationName: Transient error detected, retrying in ${delay.inSeconds}s (attempt $retryCount/$maxRetries): ${e.message}',
                );
                await Future.delayed(delay);
                continue;
              }
            }

            if (e is Exception) rethrow;
            throw handleError(e, operationName, dioErrorParser: dioErrorParser);
          }
        }
      },
      params: params,
      useCache: false,
      useDeduplication: useDeduplication,
    );
  }

  /// 清理 API 请求管理器资源
  void dispose() {
    apiRequestManager.dispose();
  }

  /// Extract error message from DioException
  String extractDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 404) {
      return 'Resource not found (404)';
    }
    if (error.response?.statusCode == 401) {
      return 'Unauthorized (401)';
    }
    if (error.response?.statusCode == 403) {
      return 'Forbidden (403)';
    }
    return error.message ?? 'Network error';
  }
}
