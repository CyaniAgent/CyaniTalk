import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/shared/widgets/login_reminder.dart';

class ForumPage extends ConsumerWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        centerTitle: true,
      ),
      body: const LoginReminder(
        title: 'Forum',
        message: 'Forum is not available',
        icon: Icons.forum_outlined,
      ),
    );
  }
}