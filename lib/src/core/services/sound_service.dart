import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/application/sound_settings_provider.dart';
import 'audio_engine.dart';

class SoundService {
  final Ref ref;

  SoundService(this.ref);

  Future<void> playMisskeyRealtimePost() async {
    final settings = await ref.read(soundSettingsProvider.future);
    if (settings.enableMisskeyRealtimePost) {
      await _play('sounds/PostReceived/n-aec.mp3');
    }
  }

  Future<void> playMisskeyPosting() async {
    final settings = await ref.read(soundSettingsProvider.future);
    if (settings.enableMisskeyPosting) {
      await _play('sounds/PostSend/n-cea-4va.mp3');
    }
  }

  Future<void> playMisskeyNotifications() async {
    final settings = await ref.read(soundSettingsProvider.future);
    if (settings.enableMisskeyNotifications) {
      await _play('sounds/Notifications/n-ea.mp3');
    }
  }

  Future<void> playMisskeyEmojiReactions() async {
    final settings = await ref.read(soundSettingsProvider.future);
    if (settings.enableMisskeyEmojiReactions) {
      await _play('sounds/Emoji-Responses/bubble2.mp3');
    }
  }

  Future<void> playMisskeyMessages() async {
    final settings = await ref.read(soundSettingsProvider.future);
    if (settings.enableMisskeyMessages) {
      await _play('sounds/Chat/waon.mp3');
    }
  }

    Future<void> _play(String assetPath) async {
      await ref.read(audioEngineProvider).playAsset(assetPath);
    }}

final soundServiceProvider = Provider((ref) => SoundService(ref));
