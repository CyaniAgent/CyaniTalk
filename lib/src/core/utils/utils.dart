/// 工具类导出文件
///
/// 该文件导出所有核心工具类，方便在整个项目中导入和使用
/// 作为工具模块的统一入口点。
library;

/// 导出日志工具
export 'logger.dart';

/// 导出缓存管理器
export 'cache_manager.dart';

/// 导出性能监控工具
export 'performance_monitor.dart';

/// 导出数据转换工具
export 'data_conversion.dart';

/// 清理主机地址，移除无效端口号（如 :0）和多余的部分
///
/// 无效端口（端口 0）会导致 HTTP 连接失败（500）或 WebSocket 被拒绝（524）。
String sanitizeHost(String host) {
  String sanitized = host.trim();
  if (sanitized.startsWith('https://')) {
    sanitized = sanitized.substring(8);
  } else if (sanitized.startsWith('http://')) {
    sanitized = sanitized.substring(7);
  }

  // 移除路径部分
  if (sanitized.contains('/')) {
    sanitized = sanitized.split('/').first;
  }

  // 移除可能的查询参数或锚点
  if (sanitized.contains('?')) {
    sanitized = sanitized.split('?').first;
  }
  if (sanitized.contains('#')) {
    sanitized = sanitized.split('#').first;
  }

  // 移除无效的端口号 :0（会导致 524/500 错误）
  if (sanitized.endsWith(':0')) {
    sanitized = sanitized.substring(0, sanitized.length - 2);
  }

  return sanitized;
}
