import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_settings_provider.g.dart';

class NotificationSettings {
  final bool misskeyRealtimePost;
  final bool misskeyMessages;

  NotificationSettings({
    required this.misskeyRealtimePost,
    required this.misskeyMessages,
  });

  NotificationSettings copyWith({
    bool? misskeyRealtimePost,
    bool? misskeyMessages,
  }) {
    return NotificationSettings(
      misskeyRealtimePost: misskeyRealtimePost ?? this.misskeyRealtimePost,
      misskeyMessages: misskeyMessages ?? this.misskeyMessages,
    );
  }
}

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  static const _kMisskeyRealtimePost = 'notif_misskey_realtime_post';
  static const _kMisskeyMessages = 'notif_misskey_messages';

  @override
  FutureOr<NotificationSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      misskeyRealtimePost: prefs.getBool(_kMisskeyRealtimePost) ?? true,
      misskeyMessages: prefs.getBool(_kMisskeyMessages) ?? true,
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
}
