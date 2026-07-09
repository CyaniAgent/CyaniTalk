import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/features/auth/domain/misskey_permissions.dart';

/// Misskey API 权限查看器
///
/// 以 Bottom Sheet / Side Sheet 形式展示所有权限信息
class MisskeyPermissionsSheet extends StatefulWidget {
  const MisskeyPermissionsSheet({super.key, this.scrollController});

  /// 显示权限查看器
  static void show(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 600) {
      // 桌面端使用 Side Sheet
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
            child: const MisskeyPermissionsSheet(),
          ),
        ),
      );
    } else {
      // 移动端使用 Bottom Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) =>
              MisskeyPermissionsSheet(scrollController: scrollController),
        ),
      );
    }
  }

  final ScrollController? scrollController;

  @override
  State<MisskeyPermissionsSheet> createState() =>
      _MisskeyPermissionsSheetState();
}

class _MisskeyPermissionsSheetState extends State<MisskeyPermissionsSheet> {
  bool _showAdminOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const groups = MisskeyPermissions.permissionGroups;

    // 过滤权限组
    final filteredGroups = <String, List<PermissionEntry>>{};
    for (final entry in groups.entries) {
      final filtered = entry.value.where((p) {
        if (_showAdminOnly && !p.isAdmin) return false;
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return p.scope.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query);
        }
        return true;
      }).toList();
      if (filtered.isNotEmpty) {
        filteredGroups[entry.key] = filtered;
      }
    }

    return Column(
      children: [
        // 拖拽指示器
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'misskey_permissions_title'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                tooltip: 'misskey_permissions_docs'.tr(),
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://misskey-hub.net/cn/docs/for-developers/api/permission/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // 搜索栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'misskey_permissions_search'.tr(),
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        // 筛选开关
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            children: [
              FilterChip(
                label: Text('misskey_permissions_admin_only'.tr()),
                avatar: const Icon(Icons.shield, size: 16),
                selected: _showAdminOnly,
                onSelected: (v) => setState(() => _showAdminOnly = v),
              ),
              const Spacer(),
              Text(
                '${filteredGroups.values.expand((e) => e).length} '
                'misskey_permissions_count'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 权限列表
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: filteredGroups.length + 1, // +1 for footer
            itemBuilder: (context, index) {
              if (index == filteredGroups.length) {
                // 底部提示
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 24,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'misskey_permissions_coming_soon'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final groupName = filteredGroups.keys.elementAt(index);
              final permissions = filteredGroups[groupName]!;
              final isAdminGroup = groupName == 'admin';

              return _PermissionGroup(
                groupName: groupName,
                permissions: permissions,
                isAdminGroup: isAdminGroup,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  final String groupName;
  final List<PermissionEntry> permissions;
  final bool isAdminGroup;

  const _PermissionGroup({
    required this.groupName,
    required this.permissions,
    required this.isAdminGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: isAdminGroup
          ? Icon(Icons.shield, color: theme.colorScheme.error, size: 20)
          : null,
      title: Text(
        groupName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isAdminGroup ? theme.colorScheme.error : null,
        ),
      ),
      children: permissions.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.isAdmin
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.scope,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (p.isAdmin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'misskey_permissions_admin'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
