/// 应用常量配置
///
/// 该文件包含应用程序的各种常量配置，如默认值、限制值等
library;

/// 应用常量类
class Constants {
  /// 应用版本号
  static const String appVersion = '1.0.0';

  /// 默认最大日志文件大小（MB）
  static const int defaultMaxLogSize = 5;

  /// 日志目录名称
  static const String logDirectoryName = 'debug';

  /// 默认日志文件前缀
  static const String logFilePrefix = 'CyaniTalk';

  /// 默认日志级别
  static const String defaultLogLevel = 'error';
}
