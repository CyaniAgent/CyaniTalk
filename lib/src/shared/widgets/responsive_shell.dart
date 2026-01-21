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
          label: 'Misskey',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: 'Flarum',
        ),
        NavigationDestination(
          icon: Icon(Icons.cloud_queue_outlined),
          selectedIcon: Icon(Icons.cloud_queue),
          label: 'Drive',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Me',
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
