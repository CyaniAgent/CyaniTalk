import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/features/profile/presentation/widgets/associated_accounts_section.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile_unified_login_manager'.tr())),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 16,
            ),
            child: const AssociatedAccountsSection(),
          ),
        ),
      ),
    );
  }
}
