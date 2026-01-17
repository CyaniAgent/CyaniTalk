import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

class ResponsiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useDrawer: false,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.public_outlined),
          selectedIcon: Icon(Icons.public),
          label: 'Timeline',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: 'Forum',
        ),
        NavigationDestination(
          icon: Icon(Icons.cloud_queue_outlined),
          selectedIcon: Icon(Icons.cloud_queue),
          label: 'Cloud',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      body: (_) => navigationShell,
      smallBody: (_) => navigationShell,
      // Define breakpoints if necessary, defaults are usually fine.
      // < 600: BottomNav
      // >= 600: NavRail
    );
  }
}
