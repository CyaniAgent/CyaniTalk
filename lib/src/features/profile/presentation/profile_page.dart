import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/associated_accounts_section.dart';
import 'settings/settings_page.dart';
import '../../auth/application/auth_service.dart';

/// 用户个人资料主页面组件
///
/// 显示用户的个人资料信息，包括关联账户列表和设置入口。
class ProfilePage extends ConsumerWidget {
  /// 创建一个新的ProfilePage实例
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mikuColor = const Color(0xFF39C5BB);
    final selectedMisskey = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;
    final selectedFlarum = ref
        .watch(selectedFlarumAccountProvider)
        .asData
        ?.value;

    // Use the first active account for the header if available
    final primaryAccount = selectedMisskey ?? selectedFlarum;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: mikuColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'profile_unified_login_manager'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          mikuColor,
                          mikuColor.withValues(alpha: 0.8),
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                  // Subtle Pattern Overlay (optional/mock)
                  Opacity(
                    opacity: 0.1,
                    child: Center(
                      child: Icon(
                        Icons.star_border_purple500,
                        size: 300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (primaryAccount?.avatarUrl != null)
                    Opacity(
                      opacity: 0.2,
                      child: Image.network(
                        primaryAccount!.avatarUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: 'profile_settings'.tr(),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: const AssociatedAccountsSection(),
            ),
          ),
          // Add some bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
