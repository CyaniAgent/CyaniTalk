import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_settings_provider.g.dart';

/// 网络与实时设置
class NetworkSettings {
  /// User Agent 类型
  final String userAgentType;

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

  /// Flarum 讨论最大加载时长（秒）
  final int flarumDiscussionMaxLoadDuration;

  const NetworkSettings({
    required this.userAgentType,
    required this.misskeyRealtimeMode,
    required this.loadPostMaxDuration,
    required this.loadEmojiMaxDuration,
    required this.webSocketReconnectAttempts,
    required this.webSocketBackgroundMaxDuration,
    required this.flarumDiscussionMaxLoadDuration,
  });

  NetworkSettings copyWith({
    String? userAgentType,
    bool? misskeyRealtimeMode,
    int? loadPostMaxDuration,
    int? loadEmojiMaxDuration,
    int? webSocketReconnectAttempts,
    int? webSocketBackgroundMaxDuration,
    int? flarumDiscussionMaxLoadDuration,
  }) {
    return NetworkSettings(
      userAgentType: userAgentType ?? this.userAgentType,
      misskeyRealtimeMode: misskeyRealtimeMode ?? this.misskeyRealtimeMode,
      loadPostMaxDuration: loadPostMaxDuration ?? this.loadPostMaxDuration,
      loadEmojiMaxDuration: loadEmojiMaxDuration ?? this.loadEmojiMaxDuration,
      webSocketReconnectAttempts: webSocketReconnectAttempts ?? this.webSocketReconnectAttempts,
      webSocketBackgroundMaxDuration: webSocketBackgroundMaxDuration ?? this.webSocketBackgroundMaxDuration,
      flarumDiscussionMaxLoadDuration: flarumDiscussionMaxLoadDuration ?? this.flarumDiscussionMaxLoadDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkSettings &&
          runtimeType == other.runtimeType &&
          userAgentType == other.userAgentType &&
          misskeyRealtimeMode == other.misskeyRealtimeMode &&
          loadPostMaxDuration == other.loadPostMaxDuration &&
          loadEmojiMaxDuration == other.loadEmojiMaxDuration &&
          webSocketReconnectAttempts == other.webSocketReconnectAttempts &&
          webSocketBackgroundMaxDuration == other.webSocketBackgroundMaxDuration &&
          flarumDiscussionMaxLoadDuration == other.flarumDiscussionMaxLoadDuration;

  @override
  int get hashCode =>
      userAgentType.hashCode ^
      misskeyRealtimeMode.hashCode ^
      loadPostMaxDuration.hashCode ^
      loadEmojiMaxDuration.hashCode ^
      webSocketReconnectAttempts.hashCode ^
      webSocketBackgroundMaxDuration.hashCode ^
      flarumDiscussionMaxLoadDuration.hashCode;
}

/// 网络设置状态管理器
@riverpod
class NetworkSettingsNotifier extends _$NetworkSettingsNotifier {
  static const String _userAgentTypeKey = 'network_user_agent_type';
  static const String _misskeyRealtimeModeKey = 'network_misskey_realtime_mode';
  static const String _loadPostMaxDurationKey = 'network_load_post_max_duration';
  static const String _loadEmojiMaxDurationKey = 'network_load_emoji_max_duration';
  static const String _webSocketReconnectAttemptsKey = 'network_websocket_reconnect_attempts';
  static const String _webSocketBackgroundMaxDurationKey = 'network_websocket_background_max_duration';
  static const String _flarumDiscussionMaxLoadDurationKey = 'network_flarum_discussion_max_load_duration';

  @override
  Future<NetworkSettings> build() async {
    final prefs = await SharedPreferences.getInstance();

    return NetworkSettings(
      userAgentType: prefs.getString(_userAgentTypeKey) ?? 'default',
      misskeyRealtimeMode: prefs.getBool(_misskeyRealtimeModeKey) ?? true,
      loadPostMaxDuration: prefs.getInt(_loadPostMaxDurationKey) ?? 15,
      loadEmojiMaxDuration: prefs.getInt(_loadEmojiMaxDurationKey) ?? 15,
      webSocketReconnectAttempts: prefs.getInt(_webSocketReconnectAttemptsKey) ?? 5,
      webSocketBackgroundMaxDuration: prefs.getInt(_webSocketBackgroundMaxDurationKey) ?? 3600,
      flarumDiscussionMaxLoadDuration: prefs.getInt(_flarumDiscussionMaxLoadDurationKey) ?? 15,
    );
  }

  /// 更新 User Agent 类型
  Future<void> updateUserAgentType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAgentTypeKey, type);
    state = AsyncData(state.value!.copyWith(userAgentType: type));
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

  /// 更新 Flarum 讨论最大加载时长
  Future<void> updateFlarumDiscussionMaxLoadDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_flarumDiscussionMaxLoadDurationKey, duration);
    state = AsyncData(state.value!.copyWith(flarumDiscussionMaxLoadDuration: duration));
  }
}

/// User Agent 类型选项
enum UserAgentType {
  defaultAgent('Default', 'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36 CyaniTalk/1.0.0'),
  chromeLatest('Chrome Latest', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36');

  const UserAgentType(this.displayName, this.userAgentString);

  final String displayName;
  final String userAgentString;
}