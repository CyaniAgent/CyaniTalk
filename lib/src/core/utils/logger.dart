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
///
/// 提供多级别日志输出、文件和控制台双输出、日志文件管理等功能。
/// 使用单例模式，确保应用中只有一个日志实例。
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
  ///
  /// 配置日志输出方式，包括控制台输出和文件输出。
  /// 会根据平台选择合适的日志文件存储位置。
  ///
  /// @return 无返回值，初始化完成后日志系统即可使用
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

  /// 为测试环境初始化日志配置
  ///
  /// 仅使用控制台输出，避免依赖 path_provider 等平台相关库。
  void setupForTesting() {
    final consoleOutput = ConsoleOutput();
    _logger = Logger(
      level: Level.error,
      output: consoleOutput,
      printer: SimplePrinter(),
    );
  }

  /// 创建文件输出
  ///
  /// 根据平台创建合适的日志文件输出实例，处理不同平台的文件路径差异。
  ///
  /// @return 返回创建的AppFileOutput实例
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
  ///
  /// 检查日志文件大小，超过限制则清理部分内容，保留最新的日志。
  ///
  /// @param file 要检查的日志文件
  /// @return 无返回值
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
  ///
  /// 动态调整日志输出级别，支持的级别包括：debug、info、warning、error。
  ///
  /// @param level 要设置的日志级别字符串
  /// @return 无返回值
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
  ///
  /// 读取并返回当前日志文件的内容，按行分割。
  ///
  /// @return 返回日志文件的内容列表，每行一条日志
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
  ///
  /// 将当前日志文件复制到指定位置，生成导出文件。
  /// 会根据平台选择合适的导出路径。
  ///
  /// @return 返回导出的日志文件，失败则返回null
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
  ///
  /// 删除当前的日志文件，Android平台会删除debug目录下的所有文件，
  /// 其他平台会删除当前日志文件并重新初始化。
  ///
  /// @return 无返回值
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
  ///
  /// 设置日志文件的最大大小，超过此大小会自动清理部分内容。
  ///
  /// @param maxSizeMB 最大日志文件大小，单位为MB
  /// @return 无返回值
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
  ///
  /// 输出调试级别的日志，通常用于开发和调试过程中的详细信息。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 输出INFO级别的日志
  ///
  /// 输出信息级别的日志，通常用于记录应用程序的正常运行状态和重要事件。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 输出WARNING级别的日志
  ///
  /// 输出警告级别的日志，通常用于记录可能导致问题但不会立即影响应用程序运行的情况。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 输出ERROR级别的日志
  ///
  /// 输出错误级别的日志，通常用于记录应用程序中的错误和异常情况。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志实例，方便使用
final logger = AppLogger();

/// 文件输出类
///
/// 负责将日志输出到文件，支持文件创建、写入和管理。
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

  /// 初始化文件输出
  ///
  /// 打开文件写入流，准备日志输出。
  ///
  /// @return 无返回值
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

  /// 输出日志到文件
  ///
  /// 将日志事件的每一行写入到文件中。
  ///
  /// @param event 日志输出事件，包含要输出的日志行
  /// @return 无返回值
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _sink?.writeln(line);
    }
  }

  /// 销毁文件输出
  ///
  /// 关闭文件写入流，释放资源。
  ///
  /// @return 无返回值
  @override
  Future<void> destroy() async {
    await _sink?.close();
  }
}

/// 多输出类
///
/// 支持将日志输出到多个目标，如同时输出到控制台和文件。
class AppMultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  AppMultiOutput(this.outputs);

  /// 初始化多个输出
  ///
  /// 初始化所有子输出目标。
  ///
  /// @return 无返回值
  @override
  Future<void> init() async {
    for (var output in outputs) {
      await output.init();
    }
  }

  /// 输出日志到多个目标
  ///
  /// 将日志事件输出到所有子输出目标。
  ///
  /// @param event 日志输出事件，包含要输出的日志行
  /// @return 无返回值
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }

  /// 销毁多个输出
  ///
  /// 销毁所有子输出目标，释放资源。
  ///
  /// @return 无返回值
  @override
  Future<void> destroy() async {
    for (var output in outputs) {
      await output.destroy();
    }
  }
}
