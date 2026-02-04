import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_settings_provider.g.dart';

class NotificationSettings {
  final bool misskeyRealtimePost;
  final bool misskeyMessages;
  final bool flarumNotifications;

  NotificationSettings({
    required this.misskeyRealtimePost,
    required this.misskeyMessages,
    required this.flarumNotifications,
  });

  NotificationSettings copyWith({
    bool? misskeyRealtimePost,
    bool? misskeyMessages,
    bool? flarumNotifications,
  }) {
    return NotificationSettings(
      misskeyRealtimePost: misskeyRealtimePost ?? this.misskeyRealtimePost,
      misskeyMessages: misskeyMessages ?? this.misskeyMessages,
      flarumNotifications: flarumNotifications ?? this.flarumNotifications,
    );
  }
}

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  static const _kMisskeyRealtimePost = 'notif_misskey_realtime_post';
  static const _kMisskeyMessages = 'notif_misskey_messages';
  static const _kFlarumNotifications = 'notif_flarum_notifications';

  @override
  FutureOr<NotificationSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      misskeyRealtimePost: prefs.getBool(_kMisskeyRealtimePost) ?? true,
      misskeyMessages: prefs.getBool(_kMisskeyMessages) ?? true,
      flarumNotifications: prefs.getBool(_kFlarumNotifications) ?? true,
    );
  }

  Future<void> toggleMisskeyRealtimePost(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyRealtimePost, value);
    state = AsyncData(state.value!.copyWith(misskeyRealtimePost: value));
  }

  Future<void> toggleMisskeyMessages(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyMessages, value);
    state = AsyncData(state.value!.copyWith(misskeyMessages: value));
  }

  Future<void> toggleFlarumNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFlarumNotifications, value);
    state = AsyncData(state.value!.copyWith(flarumNotifications: value));
  }
}
