import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';

/// 下载状态枚举
enum DownloadStatus {
  pending, // 等待下载
  downloading, // 下载中
  completed, // 下载完成
  failed, // 下载失败
  paused, // 暂停下载
}

/// 下载进度回调
typedef DownloadProgressCallback =
    void Function(int received, int total, double progress);

/// 下载状态回调
typedef DownloadStatusCallback =
    void Function(DownloadStatus status, String? message);

/// 下载配置类
class DownloadConfig {
  /// 文件URL
  final String url;

  /// 保存文件名
  final String fileName;

  /// 保存目录路径
  final String? saveDir;

  /// 最大重试次数
  final int maxRetries;

  /// 重试间隔（毫秒）
  final int retryInterval;

  /// 是否允许覆盖已存在的文件
  final bool allowOverwrite;

  /// 下载速度限制（字节/秒）
  final int? speedLimit;

  /// 下载超时（秒）
  final int timeout;

  /// 头部信息
  final Map<String, dynamic>? headers;

  /// 查询参数
  final Map<String, dynamic>? queryParams;

  const DownloadConfig({
    required this.url,
    required this.fileName,
    this.saveDir,
    this.maxRetries = 3,
    this.retryInterval = 2000,
    this.allowOverwrite = true,
    this.speedLimit,
    this.timeout = 30,
    this.headers,
    this.queryParams,
  });
}

/// 下载结果类
class DownloadResult {
  /// 下载状态
  final DownloadStatus status;

  /// 保存文件路径
  final String? filePath;

  /// 错误信息
  final String? errorMessage;

  /// 下载大小（字节）
  final int? downloadedSize;

  const DownloadResult({
    required this.status,
    this.filePath,
    this.errorMessage,
    this.downloadedSize,
  });
}

/// 通用下载工具类
class DownloadUtils {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// 存储所有下载的CancelToken
  static final List<CancelToken> _cancelTokens = [];

  /// 单文件下载
  static Future<DownloadResult> downloadFile({
    required DownloadConfig config,
    DownloadProgressCallback? onProgress,
    DownloadStatusCallback? onStatusChange,
  }) async {
    // 通知开始下载
    onStatusChange?.call(DownloadStatus.pending, 'download_preparing'.tr());

    // 确定保存目录
    final String saveDirectory =
        config.saveDir ?? await _getDefaultDownloadDir();
    if (saveDirectory.isEmpty) {
      return DownloadResult(
        status: DownloadStatus.failed,
        errorMessage: 'download_no_directory'.tr(),
      );
    }

    // 构建文件路径
    String filePath = '$saveDirectory/${config.fileName}';

    // 检查文件是否已存在
    final File file = File(filePath);
    if (file.existsSync() && !config.allowOverwrite) {
      // 生成新文件名
      final String extension = filePath.split('.').last;
      final String baseName = filePath
          .split('.')
          .take(filePath.split('.').length - 1)
          .join('.');
      int counter = 1;
      while (File('$baseName($counter).$extension').existsSync()) {
        counter++;
      }
      filePath = '$baseName($counter).$extension';
    }

    // 确保目录存在
    final Directory directory = Directory(saveDirectory);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // 开始下载
    onStatusChange?.call(DownloadStatus.downloading, 'download_starting'.tr());

    int retryCount = 0;
    bool downloadSuccess = false;

    // 创建CancelToken并添加到列表
    final cancelToken = CancelToken();
    _cancelTokens.add(cancelToken);

    try {
      while (retryCount <= config.maxRetries && !downloadSuccess) {
        try {
          await _dio.download(
            config.url,
            filePath,
            options: Options(
              headers: config.headers,
              receiveTimeout: Duration(seconds: config.timeout),
            ),
            queryParameters: config.queryParams,
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final double progress = received / total;
                onProgress?.call(received, total, progress);
              }
            },
          );

          downloadSuccess = true;
        } catch (e) {
          retryCount++;
          if (retryCount <= config.maxRetries) {
            onStatusChange?.call(
              DownloadStatus.pending,
              'download_retrying'.tr(
                namedArgs: {
                  'attempt': retryCount.toString(),
                  'max': config.maxRetries.toString(),
                },
              ),
            );
            await Future.delayed(Duration(milliseconds: config.retryInterval));
          } else {
            rethrow;
          }
        }
      }

      // 检查文件是否成功下载
      if (!file.existsSync() || file.lengthSync() == 0) {
        return DownloadResult(
          status: DownloadStatus.failed,
          errorMessage: 'download_empty_file'.tr(),
        );
      }

      onStatusChange?.call(DownloadStatus.completed, 'download_completed'.tr());

      return DownloadResult(
        status: DownloadStatus.completed,
        filePath: filePath,
        downloadedSize: file.lengthSync(),
      );
    } catch (e) {
      onStatusChange?.call(
        DownloadStatus.failed,
        'download_failed'.tr(namedArgs: {'message': e.toString()}),
      );
      return DownloadResult(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      // 从列表中移除cancelToken
      _cancelTokens.remove(cancelToken);
    }
  }

  /// 批量下载文件
  static Future<List<DownloadResult>> downloadFiles({
    required List<DownloadConfig> configs,
    DownloadProgressCallback? onProgress,
    DownloadStatusCallback? onStatusChange,
    Function(int completed, int total)? onBatchProgress,
  }) async {
    final List<DownloadResult> results = [];
    int completedCount = 0;
    final int totalCount = configs.length;

    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];
      onStatusChange?.call(
        DownloadStatus.pending,
        'download_preparing_file'.tr(
          namedArgs: {
            'index': (i + 1).toString(),
            'total': totalCount.toString(),
            'name': config.fileName,
          },
        ),
      );

      final result = await downloadFile(
        config: config,
        onProgress: (received, total, progress) {
          onProgress?.call(received, total, progress);
        },
        onStatusChange: (status, message) {
          onStatusChange?.call(status, message);
        },
      );

      results.add(result);
      completedCount++;
      onBatchProgress?.call(completedCount, totalCount);
    }

    return results;
  }

  /// 获取默认下载目录
  static Future<String> _getDefaultDownloadDir() async {
    late Directory directory;

    try {
      // 使用 path_provider 的 getDownloadsDirectory() 方法获取系统默认下载目录
      // 这样可以尊重用户的系统设置，包括用户可能更改的下载文件夹位置
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        directory = downloadsDir;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      // 尝试获取应用文档目录作为备选
      directory = await getApplicationDocumentsDirectory();
    }

    return directory.path;
  }

  /// 检查下载目录是否可写
  static Future<bool> isDownloadDirWritable(String dirPath) async {
    try {
      final Directory directory = Directory(dirPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // 创建临时文件测试写入权限
      final File testFile = File('$dirPath/.test_write.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取文件大小（格式化）
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    final List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${units[i]}';
  }

  /// 取消所有下载
  static void cancelAllDownloads() {
    // 取消所有下载任务
    for (final token in _cancelTokens) {
      if (!token.isCancelled) {
        token.cancel('Download cancelled by user');
      }
    }
    // 清空列表
    _cancelTokens.clear();
  }
}
