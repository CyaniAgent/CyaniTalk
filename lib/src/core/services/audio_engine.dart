import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 全局音频引擎服务
/// 
/// 使用 flutter_soloud 提供低延迟音频播放能力
class AudioEngine {
  bool _isInitialized = false;
  final Map<String, AudioSource> _cache = {};

  bool get isInitialized => _isInitialized;

  /// 初始化音频引擎
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await SoLoud.instance.init();
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
      AudioSource? source = _cache[assetPath];
      if (source == null) {
        // flutter_soloud assets need to be correctly prefixed in pubspec
        // usually 'assets/sounds/...'
        source = await SoLoud.instance.loadAsset('assets/$assetPath');
        _cache[assetPath] = source;
      }
      
      SoLoud.instance.play(source, volume: volume);
    } catch (e) {
      logger.error('AudioEngine: Failed to play asset $assetPath', e);
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    for (final source in _cache.values) {
      SoLoud.instance.disposeSource(source);
    }
    _cache.clear();
    SoLoud.instance.deinit();
    _isInitialized = false;
  }
}

final audioEngineProvider = Provider((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});
