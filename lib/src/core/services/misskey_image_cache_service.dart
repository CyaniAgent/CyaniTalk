import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '/src/core/services/misskey_image_cache_database.dart';
import '/src/core/utils/logger.dart';

part 'misskey_image_cache_service.g.dart';

/// Misskey 图片缓存服务
///
/// 结合 SQLite 元数据和本地文件缓存，实现：
/// 1. 图片下载并缓存到本地
/// 2. SQLite 记录元数据（URL、本地路径、关联UID、访问时间等）
/// 3. 优先从本地缓存加载，未命中时下载
class MisskeyImageCacheService {
  static const _uuid = Uuid();
  
  // 共享 Dio 实例，减少资源开销
  static final Dio _dio = Dio();
  
  // 共享数据库实例
  static final MisskeyImageCacheDatabase _db = MisskeyImageCacheDatabase();

  /// 缓存图片并记录元数据
  Future<String?> cacheImage({
    required String imageUrl,
    required ImageCacheType cacheType,
    String? associatedUserId,
    String? associatedNoteId,
    String? associatedHost,
  }) async {
    try {
      // 检查是否已缓存
      final existing = await _db.getCacheRecord(imageUrl);
      if (existing != null && existing.localPath != null) {
        final file = File(existing.localPath!);
        if (await file.exists()) {
          // 异步更新访问统计，不阻塞返回
          _db.updateAccessStats(imageUrl);
          return existing.localPath;
        }
      }

      // 下载图片
      final cacheDir = await _getCacheDirectory(cacheType);
      final fileExtension = _getFileExtension(imageUrl);
      final fileName = '${_uuid.v4()}.$fileExtension';
      final filePath = '$cacheDir/$fileName';

      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      final fileSize = await file.length();

      // 记录元数据
      final record = ImageCacheRecord(
        id: _uuid.v4(),
        imageUrl: imageUrl,
        localPath: filePath,
        cacheType: cacheType,
        associatedUserId: associatedUserId,
        associatedNoteId: associatedNoteId,
        associatedHost: associatedHost,
        cachedAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        accessCount: 1,
        fileSizeBytes: fileSize,
      );
      await _db.upsertCacheRecord(record);

      logger.info(
        'MisskeyImageCacheService: Cached image $imageUrl -> $filePath',
      );
      return filePath;
    } catch (e) {
      logger.error('MisskeyImageCacheService: Failed to cache $imageUrl', e);
      return null;
    }
  }

  /// 获取缓存的本地文件路径（如果存在）
  Future<String?> getCachedPath(String imageUrl) async {
    try {
      final record = await _db.getCacheRecord(imageUrl);
      if (record != null && record.localPath != null) {
        final file = File(record.localPath!);
        if (await file.exists()) {
          // 异步更新访问统计
          _db.updateAccessStats(imageUrl);
          return record.localPath;
        }
      }
      return null;
    } catch (e) {
      logger.error('MisskeyImageCacheService: Error getting cached path', e);
      return null;
    }
  }

  /// 检查图片是否已缓存
  Future<bool> isCached(String imageUrl) async {
    final path = await getCachedPath(imageUrl);
    return path != null;
  }

  /// 预缓存头像（关联用户UID）
  Future<void> prefetchAvatar({
    required String userId,
    required String avatarUrl,
    String? host,
  }) async {
    if (await isCached(avatarUrl)) return;

    await cacheImage(
      imageUrl: avatarUrl,
      cacheType: ImageCacheType.avatar,
      associatedUserId: userId,
      associatedHost: host,
    );
  }

  /// 预缓存帖子图片
  Future<void> prefetchPostImage({
    required String imageUrl,
    required String noteId,
    String? host,
  }) async {
    if (await isCached(imageUrl)) return;

    await cacheImage(
      imageUrl: imageUrl,
      cacheType: ImageCacheType.postImage,
      associatedNoteId: noteId,
      associatedHost: host,
    );
  }

  /// 获取用户头像路径（优先缓存，否则返回原URL）
  Future<String> getAvatarPath({
    required String userId,
    required String avatarUrl,
    String? host,
  }) async {
    final cachedPath = await getCachedPath(avatarUrl);
    if (cachedPath != null) return cachedPath;

    // 未缓存时，后台预取
    prefetchAvatar(userId: userId, avatarUrl: avatarUrl, host: host);
    return avatarUrl;
  }

  /// 获取缓存目录
  Future<String> _getCacheDirectory(ImageCacheType type) async {
    final baseDir = await getApplicationCacheDirectory();
    final typeDir = '${baseDir.path}/misskey_images/${type.name}';
    final dir = Directory(typeDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return typeDir;
  }

  /// 从 URL 提取文件扩展名
  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < path.length - 1) {
        final ext = path.substring(dotIndex + 1).toLowerCase();
        // 过滤掉URL参数
        final cleanExt = ext.split('?').first.split('#').first;
        if (cleanExt.isNotEmpty && cleanExt.length <= 10) {
          return cleanExt;
        }
      }
    } catch (_) {}
    return 'jpg';
  }
}

/// Misskey 图片缓存服务 Provider
@Riverpod(keepAlive: true)
MisskeyImageCacheService misskeyImageCacheService(Ref ref) {
  return MisskeyImageCacheService();
}
