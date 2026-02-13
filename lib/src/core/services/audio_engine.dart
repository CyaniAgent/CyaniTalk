import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 全局音频引擎服务
///
/// 使用 audioplayers 提供跨平台音频播放能力
class AudioEngine {
  bool _isInitialized = false;
  final Map<String, AudioPlayer> _cache = {};

  bool get isInitialized => _isInitialized;

  /// 初始化音频引擎
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // audioplayers 不需要显式初始化
      _isInitialized = true;
      logger.info('AudioEngine: Initialized successfully');
    } catch (e) {
      logger.error('AudioEngine: Failed to initialize', e);
    }
  }

  /// 播放资产音频 (带缓存)
  Future<void> playAsset(String assetPath, {double volume = 1.0}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      AudioPlayer? player = _cache[assetPath];
      if (player == null) {
        player = AudioPlayer();
        _cache[assetPath] = player;
      }

      await player.setVolume(volume);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      logger.error('AudioEngine: Failed to play asset $assetPath', e);
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      for (final player in _cache.values) {
        await player.dispose();
      }
      _cache.clear();
      _isInitialized = false;
      logger.info('AudioEngine: Disposed successfully');
    } catch (e) {
      logger.error('AudioEngine: Failed to dispose', e);
    }
  }
}

final audioEngineProvider = Provider((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});
