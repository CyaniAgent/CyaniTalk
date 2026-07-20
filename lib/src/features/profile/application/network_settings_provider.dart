import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_settings_provider.g.dart';

/// 网络与实时设置
class NetworkSettings {
  /// User Agent 类型
  final String userAgentType;

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
    required this.userAgentType,
    required this.customUserAgent,
    required this.misskeyRealtimeMode,
    required this.loadPostMaxDuration,
    required this.loadEmojiMaxDuration,
    required this.webSocketReconnectAttempts,
    required this.webSocketBackgroundMaxDuration,
    required this.httpRequestTimeout,
  });

  static const NetworkSettings defaults = NetworkSettings(
    userAgentType: 'default',
    customUserAgent: '',
    misskeyRealtimeMode: true,
    loadPostMaxDuration: 15,
    loadEmojiMaxDuration: 15,
    webSocketReconnectAttempts: 5,
    webSocketBackgroundMaxDuration: 3600,
    httpRequestTimeout: 30,
  );

  NetworkSettings copyWith({
    String? userAgentType,
    String? customUserAgent,
    bool? misskeyRealtimeMode,
    int? loadPostMaxDuration,
    int? loadEmojiMaxDuration,
    int? webSocketReconnectAttempts,
    int? webSocketBackgroundMaxDuration,
    int? httpRequestTimeout,
  }) {
    return NetworkSettings(
      userAgentType: userAgentType ?? this.userAgentType,
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
          userAgentType == other.userAgentType &&
          customUserAgent == other.customUserAgent &&
          misskeyRealtimeMode == other.misskeyRealtimeMode &&
          loadPostMaxDuration == other.loadPostMaxDuration &&
          loadEmojiMaxDuration == other.loadEmojiMaxDuration &&
          webSocketReconnectAttempts == other.webSocketReconnectAttempts &&
          webSocketBackgroundMaxDuration == other.webSocketBackgroundMaxDuration &&
          httpRequestTimeout == other.httpRequestTimeout;

  @override
  int get hashCode =>
      userAgentType.hashCode ^
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
  static const String _userAgentTypeKey = 'network_user_agent_type';
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
      userAgentType: prefs.getString(_userAgentTypeKey) ?? NetworkSettings.defaults.userAgentType,
      customUserAgent: prefs.getString(_customUserAgentKey) ?? NetworkSettings.defaults.customUserAgent,
      misskeyRealtimeMode: prefs.getBool(_misskeyRealtimeModeKey) ?? NetworkSettings.defaults.misskeyRealtimeMode,
      loadPostMaxDuration: prefs.getInt(_loadPostMaxDurationKey) ?? NetworkSettings.defaults.loadPostMaxDuration,
      loadEmojiMaxDuration: prefs.getInt(_loadEmojiMaxDurationKey) ?? NetworkSettings.defaults.loadEmojiMaxDuration,
      webSocketReconnectAttempts: prefs.getInt(_webSocketReconnectAttemptsKey) ?? NetworkSettings.defaults.webSocketReconnectAttempts,
      webSocketBackgroundMaxDuration: prefs.getInt(_webSocketBackgroundMaxDurationKey) ?? NetworkSettings.defaults.webSocketBackgroundMaxDuration,
      httpRequestTimeout: prefs.getInt(_httpRequestTimeoutKey) ?? NetworkSettings.defaults.httpRequestTimeout,
    );
  }

  /// 更新 User Agent 类型
  Future<void> updateUserAgentType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAgentTypeKey, type);
    state = AsyncData(state.value!.copyWith(userAgentType: type));
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
    await prefs.remove(_userAgentTypeKey);
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

/// User Agent 类型选项
enum UserAgentType {
  // ── Desktop ──
  defaultAgent(
    'Default (CyaniTalk)',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 CyaniTalk/1.0.0',
    isDesktop: true,
  ),
  chromeDesktop(
    'Chrome 150',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',
    isDesktop: true,
  ),
  firefoxDesktop(
    'Firefox 152',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:152.0) Gecko/20100101 Firefox/152.0',
    isDesktop: true,
  ),
  safariDesktop(
    'Safari 26.5',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Safari/605.1.15',
    isDesktop: true,
  ),
  edgeDesktop(
    'Edge 150',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0',
    isDesktop: true,
  ),
  // ── Mobile ──
  chromeMobileAndroid(
    'Chrome 150 (Android)',
    'Mozilla/5.0 (Linux; Android 16; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36',
    isDesktop: false,
  ),
  chromeMobileIOS(
    'Chrome 150 (iOS)',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 19_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/150.0.0.0 Mobile/15E148 Safari/604.1',
    isDesktop: false,
  ),
  firefoxMobileAndroid(
    'Firefox 152 (Android)',
    'Mozilla/5.0 (Android 16; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0',
    isDesktop: false,
  ),
  firefoxMobileIOS(
    'Firefox 152 (iOS)',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 19_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/152.0 Mobile/15E148 Safari/605.1.15',
    isDesktop: false,
  ),
  safariMobile(
    'Safari 26.5 (iOS)',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 19_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1',
    isDesktop: false,
  ),
  // ── Custom ──
  custom('Custom', '', isDesktop: false);

  const UserAgentType(this.displayName, this.userAgentString, {required this.isDesktop});

  final String displayName;
  final String userAgentString;
  final bool isDesktop;

  /// 获取有效的 User Agent 字符串
  String getEffectiveUA({String? customUA}) {
    if (this == UserAgentType.custom) {
      return customUA?.isNotEmpty == true ? customUA! : userAgentString;
    }
    return userAgentString;
  }

  /// 按平台分组
  static List<UserAgentType> get desktopOptions =>
      values.where((e) => e.isDesktop && e != custom).toList();

  static List<UserAgentType> get mobileOptions =>
      values.where((e) => !e.isDesktop && e != custom).toList();
}
