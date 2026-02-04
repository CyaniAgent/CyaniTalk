import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/notification_settings_provider.dart';
import '../../../../core/services/notification_service.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_notifications_title'.tr())),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildPermissionSection(context),
            ListTile(
              leading: const Icon(Icons.notification_add_outlined),
              title: Text('settings_notif_test'.tr()),
              subtitle: Text('settings_notif_test_desc'.tr()),
              onTap: () async {
                await NotificationService().showNotification(
                  id: 0,
                  title: 'CyaniTalk (≧▽≦)',
                  body: 'settings_notif_test_body'.tr(),
                );
              },
            ),
            const Divider(),
            _buildSectionHeader(context, 'Misskey'),
            SwitchListTile(
              secondary: const Icon(Icons.rss_feed),
              title: Text('settings_notif_misskey_posts'.tr()),
              subtitle: Text('settings_notif_misskey_posts_desc'.tr()),
              value: settings.misskeyRealtimePost,
              onChanged: (value) => ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleMisskeyRealtimePost(value),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.message_outlined),
              title: Text('settings_notif_misskey_messages'.tr()),
              subtitle: Text('settings_notif_misskey_messages_desc'.tr()),
              value: settings.misskeyMessages,
              onChanged: (value) => ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleMisskeyMessages(value),
            ),
            const Divider(),
            _buildSectionHeader(context, 'Flarum'),
            SwitchListTile(
              secondary: const Icon(Icons.forum_outlined),
              title: Text('settings_notif_flarum'.tr()),
              subtitle: Text('settings_notif_flarum_desc'.tr()),
              value: settings.flarumNotifications,
              onChanged: (value) => ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleFlarumNotifications(value),
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

  Widget _buildPermissionSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.security_outlined),
      title: Text('settings_notif_permission'.tr()),
      subtitle: Text('settings_notif_permission_desc'.tr()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final granted = await NotificationService().requestPermissions();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                granted
                    ? 'settings_notif_permission_granted'.tr()
                    : 'settings_notif_permission_denied'.tr(),
              ),
            ),
          );
        }
      },
    );
  }
}
