import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MisskeyAnnouncementsPage extends StatelessWidget {
  const MisskeyAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('misskey_announcements_none'.tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}
