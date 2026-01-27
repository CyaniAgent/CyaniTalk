import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../auth/application/auth_service.dart';
import '../../../auth/domain/account.dart';
import '../../../auth/presentation/widgets/add_account_dialog.dart';
import 'user_details_view.dart';

/// 统一登录管理器组件
///
/// 显示用户关联的账户列表，支持切换查看详细资料以及添加/删除账户。
class AssociatedAccountsSection extends ConsumerStatefulWidget {
  /// 创建一个新的AssociatedAccountsSection实例
  const AssociatedAccountsSection({super.key});

  @override
  ConsumerState<AssociatedAccountsSection> createState() => _AssociatedAccountsSectionState();
}

class _AssociatedAccountsSectionState extends ConsumerState<AssociatedAccountsSection> {
  Account? _focusedAccount;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(authServiceProvider);
    final selectedMisskey = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final selectedFlarum = ref.watch(selectedFlarumAccountProvider).asData?.value;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return _buildEmptyState(context);
        }
        
        // Ensure focused account is valid
        if (_focusedAccount == null || !accounts.contains(_focusedAccount)) {
           // Default to one of the active accounts or the first one
           _focusedAccount = selectedMisskey ?? selectedFlarum ?? accounts.first;
        }
        
        // If the user just switched via some other means (unlikely here but good for consistency), 
        // we could sync _focusedAccount, but local tap priority is better.

        return _buildManagerLayout(
          context, 
          ref, 
          accounts, 
          selectedMisskey, 
          selectedFlarum,
        );
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
          'accounts_no_linked'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _showAddAccountDialog(context),
          icon: const Icon(Icons.add),
          label: Text('accounts_add_account'.tr()),
        ),
      ],
    );
  }

  Widget _buildManagerLayout(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
    Account? selectedMisskey,
    Account? selectedFlarum,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Horizontal Account List
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...accounts.map((account) {
                 final isMisskeyActive = account.id == selectedMisskey?.id;
                 final isFlarumActive = account.id == selectedFlarum?.id;
                 final isActive = isMisskeyActive || isFlarumActive;
                 final isFocused = account.id == _focusedAccount?.id;
                 
                 return _AccountAvatarItem(
                    account: account,
                    isActive: isActive,
                    isFocused: isFocused,
                    activeColor: isMisskeyActive 
                        ? const Color(0xFF39C5BB) // Miku Green
                        : (isFlarumActive ? Colors.orange : Colors.grey),
                    onTap: () {
                      setState(() {
                        _focusedAccount = account;
                      });
                      if (account.platform == 'misskey') {
                        ref.read(selectedMisskeyAccountProvider.notifier).select(account);
                      } else if (account.platform == 'flarum') {
                        ref.read(selectedFlarumAccountProvider.notifier).select(account);
                      }
                    },
                  );
              }),
              _AddAccountButton(onTap: () => _showAddAccountDialog(context)),
            ],
          ),
        ),
        const Divider(height: 32),
        if (_focusedAccount != null) ...[
          _buildSelectedHeader(context, _focusedAccount!),
          const SizedBox(height: 16),
          UserDetailsView(account: _focusedAccount!),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context, ref, _focusedAccount!),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text('accounts_remove_button'.tr(),
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
        title: Text('accounts_remove_title'.tr()),
        content: Text('accounts_remove_confirm'.tr(namedArgs: {'username': account.username ?? 'Unknown'})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('accounts_remove_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider.notifier).removeAccount(account.id);
              Navigator.pop(context);
              setState(() {
                _focusedAccount = null; // Reset focus
              });
            },
            child: Text('accounts_remove_confirm_button'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AccountAvatarItem extends StatelessWidget {
  final Account account;
  final bool isActive;
  final bool isFocused;
  final Color activeColor;
  final VoidCallback onTap;

  const _AccountAvatarItem({
    required this.account,
    required this.isActive,
    required this.isFocused,
    required this.activeColor,
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
              color: isActive ? activeColor : (isFocused ? Theme.of(context).colorScheme.primary : Colors.transparent),
              width: 2,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ] : null,
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
