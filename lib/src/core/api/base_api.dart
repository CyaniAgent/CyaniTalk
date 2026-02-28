import 'package:dio/dio.dart';
import '/src/core/api/api_request_manager.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/error_handler.dart';

/// 基础 API 类，用于通用错误处理和响应验证
abstract class BaseApi {
  /// 处理 API 响应，提供更优雅的错误处理和类型安全
  /// 返回 (data, error) 元组，其中 error 为 null 表示成功
  /// 这是 handleResponse 和 handleResponseSafe 的替代方法
  (T?, Exception?) processResponse<T>(
    Response response,
    String operationName, {
    T Function(dynamic)? parser,
  }) {
    // 成功状态码 (2xx)
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      logger.debug('$operationName: 成功 (${response.statusCode})');
      try {
        if (parser != null) {
          final data = parser(response.data);
          return (data, null);
        }
        final data = response.data as T;
        return (data, null);
      } catch (e) {
        final errorMessage = '数据解析失败: ${e.toString()}';
        logger.error('$operationName: $errorMessage');
        return (null, Exception('$operationName $errorMessage'));
      }
    }
    // 客户端错误 (4xx)
    else if (response.statusCode! >= 400 && response.statusCode! < 500) {
      final errorMessage = response.data?['error']?['message'] ?? '客户端错误';
      logger.error(
        '$operationName: 客户端错误 ${response.statusCode}: $errorMessage',
      );
      return (
        null,
        Exception(
          '$operationName 客户端错误: ${response.statusCode}: $errorMessage',
        ),
      );
    }
    // 服务器错误 (5xx)
    else if (response.statusCode! >= 500) {
      logger.error('$operationName: 服务器错误 ${response.statusCode}');
      return (null, Exception('$operationName 服务器错误: ${response.statusCode}'));
    }
    // 其他状态码
    else {
      logger.warning('$operationName: 意外的状态码 ${response.statusCode}');
      return (null, Exception('$operationName 失败: ${response.statusCode}'));
    }
  }

  /// 处理 API 错误，提供一致的日志记录和错误包装
  /// 根据错误类型返回适当的异常
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

  /// 包装 Future 操作，提供一致的错误处理、缓存和去重
  ///
  /// 使用示例:
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
                '$operationName: 重试 (尝试 ${retryCount + 1}/$maxRetries)',
              );
            } else {
              logger.info(
                '$operationName: 开始 (尝试 ${retryCount + 1}/$maxRetries)',
              );
            }
            final response = await apiCall();
            final (data, error) = processResponse<T>(
              response,
              operationName,
              parser: (_) => parser(response),
            );
            if (error != null) {
              throw error;
            }
            if (data == null) {
              throw Exception('$operationName 数据解析失败');
            }
            return data;
          } catch (e) {
            if (e is DioException) {
              // 检查是否是可重试的错误
              if (_isRetryableError(e) && retryCount < maxRetries) {
                retryCount++;
                // 优化：更加积极的指数退避策略
                final delay = retryDelay * (1 << (retryCount - 1));
                logger.warning(
                  '$operationName: 检测到临时错误，${delay.inSeconds}秒后重试 (尝试 $retryCount/$maxRetries): ${e.message}',
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

  /// 类似于 executeApiCall，但返回 (data, error) 元组而不是抛出异常
  /// 当你想在更高层次处理错误时非常有用
  Future<(T?, Exception?)> executeApiCallSafe<T>(
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
                '$operationName: 重试 (尝试 ${retryCount + 1}/$maxRetries)',
              );
            } else {
              logger.info(
                '$operationName: 开始 (尝试 ${retryCount + 1}/$maxRetries)',
              );
            }
            final response = await apiCall();
            final (data, error) = processResponse<T>(
              response,
              operationName,
              parser: (_) => parser(response),
            );
            return (data, error);
          } catch (e) {
            if (e is DioException) {
              // 检查是否是可重试的错误
              if (_isRetryableError(e) && retryCount < maxRetries) {
                retryCount++;
                // 优化：更加积极的指数退避策略
                final delay = retryDelay * (1 << (retryCount - 1));
                logger.warning(
                  '$operationName: 检测到临时错误，${delay.inSeconds}秒后重试 (尝试 $retryCount/$maxRetries): ${e.message}',
                );
                await Future.delayed(delay);
                continue;
              }
            }

            if (e is Exception) {
              return (null, e);
            }
            return (
              null,
              handleError(e, operationName, dioErrorParser: dioErrorParser),
            );
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
  /// 包括超时、连接重置(RST)、握手失败等特殊情况
  bool _isRetryableError(DioException error) {
    // 显式捕获 HandshakeException、Connection closed 和 RST 错误
    final errorStr = error.toString().toLowerCase();
    final isNetworkError =
        errorStr.contains('handshake') ||
        errorStr.contains('terminated') ||
        errorStr.contains('connection closed') ||
        errorStr.contains('reset by peer') || // RST 错误
        errorStr.contains('connection reset'); // 连接重置

    return error.type == DioExceptionType.connectionTimeout || // 连接超时
        error.type == DioExceptionType.sendTimeout || // 发送超时
        error.type == DioExceptionType.receiveTimeout || // 接收超时
        error.type == DioExceptionType.connectionError || // 连接错误
        error.type == DioExceptionType.unknown || // 未知错误
        isNetworkError || // 网络错误
        (error.response?.statusCode != null &&
            (error.response!.statusCode! >= 500 ||
                error.response!.statusCode == 429)); // 500+ 服务器错误或 429 (请求过多)
  }

  /// 类似于 executeApiCall，但用于不返回数据的操作（无返回值操作）
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
            final (_, error) = processResponse<void>(response, operationName);
            if (error != null) {
              throw error;
            }
            return null;
          } catch (e) {
            if (e is DioException) {
              // 检查是否是 400 错误，提供更详细的错误信息
              if (e.response?.statusCode == 400) {
                final errorMessage =
                    e.response?.data?['error']?['message'] ?? 'Bad request';
                logger.error(
                  '$operationName: 400 Bad Request: $errorMessage',
                  e,
                );
                throw Exception('$operationName failed: 400 - $errorMessage');
              }

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

  /// 类似于 executeApiCallVoid，但返回 (void, Exception?) 元组而不是抛出异常
  /// 当你想在更高层次处理错误时非常有用
  Future<(void, Exception?)> executeApiCallSafeVoid(
    String operationName,
    Future<Response> Function() apiCall, {
    Map<String, dynamic>? params,
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
            final (_, error) = processResponse<void>(response, operationName);
            return (null, error);
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

            if (e is Exception) {
              return (null, e);
            }
            return (
              null,
              handleError(e, operationName, dioErrorParser: dioErrorParser),
            );
          }
        }
      },
      params: params,
      useCache: false,
      useDeduplication: useDeduplication,
    );
  }

  /// 从 DioException 中提取错误信息
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
