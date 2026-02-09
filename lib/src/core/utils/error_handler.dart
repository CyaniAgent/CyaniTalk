import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// 错误类型枚举
enum ErrorType {
  network, // 网络错误
  server, // 服务器错误
  client, // 客户端错误
  unknown, // 未知错误
}

/// 错误信息类
class AppError {
  final ErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, originalError: $originalError)';
  }
}

/// 错误处理工具类
class ErrorHandler {
  /// 处理 Dio 错误
  static AppError handleDioError(DioException error) {
    logger.error('DioError', error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.network,
          message: '网络超时，请检查网络连接',
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return AppError(
          type: ErrorType.network,
          message: '证书错误，无法建立安全连接',
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = '服务器错误';

        switch (statusCode) {
          case 400:
            message = '请求参数错误';
            break;
          case 401:
            message = '未授权，请重新登录';
            break;
          case 403:
            message = '权限不足，无法访问';
            break;
          case 404:
            message = '请求的资源不存在';
            break;
          case 405:
            message = '请求方法不允许';
            break;
          case 429:
            message = '请求过于频繁，请稍后再试';
            break;
          case 500:
            message = '服务器内部错误';
            break;
          case 502:
            message = '网关错误';
            break;
          case 503:
            message = '服务暂时不可用';
            break;
          case 504:
            message = '网关超时';
            break;
        }

        return AppError(
          type: statusCode! >= 500 ? ErrorType.server : ErrorType.client,
          message: message,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.client,
          message: '请求已取消',
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.network,
          message: '网络连接错误，请检查网络设置',
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.unknown:
        return AppError(
          type: ErrorType.unknown,
          message: '未知错误',
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// 处理通用错误
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    logger.error('ErrorHandler: Unknown error', error);

    if (error is DioException) {
      return handleDioError(error);
    } else if (error is AppError) {
      return error;
    } else if (error is Exception) {
      return AppError(
        type: ErrorType.unknown,
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: '发生未知错误',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 记录错误日志
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      logger.error('$context: Error', error, stackTrace);
    } else {
      // 在生产环境中，只记录关键错误信息
      final appError = handleError(error, stackTrace);
      logger.error('$context: ${appError.type}: ${appError.message}', error);
    }
  }

  /// 格式化错误信息，用于显示给用户
  static String formatErrorForUser(dynamic error) {
    final appError = handleError(error);
    return appError.message;
  }

  /// 检查是否是网络错误
  static bool isNetworkError(dynamic error) {
    final appError = handleError(error);
    return appError.type == ErrorType.network;
  }

  /// 检查是否是服务器错误
  static bool isServerError(dynamic error) {
    final appError = handleError(error);
    return appError.type == ErrorType.server;
  }

  /// 检查是否是客户端错误
  static bool isClientError(dynamic error) {
    final appError = handleError(error);
    return appError.type == ErrorType.client;
  }
}
