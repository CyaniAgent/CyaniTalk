import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../application/sound_settings_provider.dart';

class SoundSettingsPage extends ConsumerStatefulWidget {
  const SoundSettingsPage({super.key});

  @override
  ConsumerState<SoundSettingsPage> createState() => _SoundSettingsPageState();
}

class _SoundSettingsPageState extends ConsumerState<SoundSettingsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(soundSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_sound_title'.tr())),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSectionHeader(context, 'Misskey'),
            _buildSoundTile(
              context,
              title: 'settings_sound_misskey_realtime_post'.tr(),
              subtitle: 'assets/sounds/PostReceived/n-aec.mp3',
              value: settings.enableMisskeyRealtimePost,
              onChanged: (value) => ref
                  .read(soundSettingsProvider.notifier)
                  .toggleMisskeyRealtimePost(value),
              onPreview: () => _playSound('assets/sounds/PostReceived/n-aec.mp3'),
            ),
            _buildSoundTile(
              context,
              title: 'settings_sound_misskey_posting'.tr(),
              subtitle: 'assets/sounds/PostSend/n-cea-4va.mp3',
              value: settings.enableMisskeyPosting,
              onChanged: (value) => ref
                  .read(soundSettingsProvider.notifier)
                  .toggleMisskeyPosting(value),
              onPreview: () => _playSound('assets/sounds/PostSend/n-cea-4va.mp3'),
            ),
            _buildSoundTile(
              context,
              title: 'settings_sound_misskey_notifications'.tr(),
              subtitle: 'assets/sounds/Notifications/n-ea.mp3',
              value: settings.enableMisskeyNotifications,
              onChanged: (value) => ref
                  .read(soundSettingsProvider.notifier)
                  .toggleMisskeyNotifications(value),
              onPreview: () => _playSound('assets/sounds/Notifications/n-ea.mp3'),
            ),
            _buildSoundTile(
              context,
              title: 'settings_sound_misskey_emoji'.tr(),
              subtitle: 'assets/sounds/Emoji-Responses/bubble2.mp3',
              value: settings.enableMisskeyEmojiReactions,
              onChanged: (value) => ref
                  .read(soundSettingsProvider.notifier)
                  .toggleMisskeyEmojiReactions(value),
              onPreview: () => _playSound('assets/sounds/Emoji-Responses/bubble2.mp3'),
            ),
            _buildSoundTile(
              context,
              title: 'settings_sound_misskey_messages'.tr(),
              subtitle: 'assets/sounds/Chat/waon.mp3',
              value: settings.enableMisskeyMessages,
              onChanged: (value) => ref
                  .read(soundSettingsProvider.notifier)
                  .toggleMisskeyMessages(value),
              onPreview: () => _playSound('assets/sounds/Chat/waon.mp3'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSoundTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onPreview,
  }) {
    return SwitchListTile(
      secondary: IconButton(
        icon: const Icon(Icons.play_circle_outline),
        onPressed: onPreview,
        tooltip: '预览声音',
      ),
      title: Text('$title (Misskey default)'),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
