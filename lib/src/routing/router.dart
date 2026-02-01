// 应用程序路由配置
//
// 该文件包含应用程序的路由配置，使用go_router管理导航，
// 定义了应用程序的各个页面路由和初始位置。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/logger.dart';

import '../features/misskey/presentation/misskey_page.dart';
import '../features/cloud/presentation/cloud_page.dart';
import '../features/forum/presentation/forum_page.dart';
import '../features/messaging/presentation/messaging_history_page.dart';
import '../features/messaging/presentation/messaging_chat_page.dart';
import '../features/misskey/domain/misskey_user.dart';
import '../features/profile/presentation/profile_page.dart';
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
                path: '/messaging',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MessagingHistoryPage()),
                routes: [
                  GoRoute(
                    path: 'chat/:userId',
                    builder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      final user = state.extra as MisskeyUser?;
                      return MessagingChatPage(
                        userId: userId,
                        initialUser: user,
                      );
                    },
                  ),
                ],
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
