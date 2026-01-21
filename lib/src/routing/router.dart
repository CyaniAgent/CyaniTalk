import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/misskey/presentation/misskey_page.dart';
import '../features/cloud/presentation/cloud_page.dart';
import '../features/forum/presentation/forum_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../shared/widgets/responsive_shell.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/misskey',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/misskey',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MisskeyPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/forum',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ForumPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cloud',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CloudPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NotificationsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
