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
    // 设置全局音频上下文，解决 Android 上的通道/流类型警告
    AudioPlayer.global.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        usageType: AndroidUsageType.notificationEvent,
        contentType: AndroidContentType.sonification,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: [
          AVAudioSessionOptions.duckOthers,
          AVAudioSessionOptions.defaultToSpeaker,
        ],
      ),
    ));

    _isInitialized = true;
    logger.info('AudioEngine: Initialized (audioplayers)');
  }

  /// 播放资产音频 (带缓存/复用 Player)
  Future<void> playAsset(String assetPath, {double volume = 1.0}) async {
    try {
      // For simple sound effects, we can just create a new player or reuse one.
      // To allow multiple sounds to play simultaneously, we can use a new player or a pool.
      // Here we create a temporary player for simple implementation.
      final player = AudioPlayer();
      await player.setVolume(volume);
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
