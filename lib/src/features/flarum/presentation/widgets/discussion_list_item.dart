import 'package:flutter/material.dart';
import '../../data/models/discussion.dart';

class DiscussionListItem extends StatelessWidget {
  final Discussion discussion;
  final VoidCallback? onTap;

  const DiscussionListItem({super.key, required this.discussion, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(discussion.title[0].toUpperCase())),
      title: Text(
        discussion.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${discussion.commentCount} comments • ${discussion.lastPostedAt}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: discussion.isSticky
          ? const Icon(Icons.push_pin, size: 16)
          : null,
      onTap: onTap,
    );
  }
}
