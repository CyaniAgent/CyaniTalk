import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../misskey/application/misskey_messaging_notifier.dart';
import '../../misskey/domain/messaging_message.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/application/misskey_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagingChatPage extends ConsumerStatefulWidget {
  final String userId;
  final MisskeyUser? initialUser;

  const MessagingChatPage({super.key, required this.userId, this.initialUser});

  @override
  ConsumerState<MessagingChatPage> createState() => _MessagingChatPageState();
}

class _MessagingChatPageState extends ConsumerState<MessagingChatPage> {
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

    ref.read(misskeyMessagingProvider(widget.userId).notifier).sendMessage(text);
    _textController.clear();
    
    // Scroll to bottom after sending
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
    final messagesAsync = ref.watch(misskeyMessagingProvider(widget.userId));
    final meAsync = ref.watch(misskeyMeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.initialUser?.avatarUrl != null 
                ? NetworkImage(widget.initialUser!.avatarUrl!) 
                : null,
              child: widget.initialUser?.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.initialUser?.name ?? widget.initialUser?.username ?? 'messaging_chat_title'.tr(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: meAsync.when(
        data: (me) => Column(
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
                      // Use flexible senderId to check if it's from me
                      final isMe = message.senderId == me.id;
                      
                      // Mark as read when it appears and it's not from me
                      if (!message.isRead && !isMe) {
                        Future.microtask(() => ref.read(misskeyMessagingProvider(widget.userId).notifier).markAsRead(message.id));
                      }
                      
                      return _buildMessageBubble(context, message, isMe);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('${'common_error'.tr()}: $err')),
              ),
            ),
            _buildInputArea(context),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${'messaging_error_loading_user'.tr()}: $err')),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessagingMessage message, bool isMe) {
    final theme = Theme.of(context);
    final mikuGreen = const Color(0xFF39C5BB);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? mikuGreen : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text ?? '',
                style: TextStyle(
                  color: isMe ? Colors.white : theme.colorScheme.onSurfaceVariant,
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

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    final mikuGreen = const Color(0xFF39C5BB);

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Attachment support
            },
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'messaging_type_message'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: mikuGreen,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}