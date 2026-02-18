import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '/src/core/utils/cache_manager.dart';

/// 媒体类型枚举
enum MediaType {
  image, 
  video, 
  audio
}

/// 媒体项类
class MediaItem {
  final String url;
  final MediaType type;
  final String? fileName;
  VideoPlayerController? videoController;
  AudioPlayer? audioPlayer;
  String? cachedPath;
  bool isCached = false;

  MediaItem({required this.url, required this.type, this.fileName});

  /// 获取对应的缓存类别
  CacheCategory get cacheCategory {
    switch (type) {
      case MediaType.image:
        return CacheCategory.image;
      case MediaType.audio:
        return CacheCategory.audio;
      case MediaType.video:
        return CacheCategory.other;
    }
  }

  /// 释放媒体资源
  void dispose() {
    try {
      if (videoController != null) {
        videoController?.dispose();
        videoController = null;
      }
      if (audioPlayer != null) {
        audioPlayer?.dispose();
        audioPlayer = null;
      }
    } catch (e) {
      // 忽略释放时的错误
    }
  }
}
