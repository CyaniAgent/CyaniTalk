import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/shared/widgets/empty_state.dart';

/// EmptyState（Todo 4，C3 新增共享组件）的 widget 测试：
/// icon / title / subtitle / action 渲染与 icon 颜色。
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('渲染 icon/title/subtitle/action', (tester) async {
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.inbox,
          title: '空空如也',
          subtitle: '暂无数据',
          action: FilledButton(
            onPressed: () {},
            child: const Text('去上传'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.text('空空如也'), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.text('去上传'), findsOneWidget);
  });

  testWidgets('无 subtitle/action 时仅渲染 icon+title', (tester) async {
    await tester.pumpWidget(
      wrap(const EmptyState(icon: Icons.inbox, title: '空')),
    );

    expect(find.text('空'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('icon 颜色使用 colorScheme.outlineVariant', (tester) async {
    await tester.pumpWidget(
      wrap(const EmptyState(icon: Icons.inbox, title: '空')),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.inbox));
    final scheme = Theme.of(tester.element(find.byType(EmptyState))).colorScheme;
    expect(icon.color, scheme.outlineVariant);
  });
}
