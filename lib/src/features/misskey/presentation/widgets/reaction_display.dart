import 'package:flutter/material.dart';
import '../../domain/note.dart';

class ReactionDisplay extends StatelessWidget {
  final Note note;
  final Function(String) onReactionTap;

  const ReactionDisplay({
    super.key,
    required this.note,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
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

        return _buildReactionChip(context, reaction, count, isMyReaction);
      }).toList(),
    );
  }

  Widget _buildReactionChip(
    BuildContext context,
    String reaction,
    int count,
    bool isMyReaction,
  ) {
    return GestureDetector(
      onTap: () => onReactionTap(reaction),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isMyReaction
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isMyReaction
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReactionIcon(reaction),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isMyReaction
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isMyReaction ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionIcon(String reaction) {
    if (reaction.startsWith(':') && reaction.endsWith(':')) {
      return Text(
        reaction,
        style: const TextStyle(fontSize: 16),
      );
    } else {
      return Text(
        reaction,
        style: const TextStyle(fontSize: 16),
      );
    }
  }
}
