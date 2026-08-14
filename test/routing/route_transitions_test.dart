import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Nyachi/src/core/utils/logger.dart';
import 'package:Nyachi/src/features/welcome/presentation/welcome_page.dart';
import 'package:Nyachi/src/routing/router.dart';

/// MD3 改造（Todo 3，路由转场改用平台默认）的回归测试：
/// - router.dart 的 `_buildSafePage` 使用 [MaterialPage]，全库无
///   [CustomTransitionPage] / transitionsBuilder
/// - pump 真实 goRouterProvider 初始路由（/welcome）无异常且页面出现，
///   并验证当前匹配路由的 pageBuilder 产物是 MaterialPage
void main() {
  setUpAll(logger.setupForTesting);

  group('路由转场使用 MaterialPage（无 CustomTransitionPage）', () {
    test('router.dart 的 _buildSafePage 返回 MaterialPage 且无自定义转场', () {
      final source = File('lib/src/routing/router.dart').readAsStringSync();
      expect(source, contains('_buildSafePage'));
      expect(source, contains('MaterialPage'));
      expect(source, isNot(contains('CustomTransitionPage<'))); // 代码引用均为泛型；注释中的历史说明除外
      expect(source, isNot(contains('transitionsBuilder')));
    });

    testWidgets('pump 真实 GoRouter 初始路由：无异常且页面出现', (tester) async {
      // 未完成欢迎页 → 重定向到 /welcome（不触发 StatefulShellRoute 分支）
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomePage), findsOneWidget);

      // 当前匹配路由的 pageBuilder 产物必须是 MaterialPage 而非 CustomTransitionPage
      final matches = router.routerDelegate.currentConfiguration.matches;
      expect(matches, isNotEmpty);
      final route = matches.last.route;
      expect(route, isA<GoRoute>());

      final state = GoRouterState(
        RouteConfiguration(
          ValueNotifier(
            RoutingConfig(
              routes: [
                GoRoute(
                  path: '/welcome',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          navigatorKey: GlobalKey<NavigatorState>(),
        ),
        uri: Uri.parse('/welcome'),
        matchedLocation: '/welcome',
        fullPath: '/welcome',
        pathParameters: const {},
        pageKey: const ValueKey('/welcome'),
      );

      final ctx = tester.element(find.byType(Scaffold).first);
      final page = (route as GoRoute).pageBuilder!(ctx, state);
      expect(page, isA<MaterialPage<dynamic>>());
      expect(page, isNot(isA<CustomTransitionPage<dynamic>>()));
    });
  });
}
