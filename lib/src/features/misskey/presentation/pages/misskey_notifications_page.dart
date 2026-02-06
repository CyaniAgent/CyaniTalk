import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../application/misskey_notifications_notifier.dart';
import '../../domain/misskey_notification.dart';

class MisskeyNotificationsPage extends ConsumerWidget {
  const MisskeyNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(misskeyNotificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(misskeyNotificationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('search_no_results'.tr()),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(misskeyNotificationsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(indent: 72, height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(context, notification);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${'common_error'.tr()}: $err')),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, MisskeyNotification notification) {
    final theme = Theme.of(context);
    IconData iconData = Icons.notifications;
    Color iconColor = theme.colorScheme.primary;

    switch (notification.type) {
      case 'follow': iconData = Icons.person_add; iconColor = Colors.blue; break;
      case 'mention': iconData = Icons.alternate_email; iconColor = Colors.orange; break;
      case 'reply': iconData = Icons.reply; iconColor = Colors.green; break;
      case 'renote': iconData = Icons.repeat; iconColor = Colors.teal; break;
      case 'reaction': iconData = Icons.add_reaction; iconColor = Colors.pink; break;
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: notification.user?.avatarUrl != null ? NetworkImage(notification.user!.avatarUrl!) : null,
            child: notification.user?.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
              child: Icon(iconData, size: 12, color: iconColor),
            ),
          ),
        ],
      ),
      title: Text(
        _getNotificationText(notification),
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(timeago.format(notification.createdAt), style: theme.textTheme.bodySmall),
      onTap: () {
        // Handle notification tap
      },
    );
  }

  String _getNotificationText(MisskeyNotification n) {
    final name = n.user?.name ?? n.user?.username ?? 'someone';
    return switch (n.type) {
      'follow' => 'notifications_followed'.tr(args: [name]),
      'mention' => 'notifications_mentioned'.tr(args: [name]),
      'reply' => 'notifications_replied'.tr(args: [name]),
      'renote' => 'notifications_renoted'.tr(args: [name]),
      'reaction' => 'notifications_reacted'.tr(args: [name]),
      _ => 'notifications_new'.tr(args: [name]),
    };
  }
}
