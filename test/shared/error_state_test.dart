import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/shared/widgets/error_state.dart';

/// ErrorState（Todo 4，C3 新增共享组件）的 widget 测试：
/// message / retry 按钮 / 点击回调 / icon 颜色 / 缺省回退。
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('渲染 message 与重试按钮', (tester) async {
    await tester.pumpWidget(
      wrap(
        ErrorState(
          message: '测试错误',
          retryLabel: '重试',
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('测试错误'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('点击重试按钮触发 onRetry 回调', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(
        ErrorState(
          message: '测试错误',
          retryLabel: '重试',
          onRetry: () => retried = true,
        ),
      ),
    );

    await tester.tap(find.text('重试'));
    expect(retried, isTrue);
  });

  testWidgets('Icon 颜色使用 colorScheme.error', (tester) async {
    await tester.pumpWidget(wrap(const ErrorState(message: '测试错误')));

    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    final scheme = Theme.of(tester.element(find.byType(ErrorState))).colorScheme;
    expect(icon.color, scheme.error);
  });

  testWidgets('未提供 onRetry 时不渲染按钮', (tester) async {
    await tester.pumpWidget(wrap(const ErrorState(message: '测试错误')));
    expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
  });

  testWidgets('message 缺省时回退到 common_error_occurred', (tester) async {
    await tester.pumpWidget(wrap(const ErrorState()));
    // 测试环境未初始化 easy_localization，tr() 原样返回 key
    expect(find.text('common_error_occurred'), findsOneWidget);
  });

  testWidgets('自定义 icon 生效', (tester) async {
    await tester.pumpWidget(
      wrap(const ErrorState(message: '网络异常', icon: Icons.wifi_off)),
    );
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
}
