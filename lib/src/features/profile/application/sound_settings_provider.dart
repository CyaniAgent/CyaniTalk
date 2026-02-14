import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sound_settings_provider.g.dart';

class SoundSettings {
  final bool enableMisskeyRealtimePost;
  final bool enableMisskeyPosting;
  final bool enableMisskeyNotifications;
  final bool enableMisskeyEmojiReactions;
  final bool enableMisskeyMessages;

  SoundSettings({
    required this.enableMisskeyRealtimePost,
    required this.enableMisskeyPosting,
    required this.enableMisskeyNotifications,
    required this.enableMisskeyEmojiReactions,
    required this.enableMisskeyMessages,
  });

  SoundSettings copyWith({
    bool? enableMisskeyRealtimePost,
    bool? enableMisskeyPosting,
    bool? enableMisskeyNotifications,
    bool? enableMisskeyEmojiReactions,
    bool? enableMisskeyMessages,
  }) {
    return SoundSettings(
      enableMisskeyRealtimePost:
          enableMisskeyRealtimePost ?? this.enableMisskeyRealtimePost,
      enableMisskeyPosting: enableMisskeyPosting ?? this.enableMisskeyPosting,
      enableMisskeyNotifications:
          enableMisskeyNotifications ?? this.enableMisskeyNotifications,
      enableMisskeyEmojiReactions:
          enableMisskeyEmojiReactions ?? this.enableMisskeyEmojiReactions,
      enableMisskeyMessages:
          enableMisskeyMessages ?? this.enableMisskeyMessages,
    );
  }
}

@riverpod
class SoundSettingsNotifier extends _$SoundSettingsNotifier {
  static const _kMisskeyRealtimePost = 'sound_misskey_realtime_post';
  static const _kMisskeyPosting = 'sound_misskey_posting';
  static const _kMisskeyNotifications = 'sound_misskey_notifications';
  static const _kMisskeyEmojiReactions = 'sound_misskey_emoji_reactions';
  static const _kMisskeyMessages = 'sound_misskey_messages';

  @override
  FutureOr<SoundSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SoundSettings(
      enableMisskeyRealtimePost: prefs.getBool(_kMisskeyRealtimePost) ?? true,
      enableMisskeyPosting: prefs.getBool(_kMisskeyPosting) ?? true,
      enableMisskeyNotifications: prefs.getBool(_kMisskeyNotifications) ?? true,
      enableMisskeyEmojiReactions:
          prefs.getBool(_kMisskeyEmojiReactions) ?? true,
      enableMisskeyMessages: prefs.getBool(_kMisskeyMessages) ?? true,
    );
  }

  Future<void> toggleMisskeyRealtimePost(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyRealtimePost, value);
    state = AsyncData(state.value!.copyWith(enableMisskeyRealtimePost: value));
  }

  Future<void> toggleMisskeyPosting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyPosting, value);
    state = AsyncData(state.value!.copyWith(enableMisskeyPosting: value));
  }

  Future<void> toggleMisskeyNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyNotifications, value);
    state = AsyncData(state.value!.copyWith(enableMisskeyNotifications: value));
  }

  Future<void> toggleMisskeyEmojiReactions(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyEmojiReactions, value);
    state = AsyncData(
      state.value!.copyWith(enableMisskeyEmojiReactions: value),
    );
  }

  Future<void> toggleMisskeyMessages(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMisskeyMessages, value);
    state = AsyncData(state.value!.copyWith(enableMisskeyMessages: value));
  }
}
