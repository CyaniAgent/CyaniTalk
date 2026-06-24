import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/core/services/audio_engine.dart';
import '/src/core/widgets/settings_widgets.dart';
import '/src/core/widgets/sound_picker.dart';
import '/src/features/profile/application/sound_settings_provider.dart';

class SoundSettingsPage extends ConsumerWidget {
  const SoundSettingsPage({super.key});

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
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.edit_note_rounded,
                  iconColor: _blue,
                  label: 'sound_new_post'.tr(),
                  value: settings.newPostSound,
                  defaultPath: SoundDefaults.newPost,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setNewPostSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.send_rounded,
                  iconColor: _green,
                  label: 'sound_post'.tr(),
                  value: settings.postSound,
                  defaultPath: SoundDefaults.post,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setPostSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.notifications_rounded,
                  iconColor: _orange,
                  label: 'sound_notification'.tr(),
                  value: settings.notificationSound,
                  defaultPath: SoundDefaults.notification,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setNotificationSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.emoji_emotions_rounded,
                  iconColor: _pink,
                  label: 'sound_reaction'.tr(),
                  value: settings.reactionSound,
                  defaultPath: SoundDefaults.reaction,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setReactionSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.chat_rounded,
                  iconColor: _purple,
                  label: 'sound_message'.tr(),
                  value: settings.messageSound,
                  defaultPath: SoundDefaults.message,
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setMessageSound(v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SettingsCardGroup(
              children: [
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.swap_horiz_rounded,
                  iconColor: _cyan,
                  label: 'sound_switch_account'.tr(),
                  value: settings.switchAccountSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setSwitchAccountSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.refresh_rounded,
                  iconColor: _teal,
                  label: 'sound_trigger_refresh'.tr(),
                  value: settings.triggerRefreshSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setTriggerRefreshSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.sync_rounded,
                  iconColor: _indigo,
                  label: 'sound_refresh'.tr(),
                  value: settings.refreshSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setRefreshSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.system_update_rounded,
                  iconColor: _amber,
                  label: 'sound_app_update'.tr(),
                  value: settings.appUpdateSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setAppUpdateSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.wifi_off_rounded,
                  iconColor: _red,
                  label: 'sound_stream_error'.tr(),
                  value: settings.streamErrorSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setStreamErrorSound(v),
                ),
                _buildSlot(
                  context, ref, settings,
                  icon: Icons.error_outline_rounded,
                  iconColor: _deepOrange,
                  label: 'sound_app_error'.tr(),
                  value: settings.appErrorSound,
                  defaultPath: '',
                  onChanged: (v) => ref
                      .read(soundSettingsProvider.notifier)
                      .setAppErrorSound(v),
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

  Widget _buildSlot(
    BuildContext context, WidgetRef ref, SoundSettings settings, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String defaultPath,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 10),
          SoundPicker(
            value: value,
            onChanged: onChanged,
            silentLabel: 'sound_silent'.tr(),
            defaultLabel: 'sound_default'.tr(),
            addFileLabel: 'sound_add_file'.tr(),
            onAddFile: () => _onAddFile(context),
            onPreview: value.isEmpty
                ? null
                : () => _playSound(ref, SoundDefaults.resolve(value, defaultPath)),
          ),
        ],
      ),
    );
  }

  void _onAddFile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('sound_add_file_coming_soon'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _playSound(WidgetRef ref, String assetPath) async {
    if (assetPath.isEmpty) return;
    final path = assetPath.replaceFirst('assets/', '');
    await ref.read(audioEngineProvider).playAsset(path);
  }

  // ── Icon color palette ──
  static const _blue = Color(0xFF42A5F5);
  static const _green = Color(0xFF66BB6A);
  static const _orange = Color(0xFFFF7043);
  static const _pink = Color(0xFFEC407A);
  static const _purple = Color(0xFFAB47BC);
  static const _cyan = Color(0xFF26A69A);
  static const _teal = Color(0xFF00897B);
  static const _indigo = Color(0xFF5C6BC0);
  static const _amber = Color(0xFFFFCA28);
  static const _red = Color(0xFFEF5350);
  static const _deepOrange = Color(0xFFFF5722);
}
