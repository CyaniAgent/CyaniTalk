import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/application/auth_service.dart';
import '../../../auth/domain/account.dart';

class AssociatedAccountsSection extends ConsumerWidget {
  const AssociatedAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(authServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Associated Accounts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        accountsAsync.when(
          data: (accounts) => Column(
            children: [
              ...accounts.map((account) => _AccountCard(account: account)),
              if (accounts.isEmpty) const Text('No accounts linked yet.'),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error loading accounts: $err'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _showAddMisskeyDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Link Misskey'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _showAddFlarumDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Link Flarum'),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddMisskeyDialog(BuildContext context, WidgetRef ref) {
    final hostController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Misskey Account'),
        content: TextField(
          controller: hostController,
          decoration: const InputDecoration(
            labelText: 'Host (e.g. misskey.io)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final host = hostController.text.trim();
              if (host.isNotEmpty) {
                try {
                  final session = await ref
                      .read(authServiceProvider.notifier)
                      .startMiAuth(host);
                  // Show a dialog or snackbar with a "I have authorized" button
                  if (context.mounted) {
                    _showCheckAuthDialog(context, ref, host, session);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _showCheckAuthDialog(
    BuildContext context,
    WidgetRef ref,
    String host,
    String session,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Waiting for Authorization'),
        content: const Text(
          'Please authorize the app in your browser, then click "Done".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // Close dialog first
                await ref
                    .read(authServiceProvider.notifier)
                    .checkMiAuth(host, session);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Misskey account linked successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showAddFlarumDialog(BuildContext context, WidgetRef ref) {
    final hostController = TextEditingController();
    final tokenController = TextEditingController();
    final userController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Flarum Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostController,
              decoration: const InputDecoration(
                labelText: 'Host (e.g. discuss.flarum.org)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'Token',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final host = hostController.text.trim();
              final user = userController.text.trim();
              final token = tokenController.text.trim();

              if (host.isNotEmpty && user.isNotEmpty && token.isNotEmpty) {
                await ref
                    .read(authServiceProvider.notifier)
                    .linkFlarumAccount(host, token, user);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  final Account account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMisskey = account.platform == 'misskey';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMisskey
              ? Colors.green.shade100
              : Colors.orange.shade100,
          backgroundImage: account.avatarUrl != null
              ? NetworkImage(account.avatarUrl!)
              : null,
          child: account.avatarUrl == null
              ? Icon(
                  isMisskey ? Icons.public : Icons.forum,
                  color: isMisskey ? Colors.green : Colors.deepOrange,
                )
              : null,
        ),
        title: Text(account.username ?? 'Unknown'),
        subtitle: Text('${account.platform} @ ${account.host}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            ref.read(authServiceProvider.notifier).removeAccount(account.id);
          },
        ),
      ),
    );
  }
}
