import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:Nyachi/src/features/auth/application/auth_service.dart';
import 'package:Nyachi/src/features/auth/data/auth_repository.dart';
import 'package:Nyachi/src/features/misskey/application/misskey_notifier.dart';
import 'package:Nyachi/src/features/misskey/data/misskey_repository.dart';
import 'package:Nyachi/src/core/utils/download_utils.dart';
import 'package:Nyachi/src/core/utils/logger.dart';

/// 头像菜单卡片组件
///
/// 点击 AppBar 中的头像后弹出，包含三部分：
/// - 上部：头像、昵称、用户名（user@example.com），点击进入个人资料
/// - 中部：云盘使用额度
/// - 下部：通知、二维码、设置、登出按钮
class AvatarMenuCard extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;

  const AvatarMenuCard({super.key, this.onDismiss});

  @override
  ConsumerState<AvatarMenuCard> createState() => _AvatarMenuCardState();
}

class _AvatarMenuCardState extends ConsumerState<AvatarMenuCard> {
  int _driveUsageBytes = 0;
  int _driveCapacityBytes = 0;
  bool _isLoadingDrive = true;

  @override
  void initState() {
    super.initState();
    _loadDriveInfo();
  }

  Future<void> _loadDriveInfo() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final driveInfo = await repository.getDriveInfo();
      if (mounted) {
        setState(() {
          _driveUsageBytes = (driveInfo['usage'] as num? ?? 0).toInt();
          _driveCapacityBytes = (driveInfo['capacity'] as num? ?? 0).toInt();
          _isLoadingDrive = false;
        });
      }
    } catch (e) {
      logger.error('AvatarMenuCard: Error loading drive info: $e');
      if (mounted) {
        setState(() => _isLoadingDrive = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final misskeyAccount = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final misskeyUser = ref.watch(misskeyMeProvider).asData?.value;

    if (misskeyAccount == null) return const SizedBox.shrink();

    final displayName = misskeyUser?.name ?? misskeyAccount.username ?? '';
    final userName = misskeyAccount.username ?? '';
    final host = misskeyAccount.host;
    final avatarUrl = misskeyUser?.avatarUrl ?? misskeyAccount.avatarUrl;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(40),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === 上部：用户信息 ===
            _buildUserSection(
              context,
              theme,
              displayName: displayName,
              userName: userName,
              host: host,
              avatarUrl: avatarUrl,
              userId: misskeyUser?.id ?? misskeyAccount.id,
            ),

            const Divider(height: 1),

            // === 中部：云盘使用额度 ===
            _buildDriveSection(context, theme),

            const Divider(height: 1),

            // === 下部：操作按钮 ===
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  /// 上部：头像 + 昵称 + 用户名
  Widget _buildUserSection(
    BuildContext context,
    ThemeData theme, {
    required String displayName,
    required String userName,
    required String host,
    required String? avatarUrl,
    required String userId,
  }) {
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      onTap: () {
        widget.onDismiss?.call();
        context.push('/misskey/user/$userId');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Icon(Icons.person, size: 32, color: theme.colorScheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 12),
            // 昵称 + 用户名
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$userName@$host',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 中部：云盘使用额度
  Widget _buildDriveSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 右上方显示 "已使用 / 总容量"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'cloud_drive_space'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _isLoadingDrive
                    ? '...'
                    : '${_formatBytes(_driveUsageBytes)} / ${_formatBytes(_driveCapacityBytes)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 使用条
          if (_isLoadingDrive)
            const LinearProgressIndicator(minHeight: 8)
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _driveCapacityBytes > 0
                    ? (_driveUsageBytes / _driveCapacityBytes).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
    );
  }

  /// 下部：操作按钮
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          _ActionButton(
            icon: Icons.notifications_outlined,
            label: 'settings_notifications_title'.tr(),
            onTap: () {
              widget.onDismiss?.call();
              context.push('/misskey/notifications');
            },
          ),
          _ActionButton(
            icon: Icons.qr_code,
            label: 'avatar_menu_qr_code'.tr(),
            onTap: () {
              widget.onDismiss?.call();
              // TODO: 二维码功能待实现
            },
          ),
          _ActionButton(
            icon: Icons.settings_outlined,
            label: 'settings_title'.tr(),
            onTap: () {
              widget.onDismiss?.call();
              context.push('/settings');
            },
          ),
          _ActionButton(
            icon: Icons.logout,
            label: 'menu_logout'.tr(),
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
            onTap: () {
              widget.onDismiss?.call();
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    return DownloadUtils.formatFileSize(bytes);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('menu_logout_confirm'.tr()),
        content: Text('menu_logout_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authRepository = ref.read(authRepositoryProvider);
              final accounts = await authRepository.getAccounts();
              for (final account in accounts) {
                await authRepository.removeAccount(account.id);
              }
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.remove('cyani_selected_misskey_id');
              await ref.read(authServiceProvider.future);
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

/// 操作按钮子组件
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
