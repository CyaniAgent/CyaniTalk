/// 日志工具类，负责应用中的日志输出和管理
///
/// 该类提供：
/// 1. 不同级别的日志输出（DEBUG, INFO, WARNING, ERROR）
/// 2. 控制台和文件双输出
/// 3. 动态日志级别调整
/// 4. 日志文件管理（大小限制、清理等）
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../config/constants.dart';

/// 日志工具类，管理应用中的所有日志输出
class AppLogger {
  /// 单例实例
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// 日志实例
  late Logger _logger;

  /// 文件输出实例
  late final AppFileOutput _fileOutput;

  /// 当前日志级别
  Level _currentLevel = Level.error;

  /// 日志文件路径
  String? _logFilePath;

  /// 初始化日志配置
  Future<void> initialize() async {

    // 创建控制台输出
    final consoleOutput = ConsoleOutput();

    // 创建文件输出
    _fileOutput = await _createFileOutput();

    // 初始化日志器
    _logger = Logger(
      level: _currentLevel, // 初始日志级别
      output: AppMultiOutput([consoleOutput, _fileOutput]),
      printer: SimplePrinter(),
    );
  }

  /// 创建文件输出
  Future<AppFileOutput> _createFileOutput() async {
    try {
      String path;
      if (Platform.isAndroid) {
        // Android 平台：动态获取外部存储目录
        final directory = await getExternalStorageDirectory();
        if (directory == null) throw Exception('无法获取外部存储目录');

        final now = DateTime.now();
        final dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final timeStr =
            "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";

        final debugDir = Directory(
          '${directory.path}/${Constants.logDirectoryName}',
        );
        if (!debugDir.existsSync()) {
          debugDir.createSync(recursive: true);
        }
        path =
            '${debugDir.path}/${Constants.logFilePrefix}_${dateStr}_$timeStr.txt';
      } else {
        // 其他平台：保持原样，使用文档目录
        final directory = await getApplicationDocumentsDirectory();
        final debugDir = Directory(
          '${directory.path}/${Constants.logDirectoryName}',
        );
        if (!debugDir.existsSync()) {
          debugDir.createSync(recursive: true);
        }
        final now = DateTime.now();
        final dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        path = '${debugDir.path}/${Constants.logFilePrefix}_$dateStr.txt';
      }

      _logFilePath = path;
      final file = File(_logFilePath!);

      // 确保文件存在
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      // 检查文件大小，超过限制则清理（仅针对非 Android 或固定文件名的平台）
      if (!Platform.isAndroid) {
        await _checkAndCleanLogFile(file);
      }

      return AppFileOutput(
        file: file,
        overrideExisting: false,
        mode: FileMode.append,
      );
    } catch (e) {
      // 如果文件创建失败，返回本地控制台输出
      // 使用调试输出，避免在生产代码中使用print
      debugPrint('AppLogger Error: Failed to create file output: $e');
      final defaultPath = './${Constants.logFilePrefix}_logs.txt';
      _logFilePath = defaultPath;
      return AppFileOutput(
        file: File(defaultPath),
        overrideExisting: false,
        mode: FileMode.append,
      );
    }
  }

  /// 检查并清理日志文件
  Future<void> _checkAndCleanLogFile(File file) async {
    try {
      final stat = await file.stat();
      final maxSize = Constants.defaultMaxLogSize * 1024 * 1024; // MB to bytes

      if (stat.size > maxSize) {
        // 超过限制，保留最后50%内容
        final lines = await file.readAsLines();
        final keepLines = (lines.length * 0.5).round();
        final newContent = lines.skip(lines.length - keepLines).join('\n');
        await file.writeAsString(newContent);
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 设置日志级别
  void setLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        _currentLevel = Level.debug;
        break;
      case 'info':
        _currentLevel = Level.info;
        break;
      case 'warning':
      case 'warn':
        _currentLevel = Level.warning;
        break;
      case 'error':
        _currentLevel = Level.error;
        break;
      default:
        _currentLevel = Level.error;
    }

    // 创建控制台输出
    final consoleOutput = ConsoleOutput();

    // 重新创建日志器以更新级别
    _logger = Logger(
      level: _currentLevel,
      output: AppMultiOutput([consoleOutput, _fileOutput]),
      printer: SimplePrinter(),
    );
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFilePath;

  /// 查看日志内容
  Future<List<String>> viewLogs() async {
    try {
      if (_logFilePath == null) await initialize();
      final file = File(_logFilePath!);
      if (file.existsSync()) {
        return file.readAsLines();
      }
    } catch (e) {
      // 忽略错误
    }
    return [];
  }

  /// 导出日志
  Future<File?> exportLogs() async {
    try {
      if (_logFilePath == null) await initialize();
      final sourceFile = File(_logFilePath!);
      if (sourceFile.existsSync()) {
        String exportPath;
        if (Platform.isAndroid) {
          // Android 平台：导出到外部存储的 debug 目录
          final directory = await getExternalStorageDirectory();
          if (directory == null) throw Exception('无法获取外部存储目录');

          final now = DateTime.now();
          final timestamp =
              "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

          final debugDir = Directory(
            '${directory.path}/${Constants.logDirectoryName}',
          );
          if (!debugDir.existsSync()) {
            debugDir.createSync(recursive: true);
          }
          exportPath =
              '${debugDir.path}/${Constants.logFilePrefix}_export_$timestamp.txt';
        } else {
          // 其他平台：保持原样，使用文档目录
          final directory = await getApplicationDocumentsDirectory();
          final debugDir = Directory(
            '${directory.path}/${Constants.logDirectoryName}',
          );
          if (!debugDir.existsSync()) {
            debugDir.createSync(recursive: true);
          }
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          exportPath =
              '${debugDir.path}/${Constants.logFilePrefix}_export_$timestamp.txt';
        }

        final exportFile = File(exportPath);
        // 复制文件
        await sourceFile.copy(exportPath);
        return exportFile;
      }
    } catch (e) {
      // 忽略错误
    }
    return null;
  }

  /// 删除日志
  Future<void> deleteLogs() async {
    try {
      if (_logFilePath == null) await initialize();

      if (Platform.isAndroid) {
        // Android 平台：删除 debug 目录下的所有文件
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final debugDir = Directory(
            '${directory.path}/${Constants.logDirectoryName}',
          );
          if (debugDir.existsSync()) {
            final files = debugDir.listSync();
            for (final file in files) {
              if (file is File) {
                await file.delete();
              }
            }
          }
        }
      } else {
        // 其他平台：清空当前日志文件
        final directory = await getApplicationDocumentsDirectory();
        final debugDir = Directory(
          '${directory.path}/${Constants.logDirectoryName}',
        );
        if (debugDir.existsSync()) {
          final files = debugDir.listSync();
          for (final file in files) {
            if (file is File) {
              await file.delete();
            }
          }
        }
      }

      // 重新初始化以创建新的日志文件
      await initialize();
    } catch (e) {
      // 忽略错误
    }
  }

  /// 设置最大日志大小
  Future<void> setMaxLogSize(int maxSizeMB) async {
    try {
      if (_logFilePath == null) await initialize();
      final file = File(_logFilePath!);
      if (file.existsSync()) {
        final maxSize = maxSizeMB * 1024 * 1024; // MB to bytes
        final stat = await file.stat();
        if (stat.size > maxSize) {
          await _checkAndCleanLogFile(file);
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 输出DEBUG级别的日志
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 输出INFO级别的日志
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 输出WARNING级别的日志
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 输出ERROR级别的日志
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志实例，方便使用
final logger = AppLogger();

/// 文件输出类
class AppFileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final FileMode mode;
  IOSink? _sink;

  AppFileOutput({
    required this.file,
    this.overrideExisting = false,
    this.mode = FileMode.write,
  });

  @override
  Future<void> init() async {
    if (_sink != null) return;
    try {
      if (overrideExisting) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      file.createSync(recursive: true);
      _sink = file.openWrite(mode: mode);
    } catch (e) {
      // 使用调试输出，避免在生产代码中使用print
      debugPrint('AppFileOutput Error: Failed to init sink: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _sink?.writeln(line);
    }
  }

  @override
  Future<void> destroy() async {
    await _sink?.close();
  }
}

/// 多输出类
class AppMultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  AppMultiOutput(this.outputs);

  @override
  Future<void> init() async {
    for (var output in outputs) {
      await output.init();
    }
  }

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }

  @override
  Future<void> destroy() async {
    for (var output in outputs) {
      await output.destroy();
    }
  }
}
