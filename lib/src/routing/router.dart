// 应用程序路由配置
//
// 该文件包含应用程序的路由配置，使用go_router管理导航，
// 定义了应用程序的各个页面路由和初始位置。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Nyachi/src/core/utils/logger.dart';
import 'package:Nyachi/src/features/auth/presentation/pages/login_page.dart';
import 'package:Nyachi/src/features/cloud/presentation/cloud_page.dart';
import 'package:Nyachi/src/features/messaging/presentation/chat_page.dart';
import 'package:Nyachi/src/features/messaging/presentation/messaging_page.dart';
import 'package:Nyachi/src/features/misskey/domain/chat_room.dart';
import 'package:Nyachi/src/features/misskey/domain/misskey_user.dart';
import 'package:Nyachi/src/features/misskey/presentation/misskey_page.dart';
import 'package:Nyachi/src/features/misskey/presentation/pages/misskey_notifications_page.dart';
import 'package:Nyachi/src/features/misskey/presentation/pages/misskey_user_profile_page.dart';
import 'package:Nyachi/src/features/profile/application/developer_settings_provider.dart';
import 'package:Nyachi/src/shared/widgets/error_state.dart';
import 'package:Nyachi/src/features/profile/presentation/settings/about_page.dart';
import 'package:Nyachi/src/features/profile/presentation/settings/developer_settings_page.dart';
import 'package:Nyachi/src/features/profile/presentation/settings/licenses_page.dart';
import 'package:Nyachi/src/features/profile/presentation/settings/settings_page.dart';
import 'package:Nyachi/src/features/search/presentation/search_page.dart';
import 'package:Nyachi/src/features/welcome/application/welcome_state.dart';
import 'package:Nyachi/src/features/welcome/presentation/welcome_page.dart';
import 'package:Nyachi/src/shared/widgets/coming_soon_page.dart';
import 'package:Nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:Nyachi/src/shared/widgets/responsive_shell.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final routerRefreshNotifier = ValueNotifier<int>(0);

/// 安全构建页面。
///
/// 使用 [MaterialPage] 平台默认转场（Windows/Linux/Android 为
/// ZoomPageTransitionsBuilder，macOS/iOS 为 CupertinoPageTransitionsBuilder）。
///
/// 注：原实现使用 CustomTransitionPage（fade+slide）并在转场期间包
/// ExcludeSemantics 屏蔽语义树，防止 Windows AXTree 报错。Flutter 3.44
/// 平台默认转场已修复大部分 AXTree 问题，故不再保留该防护；若 Windows
/// 上出现 AXTree 相关崩溃，需重新评估转场期间的语义处理。
Page<T> _buildSafePage<T>({
  required LocalKey key,
  required Widget child,
  bool fullScreenDialog = false,
}) {
  return MaterialPage<T>(
    key: key,
    fullscreenDialog: fullScreenDialog,
    child: child,
  );
}

/// 根据开发者模式状态返回消息相关页面
///
/// 开发者模式未开启时显示 ComingSoonPage，防止未授权访问消息功能。
Widget _buildDeveloperGuardedPage(Widget child) {
  return Consumer(
    builder: (context, ref, _) {
      final developerModeAsync = ref.watch(developerSettingsProvider);

      return developerModeAsync.when(
        data: (developerMode) {
          if (developerMode) {
            return child;
          }
          return const ComingSoonPage();
        },
        loading: () => const Scaffold(
          body: Center(child: CyaniLoadingIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: ErrorState(message: err.toString()),
        ),
      );
    },
  );
}

/// 消息主页（开发者模式开启时显示）
Widget _buildMessagingPage(BuildContext context, GoRouterState state) {
  return _buildDeveloperGuardedPage(const MessagingPage());
}

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
  logger.info('Router: Initializing GoRouter');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/misskey',
    refreshListenable: routerRefreshNotifier,
    redirect: (context, state) {
      final welcomeDone = ref.read(welcomeCompletedProvider).asData?.value ?? false;
      final location = state.uri.toString();

      // 未完成欢迎页 → 强制跳转 /welcome
      if (!welcomeDone && location != '/welcome') {
        return '/welcome';
      }
      // 已完成欢迎页但在 /welcome → 跳转首页
      if (welcomeDone && location == '/welcome') {
        return '/misskey';
      }
      return null;
    },
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
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: const MisskeyPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cloud',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: const CloudPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messaging',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: _buildMessagingPage(context, state),
                ),
              ),
            ],
          ),
        ],
      ),
      // Top-level routes that don't have the navigation shell
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const WelcomePage()),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const SearchPage()),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const AboutPage()),
      ),
      GoRoute(
        path: '/licenses',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const LicensesPage()),
      ),
      GoRoute(
        path: '/developer',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const DeveloperSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/misskey/notifications',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const MisskeyNotificationsPage(),
        ),
      ),
      GoRoute(
        path: '/misskey/user/:userId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return _buildSafePage(
            key: state.pageKey,
            child: MisskeyUserProfilePage(userId: userId, initialUser: user),
          );
        },
      ),
      GoRoute(
        path: '/messaging/chat/:userId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return _buildSafePage(
            key: state.pageKey,
            child: _buildDeveloperGuardedPage(
              ChatPage(
                id: userId,
                type: ChatType.direct,
                initialData: user,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/messaging/chat/room/:roomId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final room = state.extra as ChatRoom?;
          return _buildSafePage(
            key: state.pageKey,
            child: _buildDeveloperGuardedPage(
              ChatPage(
                id: roomId,
                type: ChatType.room,
                initialData: room,
              ),
            ),
          );
        },
      ),
    ],
  );
}
