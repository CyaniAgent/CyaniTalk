// 应用程序路由配置
//
// 该文件包含应用程序的路由配置，使用go_router管理导航，
// 定义了应用程序的各个页面路由和初始位置。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/logger.dart';

import '../features/misskey/presentation/misskey_page.dart';
import '../features/misskey/presentation/pages/misskey_user_profile_page.dart';
import '../features/misskey/presentation/pages/misskey_notifications_page.dart';
import '../features/cloud/presentation/cloud_page.dart';
import '../features/forum/presentation/forum_page.dart';
import '../features/messaging/presentation/chat_page.dart';
import '../shared/widgets/coming_soon_page.dart';
import '../features/misskey/domain/misskey_user.dart';
import '../features/misskey/domain/chat_room.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/settings/about_page.dart';
import '../features/profile/presentation/settings/settings_page.dart';
import '../features/profile/presentation/settings/licenses_page.dart';
import '../features/search/presentation/search_page.dart';
import '../shared/widgets/responsive_shell.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// 提供应用程序的GoRouter实例
///
/// 定义了应用程序的所有路由配置，包括初始位置和各个页面的路由路径。
/// 使用StatefulShellRoute实现底部导航栏的状态保持。
///
/// [ref] - Riverpod的Ref，用于访问和监听状态
///
/// 返回配置好的GoRouter实例
@riverpod
GoRouter goRouter(Ref ref) {
  logger.info('Router: Initializing GoRouter with initial location: /misskey');
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/misskey',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          logger.debug(
            'Router: StatefulShellRoute builder called for path: ${state.path}',
          );
          return ResponsiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/misskey',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const MisskeyPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: AnimatedBuilder(
                          animation: secondaryAnimation,
                          builder: (context, child) {
                            return ExcludeSemantics(
                              excluding: !secondaryAnimation.isDismissed,
                              child: child!,
                            );
                          },
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/forum',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ForumPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: AnimatedBuilder(
                          animation: secondaryAnimation,
                          builder: (context, child) {
                            return ExcludeSemantics(
                              excluding: !secondaryAnimation.isDismissed,
                              child: child!,
                            );
                          },
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cloud',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const CloudPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: AnimatedBuilder(
                          animation: secondaryAnimation,
                          builder: (context, child) {
                            return ExcludeSemantics(
                              excluding: !secondaryAnimation.isDismissed,
                              child: child!,
                            );
                          },
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messaging',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ComingSoonPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: AnimatedBuilder(
                          animation: secondaryAnimation,
                          builder: (context, child) {
                            return ExcludeSemantics(
                              excluding: !secondaryAnimation.isDismissed,
                              child: child!,
                            );
                          },
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ProfilePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: AnimatedBuilder(
                          animation: secondaryAnimation,
                          builder: (context, child) {
                            return ExcludeSemantics(
                              excluding: !secondaryAnimation.isDismissed,
                              child: child!,
                            );
                          },
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // Top-level routes that don't have the navigation shell
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/licenses',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LicensesPage(),
      ),
      GoRoute(
        path: '/misskey/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MisskeyNotificationsPage(),
      ),
      GoRoute(
        path: '/misskey/user/:userId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return MisskeyUserProfilePage(userId: userId, initialUser: user);
        },
      ),
      GoRoute(
        path: '/messaging/chat/:userId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return ChatPage(id: userId, type: ChatType.direct, initialData: user);
        },
      ),
      GoRoute(
        path: '/messaging/chat/room/:roomId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final room = state.extra as ChatRoom?;
          return ChatPage(id: roomId, type: ChatType.room, initialData: room);
        },
      ),
    ],
  );
}
