import 'package:flutter/material.dart';

class MisskeyPostDetailsPage extends StatelessWidget {
  final int noteId;
  final String user;

  const MisskeyPostDetailsPage({
    super.key,
    required this.noteId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Loading note details...', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
