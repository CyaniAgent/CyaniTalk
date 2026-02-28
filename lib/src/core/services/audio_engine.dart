import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 全局音频引擎服务
///
/// 使用 audioplayers 提供音频播放能力
class AudioEngine {
  final Map<String, AudioPlayer> _players = {};
  bool _isInitialized = true; // audioplayers doesn't need explicit init

  bool get isInitialized => _isInitialized;

    /// 初始化音频引擎
    Future<void> initialize() async {
      _isInitialized = true;
      logger.info('AudioEngine: Initialized (audioplayers)');
    }
  
    /// 播放资产音频 (带缓存/复用 Player) - 用于通知音效
    Future<void> playAsset(String assetPath, {double volume = 1.0}) async {
      try {
        final player = AudioPlayer();
        await player.setVolume(volume);
        
        // 为通知音效设置音频上下文，使用通知通道
        await player.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              usageType: AndroidUsageType.notification,
              contentType: AndroidContentType.speech, // 或者使用 sonification
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient, // 使用 ambient 避免干扰其他音频
              options: {AVAudioSessionOptions.duckOthers},
            ),
          ),
        );
        
        // audioplayers expects asset path without 'assets/' prefix if using AssetSource
        await player.play(AssetSource(assetPath));
  
        // We should dispose the player after it finishes playing
        player.onPlayerComplete.listen((event) {
          player.dispose();
        });
      } catch (e) {
        logger.error('AudioEngine: Failed to play asset $assetPath', e);
      }
    }
  
    /// 播放媒体音频 - 用于音频/视频内容
    Future<void> playMediaAsset(String assetPath, {double volume = 1.0}) async {
      try {
        final player = AudioPlayer();
        await player.setVolume(volume);
        
        // 为媒体内容设置音频上下文，使用媒体通道
        await player.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              usageType: AndroidUsageType.media,
              contentType: AndroidContentType.music,
              audioFocus: AndroidAudioFocus.gain,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback, // 使用 playback 获取音频焦点
              options: {AVAudioSessionOptions.duckOthers},
            ),
          ),
        );
        
        // audioplayers expects asset path without 'assets/' prefix if using AssetSource
        await player.play(AssetSource(assetPath));
  
        // We should dispose the player after it finishes playing
        player.onPlayerComplete.listen((event) {
          player.dispose();
        });
      } catch (e) {
        logger.error('AudioEngine: Failed to play media asset $assetPath', e);
      }
    }
  /// 释放资源
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

final audioEngineProvider = Provider((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});
