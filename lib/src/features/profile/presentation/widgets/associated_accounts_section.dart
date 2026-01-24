// 关联账户管理组件
//
// 该文件包含AssociatedAccountsSection组件，用于显示和管理用户关联的账户列表，
// 支持添加和删除Misskey和Flarum账户。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/application/auth_service.dart';
import '../../../auth/domain/account.dart';

/// 关联账户管理组件
///
/// 显示用户关联的账户列表，支持添加和删除Misskey和Flarum账户。
class AssociatedAccountsSection extends ConsumerWidget {
  /// 创建一个新的AssociatedAccountsSection实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const AssociatedAccountsSection({super.key});

  /// 构建关联账户管理界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
  ///
  /// 返回包含账户列表和添加按钮的Column组件
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

  /// 显示添加Misskey账户的对话框
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
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
                  // 显示等待授权的对话框
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

  /// 显示检查Misskey授权状态的对话框
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
  /// [host] - Misskey实例的主机地址
  /// [session] - 认证会话ID
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
            onPressed: () => Navigator.pop(context), // 取消
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // 先关闭对话框
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

  /// 显示添加Flarum账户的对话框
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
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

/// 单个账户卡片组件
///
/// 显示单个关联账户的信息，包括头像、用户名、平台和主机地址，
/// 并提供删除账户的功能。
class _AccountCard extends ConsumerWidget {
  /// 账户信息
  final Account account;

  /// 创建一个新的_AccountCard实例
  ///
  /// [account] - 要显示的账户信息
  const _AccountCard({required this.account});

  /// 构建单个账户卡片的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [ref] - Riverpod的WidgetRef，用于访问和监听状态
  ///
  /// 返回一个包含账户信息和删除按钮的Card组件
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
