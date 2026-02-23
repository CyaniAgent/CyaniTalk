import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/auth/application/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/account.dart';
import '../../features/misskey/application/misskey_notifier.dart';
import '../../features/misskey/application/misskey_notifications_notifier.dart';
import '../../features/flarum/application/flarum_providers.dart';

class UserNavigationHeader extends ConsumerWidget {
  final bool isExtended;
  final bool isDrawer;
  final bool isSelected;
  final VoidCallback? onTap;

  UserNavigationHeader({
    super.key,
    this.isExtended = true,
    this.isDrawer = false,
    this.isSelected = false,
    this.onTap,
  });

  /// 用于获取用户信息部分的位置
  final _userInfoKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accounts info
    final misskeyAccount = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;
    final flarumAccount = ref
        .watch(selectedFlarumAccountProvider)
        .asData
        ?.value;

    final misskeyUser = misskeyAccount != null
        ? ref.watch(misskeyMeProvider).asData?.value
        : null;
    final flarumUser = flarumAccount != null
        ? ref.watch(flarumCurrentUserProvider).asData?.value
        : null;

    final bool isLoggedIn = misskeyAccount != null || flarumAccount != null;
    final theme = Theme.of(context);

    if (!isExtended && !isDrawer) {
      const double radius = 24;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InkWell(
          key: _userInfoKey,
          onTap: onTap ?? () => _showUserMenu(context, ref, isLoggedIn),
          onLongPress: () => _showUserMenu(context, ref, isLoggedIn),
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.secondaryContainer
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: _buildAvatar(
              context,
              misskeyAccount,
              misskeyUser,
              flarumAccount,
              flarumUser,
              radius: radius,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: isDrawer
          ? const EdgeInsets.fromLTRB(12, 48, 12, 8)
          : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              onLongPress: () => _showUserMenu(context, ref, isLoggedIn),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildAvatar(
                      context,
                      misskeyAccount,
                      misskeyUser,
                      flarumAccount,
                      flarumUser,
                      radius: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLoggedIn
                            ? _getUserName(
                                misskeyAccount,
                                misskeyUser,
                                flarumAccount,
                                flarumUser,
                              )
                            : 'nav_no_account'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            key: _userInfoKey,
            onTap: () => _showUserMenu(context, ref, isLoggedIn),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserName(
    Account? misskeyAccount,
    dynamic misskeyUser,
    Account? flarumAccount,
    dynamic flarumUser,
  ) {
    if (misskeyAccount != null) {
      return misskeyUser?.name ??
          misskeyAccount.name ??
          misskeyAccount.username ??
          'Misskey User';
    } else if (flarumAccount != null) {
      return flarumUser?.displayName ??
          flarumAccount.name ??
          flarumAccount.username ??
          'Flarum User';
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
    final avatarUrl =
        misskeyUser?.avatarUrl ??
        misskeyAccount?.avatarUrl ??
        flarumUser?.avatarUrl ??
        flarumAccount?.avatarUrl;

    if (avatarUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.account_circle,
              size: radius * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.account_circle,
              size: radius * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.account_circle,
          size: radius * 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  /// 显示用户菜单
  void _showUserMenu(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    // 获取用户信息部分的位置
    final RenderBox renderBox =
        _userInfoKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 计算菜单位置
    final offset = Offset(position.dx, position.dy + size.height);

    if (!isLoggedIn) {
      // 未登录时显示登录选项
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          offset.dx + size.width,
          offset.dy,
        ),
        items: <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'login',
            child: Row(
              children: [
                Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'menu_login'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).then((value) {
        if (!context.mounted) return;
        if (value == 'login') {
          context.push('/profile');
        }
      });
      return;
    }

    // 获取所有账户
    final accountsAsync = ref.watch(authServiceProvider);

    accountsAsync.when(
      data: (accounts) {
        final selectedMisskey = ref
            .read(selectedMisskeyAccountProvider)
            .asData
            ?.value;
        final selectedFlarum = ref
            .read(selectedFlarumAccountProvider)
            .asData
            ?.value;

        // 按主机分组账户
        final Map<String, List<Account>> accountsByHost = {};
        for (final account in accounts) {
          final host = account.host;
          if (!accountsByHost.containsKey(host)) {
            accountsByHost[host] = [];
          }
          accountsByHost[host]!.add(account);
        }

        // 构建账户菜单项
        final List<PopupMenuEntry<String>> items = [];

        // 遍历每个主机的账户
        for (final host in accountsByHost.keys) {
          final hostAccounts = accountsByHost[host]!;

          // 添加主机分组标题
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              height: 32,
              child: Text(
                host,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );

          // 添加该主机的账户
          for (final account in hostAccounts) {
            final isMisskeyActive = account.id == selectedMisskey?.id;
            final isFlarumActive = account.id == selectedFlarum?.id;
            final isActive = isMisskeyActive || isFlarumActive;

            items.add(
              PopupMenuItem<String>(
                value: account.id,
                enabled: !isActive,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: account.avatarUrl != null
                          ? NetworkImage(account.avatarUrl!)
                          : null,
                      child: account.avatarUrl == null
                          ? Text(account.username?[0].toUpperCase() ?? '?')
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.name ?? account.username ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '@${account.username}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }

          // 如果不是最后一个主机，添加分隔线
          if (host != accountsByHost.keys.last) {
            items.add(const PopupMenuDivider(height: 8));
          }
        }

        // 添加分隔线和其他选项
        items.addAll([
          const PopupMenuDivider(height: 16),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'menu_logout'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        ]);

        // 显示菜单
        showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            offset.dx + size.width,
            offset.dy,
          ),
          items: items,
        ).then((value) {
          if (!context.mounted) return;

          if (value != null) {
            if (value == 'logout') {
              _logout(context, ref);
            } else {
              // 切换账户
              final account = accounts.firstWhere((a) => a.id == value);
              if (account.platform == 'misskey') {
                ref
                    .read(selectedMisskeyAccountProvider.notifier)
                    .select(account);
                // 刷新Misskey相关provider
                ref.invalidate(misskeyTimelineProvider);
                ref.invalidate(misskeyMeProvider);
                ref.invalidate(misskeyNotificationsProvider);
                // 刷新当前路由
                if (context.mounted) {
                  final router = GoRouter.of(context);
                  context.go(
                    router.routeInformationProvider.value.uri.toString(),
                  );
                }
              } else if (account.platform == 'flarum') {
                ref
                    .read(selectedFlarumAccountProvider.notifier)
                    .select(account);
                // 刷新Flarum相关provider
                ref.invalidate(flarumCurrentUserProvider);
                // 刷新当前路由
                if (context.mounted) {
                  final router = GoRouter.of(context);
                  context.go(
                    router.routeInformationProvider.value.uri.toString(),
                  );
                }
              }
            }
          }
        });
      },
      loading: () {},
      error: (err, stack) {},
    );
  }

  /// 退出登录
  void _logout(BuildContext context, WidgetRef ref) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('menu_logout_confirm'.tr()),
        content: Text('menu_logout_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              // 退出所有账号
              final authRepository = ref.read(authRepositoryProvider);
              final accounts = await authRepository.getAccounts();

              // 逐个删除所有账户
              for (final account in accounts) {
                await authRepository.removeAccount(account.id);
              }

              // 清除选中的账户ID
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.remove('cyani_selected_misskey_id');
              await prefs.remove('cyani_selected_flarum_id');

              // 刷新认证服务状态
              await ref.read(authServiceProvider.future);

              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: Text(
              'menu_logout'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
