import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FlarumPostDetailsPage extends StatelessWidget {
  final int discussionId;
  final String title;

  const FlarumPostDetailsPage({
    super.key,
    required this.discussionId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flarum_post_details_title'.tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'flarum_post_details_loading'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}