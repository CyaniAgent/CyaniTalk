import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/core/config/constants.dart';

part 'network_settings_provider.g.dart';

/// 网络与实时设置
class NetworkSettings {
  /// 是否使用自定义 User Agent
  final bool useCustomAgent;

  /// 自定义 User Agent 字符串
  final String customUserAgent;

  /// Misskey 实时模式开关
  final bool misskeyRealtimeMode;

  /// 加载帖子最大时长（秒）
  final int loadPostMaxDuration;

  /// 加载表情最大时长（秒）
  final int loadEmojiMaxDuration;

  /// WebSocket 断线重连次数
  final int webSocketReconnectAttempts;

  /// WebSocket 后台最大存活时长（秒）
  final int webSocketBackgroundMaxDuration;

  /// HTTP 请求超时（秒）
  final int httpRequestTimeout;

  const NetworkSettings({
    required this.useCustomAgent,
    required this.customUserAgent,
    required this.misskeyRealtimeMode,
    required this.loadPostMaxDuration,
    required this.loadEmojiMaxDuration,
    required this.webSocketReconnectAttempts,
    required this.webSocketBackgroundMaxDuration,
    required this.httpRequestTimeout,
  });

  static const NetworkSettings defaults = NetworkSettings(
    useCustomAgent: false,
    customUserAgent: '',
    misskeyRealtimeMode: true,
    loadPostMaxDuration: 15,
    loadEmojiMaxDuration: 15,
    webSocketReconnectAttempts: 5,
    webSocketBackgroundMaxDuration: 3600,
    httpRequestTimeout: 30,
  );

  /// 获取有效的 User Agent 字符串
  String get effectiveUserAgent {
    if (useCustomAgent && customUserAgent.isNotEmpty) {
      return customUserAgent;
    }
    return Constants.getUserAgent();
  }

  NetworkSettings copyWith({
    bool? useCustomAgent,
    String? customUserAgent,
    bool? misskeyRealtimeMode,
    int? loadPostMaxDuration,
    int? loadEmojiMaxDuration,
    int? webSocketReconnectAttempts,
    int? webSocketBackgroundMaxDuration,
    int? httpRequestTimeout,
  }) {
    return NetworkSettings(
      useCustomAgent: useCustomAgent ?? this.useCustomAgent,
      customUserAgent: customUserAgent ?? this.customUserAgent,
      misskeyRealtimeMode: misskeyRealtimeMode ?? this.misskeyRealtimeMode,
      loadPostMaxDuration: loadPostMaxDuration ?? this.loadPostMaxDuration,
      loadEmojiMaxDuration: loadEmojiMaxDuration ?? this.loadEmojiMaxDuration,
      webSocketReconnectAttempts: webSocketReconnectAttempts ?? this.webSocketReconnectAttempts,
      webSocketBackgroundMaxDuration: webSocketBackgroundMaxDuration ?? this.webSocketBackgroundMaxDuration,
      httpRequestTimeout: httpRequestTimeout ?? this.httpRequestTimeout,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkSettings &&
          runtimeType == other.runtimeType &&
          useCustomAgent == other.useCustomAgent &&
          customUserAgent == other.customUserAgent &&
          misskeyRealtimeMode == other.misskeyRealtimeMode &&
          loadPostMaxDuration == other.loadPostMaxDuration &&
          loadEmojiMaxDuration == other.loadEmojiMaxDuration &&
          webSocketReconnectAttempts == other.webSocketReconnectAttempts &&
          webSocketBackgroundMaxDuration == other.webSocketBackgroundMaxDuration &&
          httpRequestTimeout == other.httpRequestTimeout;

  @override
  int get hashCode =>
      useCustomAgent.hashCode ^
      customUserAgent.hashCode ^
      misskeyRealtimeMode.hashCode ^
      loadPostMaxDuration.hashCode ^
      loadEmojiMaxDuration.hashCode ^
      webSocketReconnectAttempts.hashCode ^
      webSocketBackgroundMaxDuration.hashCode ^
      httpRequestTimeout.hashCode;
}

/// 网络设置状态管理器
@riverpod
class NetworkSettingsNotifier extends _$NetworkSettingsNotifier {
  static const String _useCustomAgentKey = 'network_use_custom_agent';
  static const String _customUserAgentKey = 'network_custom_user_agent';
  static const String _misskeyRealtimeModeKey = 'network_misskey_realtime_mode';
  static const String _loadPostMaxDurationKey = 'network_load_post_max_duration';
  static const String _loadEmojiMaxDurationKey = 'network_load_emoji_max_duration';
  static const String _webSocketReconnectAttemptsKey = 'network_websocket_reconnect_attempts';
  static const String _webSocketBackgroundMaxDurationKey = 'network_websocket_background_max_duration';
  static const String _httpRequestTimeoutKey = 'network_http_request_timeout';

  @override
  Future<NetworkSettings> build() async {
    final prefs = await SharedPreferences.getInstance();

    return NetworkSettings(
      useCustomAgent: prefs.getBool(_useCustomAgentKey) ?? NetworkSettings.defaults.useCustomAgent,
      customUserAgent: prefs.getString(_customUserAgentKey) ?? NetworkSettings.defaults.customUserAgent,
      misskeyRealtimeMode: prefs.getBool(_misskeyRealtimeModeKey) ?? NetworkSettings.defaults.misskeyRealtimeMode,
      loadPostMaxDuration: prefs.getInt(_loadPostMaxDurationKey) ?? NetworkSettings.defaults.loadPostMaxDuration,
      loadEmojiMaxDuration: prefs.getInt(_loadEmojiMaxDurationKey) ?? NetworkSettings.defaults.loadEmojiMaxDuration,
      webSocketReconnectAttempts: prefs.getInt(_webSocketReconnectAttemptsKey) ?? NetworkSettings.defaults.webSocketReconnectAttempts,
      webSocketBackgroundMaxDuration: prefs.getInt(_webSocketBackgroundMaxDurationKey) ?? NetworkSettings.defaults.webSocketBackgroundMaxDuration,
      httpRequestTimeout: prefs.getInt(_httpRequestTimeoutKey) ?? NetworkSettings.defaults.httpRequestTimeout,
    );
  }

  /// 切换自定义 User Agent
  Future<void> toggleCustomAgent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCustomAgentKey, value);
    state = AsyncData(state.value!.copyWith(useCustomAgent: value));
  }

  /// 更新自定义 User Agent
  Future<void> updateCustomUserAgent(String ua) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customUserAgentKey, ua);
    state = AsyncData(state.value!.copyWith(customUserAgent: ua));
  }

  /// 切换 Misskey 实时模式
  Future<void> toggleMisskeyRealtimeMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_misskeyRealtimeModeKey, value);
    state = AsyncData(state.value!.copyWith(misskeyRealtimeMode: value));
  }

  /// 更新加载帖子最大时长
  Future<void> updateLoadPostMaxDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loadPostMaxDurationKey, duration);
    state = AsyncData(state.value!.copyWith(loadPostMaxDuration: duration));
  }

  /// 更新加载表情最大时长
  Future<void> updateLoadEmojiMaxDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loadEmojiMaxDurationKey, duration);
    state = AsyncData(state.value!.copyWith(loadEmojiMaxDuration: duration));
  }

  /// 更新 WebSocket 断线重连次数
  Future<void> updateWebSocketReconnectAttempts(int attempts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_webSocketReconnectAttemptsKey, attempts);
    state = AsyncData(state.value!.copyWith(webSocketReconnectAttempts: attempts));
  }

  /// 更新 WebSocket 后台最大存活时长
  Future<void> updateWebSocketBackgroundMaxDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_webSocketBackgroundMaxDurationKey, duration);
    state = AsyncData(state.value!.copyWith(webSocketBackgroundMaxDuration: duration));
  }

  /// 更新 HTTP 请求超时
  Future<void> updateHttpRequestTimeout(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_httpRequestTimeoutKey, duration);
    state = AsyncData(state.value!.copyWith(httpRequestTimeout: duration));
  }

  /// 恢复默认设置
  Future<void> restoreDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_useCustomAgentKey);
    await prefs.remove(_customUserAgentKey);
    await prefs.remove(_misskeyRealtimeModeKey);
    await prefs.remove(_loadPostMaxDurationKey);
    await prefs.remove(_loadEmojiMaxDurationKey);
    await prefs.remove(_webSocketReconnectAttemptsKey);
    await prefs.remove(_webSocketBackgroundMaxDurationKey);
    await prefs.remove(_httpRequestTimeoutKey);
    state = const AsyncData(NetworkSettings.defaults);
  }
}
