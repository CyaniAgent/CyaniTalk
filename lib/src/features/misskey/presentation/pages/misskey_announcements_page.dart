import 'package:flutter/material.dart';

class MisskeyAnnouncementsPage extends StatelessWidget {
  const MisskeyAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isImportant = index == 0;
        return Card(
          color: isImportant ? Theme.of(context).colorScheme.errorContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isImportant ? Icons.warning : Icons.info,
                      color: isImportant
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isImportant ? 'Important Maintenance Notice' : 'Version Update ${13.0 + index}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isImportant
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : null,
                        ),
                      ),
                    ),
                    if (index < 2)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This is the content of the announcement. It contains important information about the server status or new features.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isImportant
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2026-01-20',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isImportant
                        ? Theme.of(context).colorScheme.onErrorContainer.withValues(alpha: 0.7)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}