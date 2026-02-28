import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/src/features/misskey/application/misskey_messaging_notifier.dart';
import '/src/features/misskey/application/misskey_notifications_notifier.dart';
import '/src/features/misskey/domain/messaging_message.dart';
import '/src/features/misskey/domain/misskey_user.dart';
import '/src/features/misskey/domain/chat_room.dart';
import '/src/features/misskey/domain/misskey_notification.dart';
import '/src/features/misskey/application/misskey_notifier.dart';

enum InboxFilter { all, direct, groups, notifications }

class MessagingPage extends ConsumerStatefulWidget {
  const MessagingPage({super.key});

  @override
  ConsumerState<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends ConsumerState<MessagingPage> {
  InboxFilter _currentFilter = InboxFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'nav_messages'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(misskeyMessagingHistoryProvider.notifier).refresh();
              ref.read(misskeyNotificationsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildUnifiedList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: InboxFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _currentFilter = filter);
              },
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(51), // 0.2 * 255
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(InboxFilter filter) {
    return switch (filter) {
      InboxFilter.all => 'common_all'.tr(),
      InboxFilter.direct => 'messaging_direct'.tr(),
      InboxFilter.groups => 'messaging_groups'.tr(),
      InboxFilter.notifications => 'notifications_title'.tr(),
    };
  }

  Widget _buildUnifiedList() {
    final historyAsync = ref.watch(misskeyMessagingHistoryProvider);
    final notificationsAsync = ref.watch(misskeyNotificationsProvider);
    final meAsync = ref.watch(misskeyMeProvider);

    return meAsync.when(
      data: (me) {
        return historyAsync.when(
          data: (history) {
            return notificationsAsync.when(
              data: (notifications) {
                final combinedList = _getFilteredAndSortedList(
                  history,
                  notifications,
                  me.id,
                );

                if (combinedList.isEmpty && notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(misskeyMessagingHistoryProvider.notifier)
                        .refresh();
                    await ref
                        .read(misskeyNotificationsProvider.notifier)
                        .refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount:
                        combinedList.length +
                        (notifications.isNotEmpty &&
                                (_currentFilter == InboxFilter.all ||
                                    _currentFilter == InboxFilter.notifications)
                            ? 1
                            : 0),
                    separatorBuilder: (context, index) =>
                        const Divider(indent: 72, height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      // Show aggregate notifications tile at the top if there are notifications
                      final showAggregate =
                          notifications.isNotEmpty &&
                          (_currentFilter == InboxFilter.all ||
                              _currentFilter == InboxFilter.notifications);

                      if (showAggregate && index == 0) {
                        return _buildAggregateNotificationsTile(
                          notifications.first,
                        );
                      }

                      final itemIndex = showAggregate ? index - 1 : index;
                      final item = combinedList[itemIndex];
                      final String id = (item is MessagingMessage)
                          ? item.id
                          : (item as MisskeyNotification).id;

                      if (item is MessagingMessage) {
                        if (item.room != null) {
                          return _buildRoomTile(
                            item,
                            item.room!,
                            me.id,
                            key: ValueKey('room_$id'),
                          );
                        } else {
                          // 获取对方用户
                          final otherUser = (item.senderId == me.id)
                              ? item.recipient
                              : item.sender;

                          // 如果用户对象存在，直接使用
                          if (otherUser != null) {
                            return _buildDirectTile(
                              item,
                              otherUser,
                              me.id,
                              key: ValueKey('direct_$id'),
                            );
                          }

                          // 如果用户对象缺失，但有用户ID，创建临时用户对象
                          String? counterpartId;
                          if (item.senderId == me.id) {
                            // 我发的消息，对方是接收者
                            counterpartId = item.recipientId;
                          } else {
                            // 别人发给我的消息，对方是发送者
                            counterpartId = item.senderId;
                          }

                          if (counterpartId != null) {
                            final tempUser = MisskeyUser(
                              id: counterpartId,
                              username: 'User_$counterpartId',
                              name: 'User $counterpartId',
                            );
                            return _buildDirectTile(
                              item,
                              tempUser,
                              me.id,
                              key: ValueKey('direct_$id'),
                            );
                          }

                          // 最后才显示系统未知
                          return _buildSystemTile(
                            item,
                            key: ValueKey('system_$id'),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildErrorState(err),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(err),
    );
  }

  List<dynamic> _getFilteredAndSortedList(
    List<MessagingMessage> history,
    List<MisskeyNotification> notifications,
    String myId,
  ) {
    List<dynamic> list = [];

    if (_currentFilter == InboxFilter.all ||
        _currentFilter == InboxFilter.direct) {
      list.addAll(history.where((m) => m.room == null));
    }

    if (_currentFilter == InboxFilter.all ||
        _currentFilter == InboxFilter.groups) {
      list.addAll(history.where((m) => m.room != null));
    }

    // Notifications are now aggregated separately, so we don't add them to the main list here

    // Sort by createdAt descending
    list.sort((a, b) {
      final dateA = (a is MessagingMessage)
          ? a.createdAt
          : (a as MisskeyNotification).createdAt;
      final dateB = (b is MessagingMessage)
          ? b.createdAt
          : (b as MisskeyNotification).createdAt;
      return dateB.compareTo(dateA);
    });

    return list;
  }

  Widget _buildDirectTile(
    MessagingMessage message,
    MisskeyUser otherUser,
    String myId, {
    Key? key,
  }) {
    return ListTile(
      key: key,
      leading: _buildAvatar(otherUser.avatarUrl, Icons.person),
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
          Text(
            timeago.format(message.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              message.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!message.isRead && message.senderId != myId)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () =>
          context.push('/messaging/chat/${otherUser.id}', extra: otherUser),
    );
  }

  Widget _buildRoomTile(
    MessagingMessage message,
    ChatRoom room,
    String myId, {
    Key? key,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      key: key,
      leading: _buildAvatar(null, Icons.groups, isRoom: true),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.name ?? 'Group Chat',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
              '${message.sender?.name ?? '?'}: ${message.text ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!message.isRead && message.senderId != myId)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () => context.push('/messaging/chat/room/${room.id}', extra: room),
    );
  }

  Widget _buildAggregateNotificationsTile(MisskeyNotification latest) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withAlpha(26), // 0.1 * 255
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.notifications_active, color: primaryColor),
      ),
      title: Text(
        'notifications_title'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _getNotificationText(latest),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeago.format(latest.createdAt),
            style: theme.textTheme.bodySmall,
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
      onTap: () => context.push('/misskey/notifications'),
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

  Widget _buildSystemTile(MessagingMessage message, {Key? key}) {
    return ListTile(
      key: key,
      leading: _buildAvatar(null, Icons.settings),
      title: Text(
        'messaging_system_unknown'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message.text ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAvatar(String? url, IconData fallback, {bool isRoom = false}) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 24,
      backgroundColor: isRoom
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Icon(
              fallback,
              color: isRoom ? theme.colorScheme.onPrimaryContainer : null,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'messaging_empty_title'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'messaging_empty_description'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // 这里可以添加一个操作，比如打开新消息页面
              },
              icon: const Icon(Icons.add),
              label: Text('messaging_empty_action'.tr()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'messaging_error_title'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'messaging_error_description'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              err.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                ref.read(misskeyMessagingHistoryProvider.notifier).refresh();
                ref.read(misskeyNotificationsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: Text('messaging_error_retry'.tr()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
