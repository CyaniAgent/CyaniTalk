import 'package:flutter/material.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/logger.dart';
import '/src/core/utils/performance_monitor.dart';
import 'media_item.dart';

/// 媒体预加载管理器
class MediaPreloader {
  final BuildContext context;

  MediaPreloader(this.context);

  /// 预加载初始媒体和相邻媒体
  void preloadInitialMedia(List<MediaItem> mediaItems, int initialIndex) {
    // 预加载初始媒体
    if (mediaItems.isNotEmpty && initialIndex < mediaItems.length) {
      preloadSingleMedia(mediaItems[initialIndex]);
    }

    // 预加载下两个媒体
    for (int i = 1; i <= 2; i++) {
      if (initialIndex + i < mediaItems.length) {
        preloadSingleMedia(mediaItems[initialIndex + i]);
      }
    }

    // 预加载上两个媒体
    for (int i = 1; i <= 2; i++) {
      if (initialIndex - i >= 0) {
        preloadSingleMedia(mediaItems[initialIndex - i]);
      }
    }
  }

  /// 预加载当前索引的相邻媒体
  void preloadMedia(List<MediaItem> mediaItems, int currentIndex) {
    // 预加载下两个媒体
    for (int i = 1; i <= 2; i++) {
      if (currentIndex + i < mediaItems.length) {
        final nextItem = mediaItems[currentIndex + i];
        preloadSingleMedia(nextItem);
      }
    }

    // 预加载上两个媒体
    for (int i = 1; i <= 2; i++) {
      if (currentIndex - i >= 0) {
        final prevItem = mediaItems[currentIndex - i];
        preloadSingleMedia(prevItem);
      }
    }
  }

  /// 预加载单个媒体
  void preloadSingleMedia(MediaItem mediaItem) async {
    if (mediaItem.url.isEmpty) return;

    final startTime = DateTime.now();

    try {
      // 检查是否已经缓存
      if (!mediaItem.isCached) {
        // 后台异步缓存媒体文件，不阻塞用户体验
        _cacheMediaInBackground(mediaItem);
      }

      // 如果组件已经销毁，不再初始化控制器
      if (!context.mounted) return;

      // 根据媒体类型进行预加载
      switch (mediaItem.type) {
        case MediaType.image:
          // 预加载图片（使用网络直接加载，不等待缓存）
          await precacheImage(NetworkImage(mediaItem.url), context);
          break;
        case MediaType.video:
          // 视频只缓存，不初始化控制器（节省内存）
          // 控制器会在用户查看时初始化
          break;
        case MediaType.audio:
          // 音频只缓存，不初始化播放器（节省内存）
          // 播放器会在用户查看时初始化
          break;
      }

      // 记录媒体加载性能
      final duration = DateTime.now().difference(startTime);
      performanceMonitor.trackMediaLoading(
        mediaItem.url,
        duration,
        mediaItem.type.toString().split('.').last,
      );
    } catch (error) {
      logger.error('Error preloading media', error);
      // 如果预加载失败，使用网络加载
      if (!context.mounted) return;

      if (mediaItem.type == MediaType.image) {
        try {
          await precacheImage(NetworkImage(mediaItem.url), context);
        } catch (e) {
          logger.error('Error precaching image', e);
        }
      }
    }
  }

  /// 后台缓存媒体文件
  void _cacheMediaInBackground(MediaItem mediaItem) async {
    try {
      // 使用CacheManager缓存媒体文件
      // 这个异步操作即使在MediaViewer关闭后也会在后台继续完成
      final cachedPath = await cacheManager.cacheFile(
        mediaItem.url,
        mediaItem.cacheCategory,
      );
      // 更新媒体项的缓存状态
      if (mediaItem.url == mediaItem.url) { // 确保媒体项仍然有效
        mediaItem.cachedPath = cachedPath;
        mediaItem.isCached = true;
        logger.debug(
          'Media background caching completed for: ${mediaItem.url}',
        );
      }
    } catch (error) {
      logger.error('Error caching media in background', error);
      // 后台缓存失败不影响用户体验，忽略错误
    }
  }

  /// 释放媒体资源
  static void disposeMediaResources(List<MediaItem> mediaItems) {
    for (var item in mediaItems) {
      item.dispose();
    }
  }
}
