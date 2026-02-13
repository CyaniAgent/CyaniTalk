import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_service.dart';
import '../../features/auth/domain/account.dart';
import '../../features/misskey/application/misskey_notifier.dart';
import '../../features/flarum/application/flarum_providers.dart';

class UserNavigationHeader extends ConsumerWidget {
  final bool isExtended;
  final bool isDrawer;

  const UserNavigationHeader({
    super.key,
    this.isExtended = true,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accounts info
    final misskeyAccount = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final flarumAccount = ref.watch(selectedFlarumAccountProvider).asData?.value;
    
    final misskeyUser = misskeyAccount != null ? ref.watch(misskeyMeProvider).asData?.value : null;
    final flarumUser = flarumAccount != null ? ref.watch(flarumCurrentUserProvider).asData?.value : null;

    final bool isLoggedIn = misskeyAccount != null || flarumAccount != null;

    if (!isExtended && !isDrawer) {
      const double radius = 24;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InkWell(
          onTap: () => context.push('/profile'),
          borderRadius: BorderRadius.circular(radius),
          child: _buildAvatar(context, misskeyAccount, misskeyUser, flarumAccount, flarumUser, radius: radius),
        ),
      );
    }

    Widget content = Container(
      padding: isDrawer 
          ? const EdgeInsets.fromLTRB(16, 48, 16, 16)
          : const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _buildAvatar(context, misskeyAccount, misskeyUser, flarumAccount, flarumUser, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLoggedIn 
                      ? _getUserName(misskeyAccount, misskeyUser, flarumAccount, flarumUser)
                      : 'nav_no_account'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isDrawer) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256),
        child: content,
      );
    }

    return content;
  }

  String _getUserName(
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser,
  ) {
    if (misskeyAccount != null) {
      return misskeyUser?.name ?? misskeyAccount.name ?? misskeyAccount.username ?? 'Misskey User';
    } else if (flarumAccount != null) {
      return flarumUser?.displayName ?? flarumAccount.name ?? flarumAccount.username ?? 'Flarum User';
    }
    return 'CyaniUser';
  }

  Widget _buildAvatar(
    BuildContext context,
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser, {
    double radius = 32,
  }) {
    final avatarUrl = misskeyUser?.avatarUrl ?? misskeyAccount?.avatarUrl ?? flarumUser?.avatarUrl ?? flarumAccount?.avatarUrl;
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null 
          ? Icon(
              Icons.account_circle, // Google's Material Design default image
              size: radius * 2, 
              color: Theme.of(context).colorScheme.primary
            ) 
          : null,
    );
  }
}
