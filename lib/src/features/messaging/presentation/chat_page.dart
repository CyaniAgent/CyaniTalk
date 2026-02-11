import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../misskey/application/misskey_messaging_notifier.dart';
import '../../misskey/domain/messaging_message.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/domain/chat_room.dart';
import '../../misskey/application/misskey_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

enum ChatType { direct, room }

class ChatPage extends ConsumerStatefulWidget {
  final String id;
  final ChatType type;
  final dynamic initialData; // MisskeyUser for direct, ChatRoom for room

  const ChatPage({
    super.key,
    required this.id,
    required this.type,
    this.initialData,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (widget.type == ChatType.direct) {
      ref.read(misskeyMessagingProvider(widget.id).notifier).sendMessage(text);
    } else {
      ref.read(misskeyChatRoomProvider(widget.id).notifier).sendMessage(text);
    }
    
    _textController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(misskeyMeProvider);

    final messagesAsync = widget.type == ChatType.direct
        ? ref.watch(misskeyMessagingProvider(widget.id))
        : ref.watch(misskeyChatRoomProvider(widget.id));

    return meAsync.when(
      data: (me) {
        if (widget.type == ChatType.direct) {
          final userAsync = ref.watch(misskeyUserProvider(widget.id));
          return userAsync.when(
            data: (user) => _buildScaffold(context, me, messagesAsync, user: user),
            loading: () => _buildScaffold(context, me, messagesAsync, user: widget.initialData as MisskeyUser?, isLoadingUser: true),
            error: (err, stack) => _buildScaffold(context, me, messagesAsync, user: widget.initialData as MisskeyUser?, userError: err),
          );
        } else {
          final room = widget.initialData as ChatRoom?;
          return _buildScaffold(context, me, messagesAsync, room: room);
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('${'messaging_error_loading_user'.tr()}: $err'))),
    );
  }

  Widget _buildScaffold(
    BuildContext context, 
    MisskeyUser me, 
    AsyncValue<List<MessagingMessage>> messagesAsync, 
    {MisskeyUser? user, ChatRoom? room, bool isLoadingUser = false, Object? userError}
  ) {
    final theme = Theme.of(context);
    
    String title = 'messaging_chat_title'.tr();
    Widget? leadingAvatar;
    bool isInputLocked = isLoadingUser;

    if (widget.type == ChatType.direct) {
      final displayUser = user ?? widget.initialData as MisskeyUser?;
      title = displayUser?.name ?? displayUser?.username ?? title;
      leadingAvatar = CircleAvatar(
        radius: 16,
        backgroundImage: displayUser?.avatarUrl != null ? NetworkImage(displayUser!.avatarUrl!) : null,
        child: displayUser?.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
      );
      
      // Verification: Check if widget.id matches displayUser.id if available
      if (displayUser != null && displayUser.id != widget.id) {
        title = 'messaging_error_id_mismatch'.tr();
        isInputLocked = true;
      }
    } else {
      title = room?.name ?? 'messaging_room_chat_title'.tr();
      leadingAvatar = CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: const Icon(Icons.groups, size: 20),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            leadingAvatar,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  if (isLoadingUser)
                    Text('common_loading'.tr(), style: theme.textTheme.labelSmall)
                  else if (user != null)
                    Text('@${user.username}', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('search_no_results'.tr()),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == me.id;
                    
                    if (widget.type == ChatType.direct && !message.isRead && !isMe) {
                      Future.microtask(() => ref.read(misskeyMessagingProvider(widget.id).notifier).markAsRead(message.id));
                    }
                    
                    return _buildMessageBubble(context, message, isMe, me.id);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('${'common_error'.tr()}: $err')),
            ),
          ),
          _buildInputArea(context, isLocked: isInputLocked),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessagingMessage message, bool isMe, String myId) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && widget.type == ChatType.room)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  message.sender?.name ?? message.sender?.username ?? '?',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13), // 0.05 * 255
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text ?? '',
                style: TextStyle(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                timeago.format(message.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, {bool isLocked = false}) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(128))), // 0.5 * 255
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: isLocked ? null : () {},
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: !isLocked,
              decoration: InputDecoration(
                hintText: isLocked ? 'messaging_chat_locked'.tr() : 'messaging_type_message'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isLocked ? theme.colorScheme.surfaceContainer : theme.colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: isLocked ? theme.colorScheme.outlineVariant : theme.colorScheme.primary,
            shape: const CircleBorder(),
            elevation: isLocked ? 0 : 2,
            child: IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
              onPressed: isLocked ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
