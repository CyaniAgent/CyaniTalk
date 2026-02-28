import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/emoji.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/presentation/widgets/retryable_network_image.dart';

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
                _buildReactionIcon(ref, reaction),
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

  Widget _buildReactionIcon(WidgetRef ref, String reaction) {
    // 处理带有 @ 符号的表情格式，如 :Snow_Miku_26@.:
    if (reaction.startsWith(':') && reaction.endsWith(':')) {
      // 提取表情名称和实例信息
      final parts = reaction.replaceAll(':', '').split('@');
      final emojiName = parts[0];
      final instance = parts.length > 1 ? parts[1] : null;

      // 使用 FutureBuilder 异步获取表情详情，包括正确的图片 URL
      return FutureBuilder<EmojiDetail>(
        future: _getEmojiDetail(ref, emojiName, instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 使用 API 返回的正确图片 URL
            return SizedBox(
              width: 20,
              height: 20,
              child: RetryableNetworkImage(
                url: snapshot.data!.url,
                fit: BoxFit.contain,
                width: 20,
                height: 20,
              ),
            );
          } else {
            // 加载中或失败时显示占位符
            return SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: Text(
                  emojiName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          }
        },
      );
    } else {
      // 普通表情符号直接显示
      return Text(reaction, style: const TextStyle(fontSize: 16));
    }
  }

  /// 获取表情详情，包括正确的图片 URL
  Future<EmojiDetail> _getEmojiDetail(
    WidgetRef ref,
    String emojiName,
    String? instance,
  ) async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      // 如果有实例信息，需要从对应的实例获取表情
      if (instance != null && instance != '.' && instance.isNotEmpty) {
        // 这里可以实现从其他实例获取表情的逻辑
        // 暂时使用当前实例的API，后续可以扩展
        return await repository.getEmoji(emojiName);
      } else {
        // 从当前实例获取表情
        return await repository.getEmoji(emojiName);
      }
    } catch (e) {
      // 如果获取失败，返回一个默认的表情详情
      return EmojiDetail(
        id: emojiName,
        aliases: [emojiName],
        name: emojiName,
        url: '',
      );
    }
  }
}
