import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyanitalk/src/features/misskey/application/misskey_notifier.dart';
import 'package:cyanitalk/src/features/misskey/domain/channel.dart';
import 'package:cyanitalk/src/features/misskey/presentation/pages/misskey_channel_details_page.dart';

/// Misskey 频道页面组件
///
/// 显示用户已加入的频道列表。
class MisskeyChannelsPage extends ConsumerWidget {
  /// 创建一个新的MisskeyChannelsPage实例
  const MisskeyChannelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(misskeyChannelsProvider);

    return Scaffold(
      body: channelsAsync.when(
        data: (channels) {
          if (channels.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(misskeyChannelsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: channels.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final channel = channels[index];
                return _buildChannelTile(context, channel);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildChannelTile(BuildContext context, Channel channel) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: channel.bannerUrl != null
              ? DecorationImage(
                  image: NetworkImage(channel.bannerUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: channel.bannerUrl == null
            ? const Icon(Icons.forum_outlined)
            : null,
      ),
      title: Text(
        channel.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        channel.description ?? 'No description',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${channel.usersCount} users',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${channel.notesCount} notes',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MisskeyChannelDetailsPage(channel: channel),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          const Text('No joined channels found'),
        ],
      ),
    );
  }
}
