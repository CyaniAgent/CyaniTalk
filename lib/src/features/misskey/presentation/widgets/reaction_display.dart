import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/note.dart';
import '../../data/misskey_repository.dart';
import './retryable_network_image.dart';

class ReactionDisplay extends ConsumerWidget {
  final Note note;
  final String host;
  final Function(String) onReactionTap;

  const ReactionDisplay({
    super.key,
    required this.note,
    required this.host,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactions = note.reactions;

    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: reactions.entries.map((entry) {
        final reaction = entry.key;
        final count = entry.value;
        final isMyReaction = note.myReaction == reaction;

        return _buildReactionChip(context, ref, reaction, count, isMyReaction);
      }).toList(),
    );
  }

  Widget _buildReactionChip(
    BuildContext context,
    WidgetRef ref,
    String reaction,
    int count,
    bool isMyReaction,
  ) {
    // 提取表情名称，用于工具提示
    String emojiName = reaction;
    if (reaction.startsWith(':') && reaction.endsWith(':')) {
      final parts = reaction.replaceAll(':', '').split('@');
      emojiName = parts[0];
    }

    return FutureBuilder<List<dynamic>>(
      future: ref
          .read(misskeyRepositoryProvider.future)
          .then((repo) => repo.getNoteReactions(note.id, type: reaction)),
      builder: (context, snapshot) {
        String tooltipMessage = emojiName;
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final users = snapshot.data!
              .map((item) => item['user']['name'] ?? item['user']['username'])
              .toList();
          tooltipMessage = '$emojiName\n${users.join('\n')}';
        }

        return Tooltip(
          message: tooltipMessage,
          waitDuration: const Duration(milliseconds: 500),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReactionIcon(reaction),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isMyReaction
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            selected: isMyReaction,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            onSelected: (selected) {
              if (isMyReaction) {
                // 如果点击的是自己已有的表情，显示二次确认对话框
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('取消表情反应'),
                    content: const Text('确定要取消这个表情反应吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 调用取消表情的方法
                          onReactionTap(reaction);
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              } else if (note.myReaction != null) {
                // 如果已经有其他表情反应，先取消再发送新的
                onReactionTap(reaction);
              } else {
                // 直接发送表情反应
                onReactionTap(reaction);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildReactionIcon(String reaction) {
    // 处理带有 @ 符号的表情格式，如 :Snow_Miku_26@.:
    if (reaction.startsWith(':') && reaction.endsWith(':')) {
      // 提取表情名称和实例信息
      final parts = reaction.replaceAll(':', '').split('@');
      final emojiName = parts[0];
      final instance = parts.length > 1 ? parts[1] : null;

      // 构建表情图片 URL
      // 注意：这是一个简化的实现，实际的表情 URL 格式可能因实例而异
      String emojiUrl;
      if (instance == '.' || instance == null) {
        // 当前实例的表情，使用完整的 URL
        emojiUrl = 'https://$host/emoji/$emojiName.png';
      } else {
        // 其他实例的表情，使用完整的 URL
        emojiUrl = 'https://$instance/emoji/$emojiName.png';
      }

      // 使用 RetryableNetworkImage 加载表情图片，与图片反应使用相同的缓存逻辑
      return SizedBox(
        width: 20,
        height: 20,
        child: RetryableNetworkImage(url: emojiUrl, fit: BoxFit.contain),
      );
    } else {
      // 普通表情符号直接显示
      return Text(reaction, style: const TextStyle(fontSize: 16));
    }
  }
}
