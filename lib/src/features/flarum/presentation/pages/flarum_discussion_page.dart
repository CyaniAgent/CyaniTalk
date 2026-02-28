import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/flarum/application/flarum_providers.dart';
import '/src/features/flarum/presentation/widgets/discussion_list_item.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';
import '/src/features/common/presentation/widgets/media/media_item.dart';

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
                // 导航到讨论详情页面
                // TODO: 实现讨论详情页面
                // 示例：Navigator.push(context, MaterialPageRoute(builder: (context) => FlarumDiscussionDetailPage(discussion: discussion)));
                
                // 示例：如果讨论包含媒体内容，显示媒体浏览器
                // 这里只是示例，实际实现需要根据讨论的实际媒体内容来处理
                final mediaItems = [
                  MediaItem(
                    url: 'https://picsum.photos/200/300',
                    type: MediaType.image,
                  ),
                  MediaItem(
                    url: 'https://picsum.photos/300/200',
                    type: MediaType.image,
                  ),
                ];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaViewerPage(
                      mediaItems: mediaItems,
                      initialIndex: 0,
                    ),
                  ),
                );
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
