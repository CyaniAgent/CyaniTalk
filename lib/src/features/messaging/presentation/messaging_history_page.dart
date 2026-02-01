import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../misskey/application/misskey_messaging_notifier.dart';
import '../../misskey/domain/messaging_message.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/application/misskey_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagingHistoryPage extends ConsumerWidget {
  const MessagingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(misskeyMessagingHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('nav_messages'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(misskeyMessagingHistoryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.read(misskeyMessagingHistoryProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: history.length,
              separatorBuilder: (context, index) => const Divider(indent: 72, height: 1),
              itemBuilder: (context, index) {
                final message = history[index];
                
                return Consumer(
                  builder: (context, ref, child) {
                    final me = ref.watch(misskeyMeProvider).value;
                    
                    // Determine who the "other" person is using the new extension
                    MisskeyUser? otherUser;
                    if (me != null) {
                      otherUser = (message.senderId == me.id) 
                          ? message.recipient 
                          : message.sender;
                    } else {
                      // Fallback if 'me' is not yet loaded
                      otherUser = message.sender ?? message.recipient;
                    }
                    
                    if (otherUser == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return _buildConversationTile(context, message, otherUser, me?.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(misskeyMessagingHistoryProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context, 
    MessagingMessage message, 
    MisskeyUser otherUser,
    String? myId,
  ) {
    final theme = Theme.of(context);
    final mikuGreen = const Color(0xFF39C5BB);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: otherUser.avatarUrl != null ? NetworkImage(otherUser.avatarUrl!) : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: otherUser.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUser.name ?? otherUser.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(message.createdAt),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              message.text ?? (message.file != null ? '[File]' : ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: message.isRead ? null : const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (!message.isRead && message.senderId != null && message.senderId != myId)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: mikuGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        context.push('/messaging/chat/${otherUser.id}', extra: otherUser);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('search_no_results'.tr()),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => ref.read(misskeyMessagingHistoryProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Stage'),
          ),
        ],
      ),
    );
  }
}
