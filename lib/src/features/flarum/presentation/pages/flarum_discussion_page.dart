import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/flarum_providers.dart';
import '../widgets/discussion_list_item.dart';

class FlarumDiscussionPage extends ConsumerWidget {
  const FlarumDiscussionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussionsAsync = ref.watch(discussionsProvider);

    return discussionsAsync.when(
      data: (discussions) {
        if (discussions.isEmpty) {
          return Center(
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
                  'flarum_discussion_no_discussions'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: discussions.length,
          itemBuilder: (context, index) {
            final discussion = discussions[index];
            return DiscussionListItem(
              discussion: discussion,
              onTap: () {
                // TODO: Navigate to discussion details
              },
            );
          },
          padding: const EdgeInsets.symmetric(vertical: 8),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
            TextButton(
              onPressed: () => ref.invalidate(discussionsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
