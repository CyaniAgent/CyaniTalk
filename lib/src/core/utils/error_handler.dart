import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
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
          message: 'error_network_timeout'.tr(),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return AppError(
          type: ErrorType.network,
          message: 'error_certificate_error'.tr(),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'error_server_error'.tr();

        switch (statusCode) {
          case 400:
            message = 'error_bad_request'.tr();
            break;
          case 401:
            message = 'error_unauthorized'.tr();
            break;
          case 403:
            message = 'error_forbidden'.tr();
            break;
          case 404:
            message = 'error_not_found'.tr();
            break;
          case 405:
            message = 'error_method_not_allowed'.tr();
            break;
          case 429:
            message = 'error_too_many_requests'.tr();
            break;
          case 500:
            message = 'error_internal_server_error'.tr();
            break;
          case 502:
            message = 'error_bad_gateway'.tr();
            break;
          case 503:
            message = 'error_service_unavailable'.tr();
            break;
          case 504:
            message = 'error_gateway_timeout'.tr();
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
          message: 'error_request_canceled'.tr(),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.network,
          message: 'error_connection_error'.tr(),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.unknown:
        return AppError(
          type: ErrorType.unknown,
          message: 'error_unknown'.tr(),
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
        message: 'error_occurred'.tr(),
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
