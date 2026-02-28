import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '/src/core/navigation/navigation.dart';

class FlarumPostDetailsPage extends ConsumerWidget {
  final int discussionId;
  final String title;

  const FlarumPostDetailsPage({
    super.key,
    required this.discussionId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: Breakpoints.small.isActive(context)
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref
                    .read(navigationControllerProvider.notifier)
                    .openDrawer(),
              )
            : null,
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
