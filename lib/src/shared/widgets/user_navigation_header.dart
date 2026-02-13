import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/auth/application/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/account.dart';
import '../../features/misskey/application/misskey_notifier.dart';
import '../../features/flarum/application/flarum_providers.dart';

class UserNavigationHeader extends ConsumerWidget {
  final bool isExtended;
  final bool isDrawer;

  UserNavigationHeader({
    super.key,
    this.isExtended = true,
    this.isDrawer = false,
  });

  /// 用于获取用户信息部分的位置
  final _userInfoKey = GlobalKey();

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
          key: _userInfoKey,
          onTap: () => _showUserMenu(context, ref, isLoggedIn),
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
        key: _userInfoKey,
        onTap: () => _showUserMenu(context, ref, isLoggedIn),
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
    final RenderBox renderBox = _userInfoKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 计算菜单位置
    final offset = Offset(position.dx, position.dy + size.height);

    // 显示弹出菜单
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + size.width, offset.dy),
      items: <PopupMenuEntry<String>>[
        // 用户页面选项
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              Text('menu_user_profile'.tr()),
            ],
          ),
        ),
        // 设置页面选项
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              Text('menu_settings'.tr()),
            ],
          ),
        ),
        // 分隔线
        const PopupMenuDivider(),
        // 登录或退出登录选项
        if (isLoggedIn)
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text('menu_logout'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ),
          )
        else
          PopupMenuItem<String>(
            value: 'login',
            child: Row(
              children: [
                Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('menu_login'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
      ],
    ).then((value) {
      // 处理菜单选项
      if (value != null) {
        switch (value) {
          case 'profile':
            context.push('/profile');
            break;
          case 'settings':
            context.push('/settings');
            break;
          case 'logout':
            // 退出登录逻辑
            _logout(context, ref);
            break;
          case 'login':
            // 登录逻辑
            context.push('/profile');
            break;
        }
      }
    });
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
              
              Navigator.of(context).pop();
            },
            child: Text('menu_logout'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
