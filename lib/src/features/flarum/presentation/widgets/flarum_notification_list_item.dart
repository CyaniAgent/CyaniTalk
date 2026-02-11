import 'package:flutter/material.dart';
import '../../data/models/flarum_notification.dart';

class FlarumNotificationListItem extends StatelessWidget {
  final FlarumNotification notification;
  final VoidCallback? onTap;

  const FlarumNotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.notifications;
    switch (notification.type) {
      case 'postLiked':
        iconData = Icons.favorite;
        break;
      case 'newPost':
        iconData = Icons.chat_bubble;
        break;
      // Add more cases as needed
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surfaceVariant
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          iconData,
          size: 20,
          color: notification.isRead
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        notification.content ?? notification.type,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        notification.createdAt,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
    );
  }
}
