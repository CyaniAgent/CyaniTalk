import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/note.dart';
import '../../data/misskey_repository.dart';
import 'retryable_network_image.dart';

class NoteCard extends ConsumerWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = note.user;
    final text = note.text;
    final cw = note.cw;

    return RepaintBoundary(
      child: Semantics(
        label: 'Note by ${user?.username}',
        value: text ?? cw,
        child:
            Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Semantics(
                              label: 'Avatar for ${user?.username}',
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                                child: user?.avatarUrl == null
                                    ? Text(
                                        user?.username[0].toUpperCase() ?? '?',
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    label: 'User name',
                                    child: Text(
                                      user?.name ?? user?.username ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Semantics(
                                    label: 'User handle',
                                    child: Text(
                                      '@${user?.username}${user?.host != null ? "@${user!.host}" : ""}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Semantics(
                              label: 'Post time',
                              child: Text(
                                _formatTime(note.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (cw != null) ...[
                          Semantics(
                            label: 'Content warning',
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(cw)),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else if (text != null)
                          Semantics(label: 'Note content', child: Text(text)),

                        if (note.files.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Semantics(
                              label: 'Attached files',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  children: note.files.map((file) {
                                    final url = file['url'] as String?;
                                    if (url == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: RetryableNetworkImage(
                                        url: url,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Semantics(
                              label: 'Reply button',
                              child: _buildAction(
                                context,
                                Icons.reply,
                                note.repliesCount.toString(),
                                () => _handleReply(context, ref),
                              ),
                            ),
                            Semantics(
                              label: 'Renote button',
                              child: _buildAction(
                                context,
                                Icons.repeat,
                                note.renoteCount.toString(),
                                () => _handleRenote(context, ref),
                              ),
                            ),
                            Semantics(
                              label: 'Reaction button',
                              child: _buildAction(
                                context,
                                Icons.add_reaction_outlined,
                                note.reactions.length.toString(),
                                () => _handleReaction(context, ref),
                              ),
                            ),
                            Semantics(
                              label: 'Share button',
                              child: _buildAction(
                                context,
                                Icons.share_outlined,
                                "",
                                () => _handleShare(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Future<void> _handleRenote(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(misskeyRepositoryProvider).renote(note.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Renoted successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to renote: $e')));
      }
    }
  }

  Future<void> _handleReply(BuildContext context, WidgetRef ref) async {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'What\'s on your mind?'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(misskeyRepositoryProvider)
                    .reply(note.id, textController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Reply sent!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reply: $e')),
                  );
                }
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReaction(BuildContext context, WidgetRef ref) async {
    try {
      // Default to heart for now
      await ref.read(misskeyRepositoryProvider).addReaction(note.id, '❤️');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reaction added!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to react: $e')));
      }
    }
  }

  void _handleShare(BuildContext context) {
    // Placeholder for share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}
