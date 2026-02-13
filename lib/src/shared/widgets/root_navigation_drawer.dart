import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_service.dart';
import '../../features/auth/domain/account.dart';
import '../../features/misskey/application/misskey_notifier.dart';
import '../../features/flarum/application/flarum_providers.dart';
import '../../core/navigation/navigation.dart';

class RootNavigationDrawer extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const RootNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationSettings = ref.watch(navigationSettingsProvider).value;
    
    // Accounts info
    final misskeyAccount = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final flarumAccount = ref.watch(selectedFlarumAccountProvider).asData?.value;
    
    final misskeyUser = misskeyAccount != null ? ref.watch(misskeyMeProvider).asData?.value : null;
    final flarumUser = flarumAccount != null ? ref.watch(flarumCurrentUserProvider).asData?.value : null;

    final destinations = navigationSettings?.items
        .where((item) => item.isEnabled)
        .toList() ?? [];

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.of(context).maybePop();
      },
      children: [
        _buildHeader(context, ref, misskeyAccount, misskeyUser, flarumAccount, flarumUser),
        const Divider(indent: 12, endIndent: 12),
        ...destinations.map((item) {
          return NavigationDrawerDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.title),
          );
        }),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(context, misskeyAccount, misskeyUser, flarumAccount, flarumUser),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.switch_account_outlined),
                onPressed: () => context.push('/profile'),
                tooltip: 'profile_unified_login_manager'.tr(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUserInfo(context, misskeyAccount, misskeyUser, flarumAccount, flarumUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser,
  ) {
    final avatarUrl = misskeyUser?.avatarUrl ?? misskeyAccount?.avatarUrl ?? flarumUser?.avatarUrl ?? flarumAccount?.avatarUrl;
    
    return CircleAvatar(
      radius: 32,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null ? const Icon(Icons.person, size: 32) : null,
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser,
  ) {
    final theme = Theme.of(context);
    String name = 'CyaniUser';
    String handle = '';
    
    if (misskeyAccount != null) {
      name = misskeyUser?.name ?? misskeyAccount.name ?? misskeyAccount.username ?? 'Misskey User';
      handle = '@${misskeyAccount.username}@${misskeyAccount.host}';
    } else if (flarumAccount != null) {
      name = flarumUser?.displayName ?? flarumAccount.name ?? flarumAccount.username ?? 'Flarum User';
      handle = '@${flarumAccount.username}@${flarumAccount.host}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          handle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
