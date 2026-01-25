import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FlarumDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const FlarumDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'flarum_drawer_menu_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.forum_outlined),
          selectedIcon: const Icon(Icons.forum),
          label: Text('flarum_drawer_discussions'.tr()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.label_outlined),
          selectedIcon: const Icon(Icons.label),
          label: Text('flarum_drawer_tags'.tr()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
          label: Text('flarum_drawer_notifications'.tr()),
        ),
      ],
    );
  }
}
