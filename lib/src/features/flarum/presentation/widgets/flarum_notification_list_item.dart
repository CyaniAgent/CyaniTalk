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
      leading: Icon(
        iconData,
        color: notification.isRead
            ? null
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        notification.content ?? notification.type,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.createdAt,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }
}
