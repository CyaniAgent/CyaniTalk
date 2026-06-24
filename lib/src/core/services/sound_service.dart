import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/profile/application/sound_settings_provider.dart';
import 'audio_engine.dart';

class SoundService {
  final Ref ref;

  SoundService(this.ref);

  Future<void> playMisskeyRealtimePost() async {
    final settings = await ref.read(soundSettingsProvider.future);
    final path = SoundDefaults.resolve(settings.newPostSound, SoundDefaults.newPost);
    if (path.isNotEmpty) await _play(path.replaceFirst('assets/', ''));
  }

  Future<void> playMisskeyPosting() async {
    final settings = await ref.read(soundSettingsProvider.future);
    final path = SoundDefaults.resolve(settings.postSound, SoundDefaults.post);
    if (path.isNotEmpty) await _play(path.replaceFirst('assets/', ''));
  }

  Future<void> playMisskeyNotifications() async {
    final settings = await ref.read(soundSettingsProvider.future);
    final path = SoundDefaults.resolve(settings.notificationSound, SoundDefaults.notification);
    if (path.isNotEmpty) await _play(path.replaceFirst('assets/', ''));
  }

  Future<void> playMisskeyEmojiReactions() async {
    final settings = await ref.read(soundSettingsProvider.future);
    final path = SoundDefaults.resolve(settings.reactionSound, SoundDefaults.reaction);
    if (path.isNotEmpty) await _play(path.replaceFirst('assets/', ''));
  }

  Future<void> playMisskeyMessages() async {
    final settings = await ref.read(soundSettingsProvider.future);
    final path = SoundDefaults.resolve(settings.messageSound, SoundDefaults.message);
    if (path.isNotEmpty) await _play(path.replaceFirst('assets/', ''));
  }

    Future<void> _play(String assetPath) async {
      await ref.read(audioEngineProvider).playAsset(assetPath);
    }
}

final soundServiceProvider = Provider((ref) => SoundService(ref));
