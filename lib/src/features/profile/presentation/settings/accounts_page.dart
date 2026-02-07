import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/core.dart';
import '../widgets/associated_accounts_section.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const mikuColor = SaucePalette.mikuGreen;
    final theme = Theme.of(context);

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
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Container(
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
                child: Opacity(
                  opacity: 0.1,
                  child: Center(
                    child: Icon(
                      Icons.manage_accounts,
                      size: 150,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: AssociatedAccountsSection(),
            ),
          ),
        ],
      ),
    );
  }
}
