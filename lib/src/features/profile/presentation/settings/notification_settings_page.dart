import 'dart:io';
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
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Scaffold(
      appBar: AppBar(title: Text('settings_notifications_title'.tr())),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'settings_notif_mobile_only'.tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _buildPermissionSection(context, isDesktop),
            ListTile(
              leading: const Icon(Icons.notification_add_outlined),
              title: Text('settings_notif_test'.tr()),
              subtitle: Text('settings_notif_test_desc'.tr()),
              enabled: !isDesktop,
              onTap: isDesktop
                  ? null
                  : () async {
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
              onChanged: isDesktop
                  ? null
                  : (value) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleMisskeyRealtimePost(value),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.message_outlined),
              title: Text('settings_notif_misskey_messages'.tr()),
              subtitle: Text('settings_notif_misskey_messages_desc'.tr()),
              value: settings.misskeyMessages,
              onChanged: isDesktop
                  ? null
                  : (value) => ref
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
              onChanged: isDesktop
                  ? null
                  : (value) => ref
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

  Widget _buildPermissionSection(BuildContext context, bool isDesktop) {
    return ListTile(
      leading: const Icon(Icons.security_outlined),
      title: Text('settings_notif_permission'.tr()),
      subtitle: Text('settings_notif_permission_desc'.tr()),
      trailing: const Icon(Icons.chevron_right),
      enabled: !isDesktop,
      onTap: isDesktop
          ? null
          : () async {
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
