import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/application/auth_service.dart';
import '../../../auth/domain/account.dart';
import '../../../auth/presentation/widgets/add_account_dialog.dart';
import 'user_details_view.dart';

/// 统一登录管理器组件
///
/// 显示用户关联的账户列表，支持切换查看详细资料以及添加/删除账户。
class AssociatedAccountsSection extends ConsumerWidget {
  /// 创建一个新的AssociatedAccountsSection实例
  const AssociatedAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(authServiceProvider);
    final selectedAccount = ref.watch(selectedAccountProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildManagerLayout(context, ref, accounts, selectedAccount);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.account_circle_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'No accounts linked yet.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _showAddAccountDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Account'),
        ),
      ],
    );
  }

  Widget _buildManagerLayout(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
    Account? selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Horizontal Account List
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...accounts.map((account) => _AccountAvatarItem(
                    account: account,
                    isSelected: selected?.id == account.id,
                    onTap: () => ref
                        .read(selectedAccountProvider.notifier)
                        .state = account,
                  )),
              _AddAccountButton(onTap: () => _showAddAccountDialog(context)),
            ],
          ),
        ),
        const Divider(height: 32),
        if (selected != null) ...[
          _buildSelectedHeader(context, selected),
          const SizedBox(height: 16),
          UserDetailsView(account: selected),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context, ref, selected),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Remove this account',
                  style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedHeader(BuildContext context, Account account) {
    final isMisskey = account.platform == 'misskey';
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: account.avatarUrl != null
              ? NetworkImage(account.avatarUrl!)
              : null,
          child: account.avatarUrl == null
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.username ?? 'Unknown',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  Image.asset(
                    isMisskey ? 'assets/icons/misskey.png' : 'assets/icons/flarum.png',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${isMisskey ? "Misskey" : "Flarum"} @ ${account.host}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text('Are you sure you want to remove ${account.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider.notifier).removeAccount(account.id);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AccountAvatarItem extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountAvatarItem({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundImage: account.avatarUrl != null
                ? NetworkImage(account.avatarUrl!)
                : null,
            child: account.avatarUrl == null
                ? Text(account.username?[0].toUpperCase() ?? '?')
                : null,
          ),
        ),
      ),
    );
  }
}

class _AddAccountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAccountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
