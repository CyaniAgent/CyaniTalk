import 'dart:io';
import 'package:flutter_soloud/flutter_soloud.dart';
import '/src/core/services/timeline_cache_database.dart';
import '/src/core/utils/logger.dart';

/// 文件元数据服务
///
/// 用于获取音频时长和文件大小，并缓存到本地数据库
class FileMetadataService {
  static final FileMetadataService _instance = FileMetadataService._internal();
  factory FileMetadataService() => _instance;
  FileMetadataService._internal();

  final _database = TimelineCacheDatabase();
  final _soloud = SoLoud.instance;

  /// 获取音频时长（毫秒）
  ///
  /// 优先从缓存获取，缓存未命中时从网络获取并缓存
  Future<int?> getAudioDuration(String fileId, String audioUrl) async {
    try {
      // 1. 先从缓存获取
      final cachedDuration = await _database.getAudioDuration(fileId);
      if (cachedDuration != null) {
        logger.debug('FileMetadataService: Audio duration cached for $fileId: ${cachedDuration}ms');
        return cachedDuration;
      }

      // 2. 从网络获取音频时长
      logger.info('FileMetadataService: Fetching audio duration for $fileId');
      final duration = await _fetchAudioDuration(audioUrl);
      
      if (duration != null) {
        // 3. 缓存到数据库
        await _database.saveAudioDuration(fileId, duration);
        logger.info('FileMetadataService: Audio duration fetched and cached for $fileId: ${duration}ms');
      }
      
      return duration;
    } catch (e) {
      logger.error('FileMetadataService: Error getting audio duration for $fileId', e);
      return null;
    }
  }

  /// 从网络获取音频时长
  Future<int?> _fetchAudioDuration(String audioUrl) async {
    try {
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      
      final source = await _soloud.loadUrl(audioUrl, mode: LoadMode.disk);
      final duration = _soloud.getLength(source);
      
      // 卸载音频资源
      _soloud.disposeSource(source);
      
      return duration.inMilliseconds;
    } catch (e) {
      logger.error('FileMetadataService: Error fetching audio duration from $audioUrl', e);
      return null;
    }
  }

  /// 获取文件大小（字节）
  ///
  /// 优先从缓存获取，缓存未命中时从网络获取并缓存
  Future<int?> getFileSize(String fileId, String fileUrl) async {
    try {
      // 1. 先从缓存获取
      final cachedSize = await _database.getFileSize(fileId);
      if (cachedSize != null) {
        logger.debug('FileMetadataService: File size cached for $fileId: $cachedSize bytes');
        return cachedSize;
      }

      // 2. 从网络获取文件大小
      logger.info('FileMetadataService: Fetching file size for $fileId');
      final size = await _fetchFileSize(fileUrl);
      
      if (size != null) {
        // 3. 缓存到数据库
        await _database.saveFileSize(fileId, size);
        logger.info('FileMetadataService: File size fetched and cached for $fileId: $size bytes');
      }
      
      return size;
    } catch (e) {
      logger.error('FileMetadataService: Error getting file size for $fileId', e);
      return null;
    }
  }

  /// 从网络获取文件大小（通过下载 Raw 数据获取实际大小）
  Future<int?> _fetchFileSize(String fileUrl) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      
      final request = await client.getUrl(Uri.parse(fileUrl));
      final response = await request.close();
      
      // 计算实际下载的数据大小
      int totalBytes = 0;
      await for (final chunk in response) {
        totalBytes += chunk.length;
      }
      client.close();
      
      if (totalBytes > 0) {
        return totalBytes;
      }
      
      return null;
    } catch (e) {
      logger.error('FileMetadataService: Error fetching file size from $fileUrl', e);
      return null;
    }
  }

  /// 格式化音频时长
  ///
  /// @param durationMs 时长（毫秒）
  /// @return 格式化的时长字符串（如 "3:45"）
  static String formatDuration(int? durationMs) {
    if (durationMs == null || durationMs <= 0) return '0:00';
    
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  ///
  /// @param sizeBytes 文件大小（字节）
  /// @return 格式化的文件大小字符串（如 "1.5 MB"）
  static String formatFileSize(int? sizeBytes) {
    if (sizeBytes == null || sizeBytes <= 0) return '0 B';
    
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
