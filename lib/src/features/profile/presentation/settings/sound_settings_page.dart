import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/profile/application/sound_settings_provider.dart';
import '/src/core/services/audio_engine.dart';
import '/src/core/widgets/settings_widgets.dart';

class SoundSettingsPage extends ConsumerWidget {
  const SoundSettingsPage({super.key});

  static const _pink = Color(0xFFEC407A);

  Future<void> _playSound(WidgetRef ref, String assetPath) async {
    final path = assetPath.replaceFirst('assets/', '');
    await ref.read(audioEngineProvider).playAsset(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(soundSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_sound_title'.tr())),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            SettingsCardGroup(
              children: [
                _soundSwitchTile(context, settings, ref,
                  title: 'settings_sound_misskey_realtime_post'.tr(),
                  subtitle: 'assets/sounds/PostReceived/n-aec.mp3',
                  value: settings.enableMisskeyRealtimePost,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .toggleMisskeyRealtimePost(v),
                  assetPath: 'assets/sounds/PostReceived/n-aec.mp3',
                ),
                _soundSwitchTile(context, settings, ref,
                  title: 'settings_sound_misskey_posting'.tr(),
                  subtitle: 'assets/sounds/PostSend/n-cea-4va.mp3',
                  value: settings.enableMisskeyPosting,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .toggleMisskeyPosting(v),
                  assetPath: 'assets/sounds/PostSend/n-cea-4va.mp3',
                ),
                _soundSwitchTile(context, settings, ref,
                  title: 'settings_sound_misskey_notifications'.tr(),
                  subtitle: 'assets/sounds/Notifications/n-ea.mp3',
                  value: settings.enableMisskeyNotifications,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .toggleMisskeyNotifications(v),
                  assetPath: 'assets/sounds/Notifications/n-ea.mp3',
                ),
                _soundSwitchTile(context, settings, ref,
                  title: 'settings_sound_misskey_emoji'.tr(),
                  subtitle: 'assets/sounds/Emoji-Responses/bubble2.mp3',
                  value: settings.enableMisskeyEmojiReactions,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .toggleMisskeyEmojiReactions(v),
                  assetPath: 'assets/sounds/Emoji-Responses/bubble2.mp3',
                ),
                _soundSwitchTile(context, settings, ref,
                  title: 'settings_sound_misskey_messages'.tr(),
                  subtitle: 'assets/sounds/Chat/waon.mp3',
                  value: settings.enableMisskeyMessages,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .toggleMisskeyMessages(v),
                  assetPath: 'assets/sounds/Chat/waon.mp3',
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text('Error')),
      ),
    );
  }

  Widget _soundSwitchTile(
    BuildContext context, SoundSettings settings, WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String assetPath,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_circle_filled, color: _pink, size: 28),
            onPressed: () => _playSound(ref, assetPath),
            tooltip: '预览声音',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title (Misskey default)', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
