import 'package:flutter/foundation.dart';
import 'logger.dart';

/// 日志级别枚举
enum LogLevel { debug, info, warning, error }

/// 优化的日志工具类扩展
/// 提供简洁的 API 调用和条件日志记录
extension LoggerExtension on AppLogger {
  /// 记录 API 操作的开始
  void apiStart(String operationName, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final paramStr = params != null ? ': $params' : '';
      info('$operationName: START$paramStr');
    }
  }

  /// 记录 API 操作的成功
  void apiSuccess(String operationName, {dynamic result}) {
    info('$operationName: SUCCESS');
    if (result != null && kDebugMode) {
      debug('$operationName: Result = $result');
    }
  }

  /// 记录 API 操作的失败
  void apiError(String operationName, dynamic error) {
    error('$operationName: FAILED - $error', error);
  }

  /// 批量记录多条信息，避免多次调用
  void multiLog(List<String> messages, {LogLevel level = LogLevel.info}) {
    for (final msg in messages) {
      switch (level) {
        case LogLevel.debug:
          debug(msg);
        case LogLevel.info:
          info(msg);
        case LogLevel.warning:
          warning(msg);
        case LogLevel.error:
          error(msg, null);
      }
    }
  }

  /// 条件日志记录（仅在Debug模式下）
  void debugOnly(String message) {
    if (kDebugMode) {
      debug(message);
    }
  }
}

// 使用示例:
// logger.apiStart('getUserInfo', params: {'userId': '123'});
// logger.apiSuccess('getUserInfo', result: userData);
// logger.apiError('getUserInfo', dioException);
