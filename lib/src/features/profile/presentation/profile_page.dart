import 'package:flutter/material.dart';
import 'widgets/associated_accounts_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: const [AssociatedAccountsSection()]),
      ),
    );
  }
}
