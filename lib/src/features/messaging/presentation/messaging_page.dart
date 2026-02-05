import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../misskey/application/misskey_messaging_notifier.dart';
import '../../misskey/application/misskey_notifications_notifier.dart';
import '../../misskey/domain/messaging_message.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/domain/chat_room.dart';
import '../../misskey/domain/misskey_notification.dart';
import '../../misskey/application/misskey_notifier.dart';

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
        title: Text('nav_messages'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          Expanded(
            child: _buildUnifiedList(),
          ),
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
              selectedColor: const Color(0xFF39C5BB).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF39C5BB) : null,
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
                final combinedList = _getFilteredAndSortedList(history, notifications, me.id);
                
                if (combinedList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(misskeyMessagingHistoryProvider.notifier).refresh();
                    await ref.read(misskeyNotificationsProvider.notifier).refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: combinedList.length,
                    separatorBuilder: (context, index) => const Divider(indent: 72, height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final item = combinedList[index];
                      if (item is MessagingMessage) {
                        if (item.room != null) {
                          return _buildRoomTile(item, item.room!, me.id);
                        } else {
                          final otherUser = (item.senderId == me.id) ? item.recipient : item.sender;
                          if (otherUser == null) return _buildSystemTile(item);
                          return _buildDirectTile(item, otherUser, me.id);
                        }
                      } else if (item is MisskeyNotification) {
                        return _buildNotificationTile(item);
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
    
    if (_currentFilter == InboxFilter.all || _currentFilter == InboxFilter.direct) {
      list.addAll(history.where((m) => m.room == null));
    }
    
    if (_currentFilter == InboxFilter.all || _currentFilter == InboxFilter.groups) {
      list.addAll(history.where((m) => m.room != null));
    }
    
    if (_currentFilter == InboxFilter.all || _currentFilter == InboxFilter.notifications) {
      list.addAll(notifications);
    }

    // Sort by createdAt descending
    list.sort((a, b) {
      final dateA = (a is MessagingMessage) ? a.createdAt : (a as MisskeyNotification).createdAt;
      final dateB = (b is MessagingMessage) ? b.createdAt : (b as MisskeyNotification).createdAt;
      return dateB.compareTo(dateA);
    });

    return list;
  }

  Widget _buildDirectTile(MessagingMessage message, MisskeyUser otherUser, String myId) {
    final mikuGreen = const Color(0xFF39C5BB);
    return ListTile(
      leading: _buildAvatar(otherUser.avatarUrl, Icons.person),
      title: Row(
        children: [
          Expanded(child: Text(otherUser.name ?? otherUser.username, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(timeago.format(message.createdAt), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(child: Text(message.text ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (!message.isRead && message.senderId != myId)
            Container(width: 8, height: 8, decoration: BoxDecoration(color: mikuGreen, shape: BoxShape.circle)),
        ],
      ),
      onTap: () => context.push('/messaging/chat/${otherUser.id}', extra: otherUser),
    );
  }

  Widget _buildRoomTile(MessagingMessage message, ChatRoom room, String myId) {
    final theme = Theme.of(context);
    final mikuGreen = const Color(0xFF39C5BB);
    return ListTile(
      leading: _buildAvatar(null, Icons.groups, isRoom: true),
      title: Row(
        children: [
          Expanded(child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(timeago.format(message.createdAt), style: theme.textTheme.bodySmall),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(child: Text('${message.sender?.name ?? '?'}: ${message.text ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (!message.isRead && message.senderId != myId)
            Container(width: 8, height: 8, decoration: BoxDecoration(color: mikuGreen, shape: BoxShape.circle)),
        ],
      ),
      onTap: () => context.push('/messaging/chat/room/${room.id}', extra: room),
    );
  }

  Widget _buildNotificationTile(MisskeyNotification notification) {
    final theme = Theme.of(context);
    IconData iconData = Icons.notifications;
    Color iconColor = theme.colorScheme.primary;

    switch (notification.type) {
      case 'follow': iconData = Icons.person_add; iconColor = Colors.blue; break;
      case 'mention': iconData = Icons.alternate_email; iconColor = Colors.orange; break;
      case 'reply': iconData = Icons.reply; iconColor = Colors.green; break;
      case 'renote': iconData = Icons.repeat; iconColor = Colors.teal; break;
      case 'reaction': iconData = Icons.add_reaction; iconColor = Colors.pink; break;
    }

    return ListTile(
      leading: Stack(
        children: [
          _buildAvatar(notification.user?.avatarUrl, Icons.person),
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
              child: Icon(iconData, size: 12, color: iconColor),
            ),
          ),
        ],
      ),
      title: Text(
        _getNotificationText(notification),
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(timeago.format(notification.createdAt), style: theme.textTheme.bodySmall),
      onTap: () {
        // Handle notification tap (e.g. show note)
      },
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

  Widget _buildSystemTile(MessagingMessage message) {
    return ListTile(
      leading: _buildAvatar(null, Icons.settings),
      title: Text('messaging_system_unknown'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message.text ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildAvatar(String? url, IconData fallback, {bool isRoom = false}) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 24,
      backgroundColor: isRoom ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null ? Icon(fallback, color: isRoom ? theme.colorScheme.onPrimaryContainer : null) : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('search_no_results'.tr()),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(child: Text('${'common_error'.tr()}: $err'));
  }
}