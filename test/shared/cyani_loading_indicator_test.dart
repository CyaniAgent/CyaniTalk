import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_core/m3e_core.dart';

import 'package:Nyachi/src/shared/widgets/cyani_loading_indicator.dart';

/// CyaniLoadingIndicator（Todo 6，C5 切换至 m3e_core loading）的 widget 测试。
///
/// 注意：m3e 组件使用 motor 弹簧动画（SpringSimulation），`pumpAndSettle`
/// 不会收敛，这里一律使用 bounded `pump(duration)` 有限推进。
void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('默认分支渲染 M3ELoadingIndicator（bounded pump）', (tester) async {
    await tester.pumpWidget(wrap(const CyaniLoadingIndicator()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(M3ELoadingIndicator), findsOneWidget);
    expect(find.byType(M3EContainedLoadingIndicator), findsNothing);
  });

  testWidgets('contained 分支渲染 M3EContainedLoadingIndicator', (tester) async {
    await tester.pumpWidget(
      wrap(const CyaniLoadingIndicator(contained: true, size: 32)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(M3EContainedLoadingIndicator), findsOneWidget);
    // M3EContainedLoadingIndicator 内部包裹 M3ELoadingIndicator
    expect(find.byType(M3ELoadingIndicator), findsOneWidget);
  });

  testWidgets('自定义 color/size 透传到 M3ELoadingIndicator', (tester) async {
    const color = Color(0xFF123456);
    await tester.pumpWidget(
      wrap(const CyaniLoadingIndicator(size: 64, color: color)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final indicator =
        tester.widget<M3ELoadingIndicator>(find.byType(M3ELoadingIndicator));
    expect(indicator.constraints, BoxConstraints.tight(const Size(64, 64)));
    expect(indicator.color, color);
  });

  testWidgets('contained 分支透传 width/height', (tester) async {
    await tester.pumpWidget(
      wrap(const CyaniLoadingIndicator(contained: true, size: 40)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final indicator = tester.widget<M3EContainedLoadingIndicator>(
      find.byType(M3EContainedLoadingIndicator),
    );
    expect(indicator.width, 40);
    expect(indicator.height, 40);
  });
}
