import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/core/utils/logger.dart';

part 'audio_engine.g.dart';

class AudioEngine {
  final _soloud = SoLoud.instance;
  bool _isInitialized = false;
  final Map<String, AudioSource> _sources = {};

  bool get isInitialized => _isInitialized;

  Future<void> _ensureInit() async {
    if (!_isInitialized) {
      await _soloud.init();
      _isInitialized = true;
      logger.info('AudioEngine: Initialized (flutter_soloud)');
    }
  }

  String _normalizeAssetPath(String path) {
    if (path.startsWith('assets/')) return path;
    return 'assets/$path';
  }

  Future<AudioSource> _loadSource(String rawPath) async {
    final assetPath = _normalizeAssetPath(rawPath);
    final existing = _sources[assetPath];
    if (existing != null) return existing;
    final source = await _soloud.loadAsset(assetPath);
    _sources[assetPath] = source;
    return source;
  }

  Future<void> initialize() => _ensureInit();

  Future<void> playAsset(String rawPath, {double volume = 1.0}) async {
    try {
      await _ensureInit();
      final source = await _loadSource(rawPath);
      _soloud.play(source, volume: volume);
    } catch (e) {
      logger.error('AudioEngine: Failed to play asset $rawPath', e);
    }
  }

  Future<void> playMediaAsset(String rawPath, {double volume = 1.0}) async {
    try {
      await _ensureInit();
      final source = await _loadSource(rawPath);
      _soloud.play(source, volume: volume);
    } catch (e) {
      logger.error('AudioEngine: Failed to play media asset $rawPath', e);
    }
  }

  Future<void> dispose() async {
    for (final source in _sources.values) {
      await _soloud.disposeSource(source);
    }
    _sources.clear();
    _soloud.deinit();
    _isInitialized = false;
  }
}

@Riverpod(keepAlive: true)
AudioEngine audioEngine(Ref ref) {
  final engine = AudioEngine();
  ref.onDispose(engine.dispose);
  return engine;
}
