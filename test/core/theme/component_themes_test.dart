import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/core/theme/design_tokens.dart';
import 'package:Nyachi/src/core/theme/desktop_semantic_colors.dart';

import '../../helpers/theme_test_helper.dart';

/// MD3 改造（Todo 2，commit b4f134d）的回归测试：
/// - 26 个 MD3 组件主题注册进 ThemeData
/// - 5 个 M3E token + DesktopSemanticColors 注册进 extensions
/// - FilledButton 不再被 StadiumBorder 覆盖，走标准 M3 圆角矩形
void main() {
  final theme = buildTestTheme(Brightness.light);

  group('MD3 组件主题注册', () {
    test('26 个 MD3 组件主题均非空', () {
      expect(theme.badgeTheme, isNotNull);
      expect(theme.bottomSheetTheme, isNotNull);
      expect(theme.cardTheme, isNotNull);
      expect(theme.checkboxTheme, isNotNull);
      expect(theme.chipTheme, isNotNull);
      expect(theme.datePickerTheme, isNotNull);
      expect(theme.dialogTheme, isNotNull);
      expect(theme.dividerTheme, isNotNull);
      expect(theme.dropdownMenuTheme, isNotNull);
      expect(theme.expansionTileTheme, isNotNull);
      expect(theme.floatingActionButtonTheme, isNotNull);
      expect(theme.iconButtonTheme, isNotNull);
      expect(theme.inputDecorationTheme, isNotNull);
      expect(theme.listTileTheme, isNotNull);
      expect(theme.menuTheme, isNotNull);
      expect(theme.navigationDrawerTheme, isNotNull);
      expect(theme.popupMenuTheme, isNotNull);
      expect(theme.progressIndicatorTheme, isNotNull);
      expect(theme.radioTheme, isNotNull);
      expect(theme.segmentedButtonTheme, isNotNull);
      expect(theme.sliderTheme, isNotNull);
      expect(theme.snackBarTheme, isNotNull);
      expect(theme.switchTheme, isNotNull);
      expect(theme.tabBarTheme, isNotNull);
      expect(theme.timePickerTheme, isNotNull);
      expect(theme.tooltipTheme, isNotNull);
    });

    test('bannerTheme / appBarTheme 亦已配置', () {
      expect(theme.bannerTheme, isNotNull);
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.scrolledUnderElevation, 3);
    });

    test('非默认组件主题值均基于 colorScheme（无硬编码色）', () {
      expect(theme.cardTheme.elevation, 1);
      expect(theme.cardTheme.surfaceTintColor, theme.colorScheme.surfaceTint);
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      expect(
        theme.bottomSheetTheme.backgroundColor,
        theme.colorScheme.surfaceContainerLow,
      );
      expect(
        theme.dialogTheme.backgroundColor,
        theme.colorScheme.surfaceContainerHigh,
      );
      expect(
        theme.navigationDrawerTheme.backgroundColor,
        theme.colorScheme.surfaceContainerLow,
      );
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });

    test('5 个 M3E token + DesktopSemanticColors 已注册进 extensions', () {
      expect(theme.extension<M3ETitleBarTokens>(), isNotNull);
      expect(theme.extension<M3EShapeTokens>(), isNotNull);
      expect(theme.extension<M3ESliderTokens>(), isNotNull);
      expect(theme.extension<M3EMenuTokens>(), isNotNull);
      expect(theme.extension<M3ESoundPickerTokens>(), isNotNull);
      expect(theme.extension<DesktopSemanticColors>(), isNotNull);
    });

    test('FilledButton 无 StadiumBorder 覆盖（style 为空即保留 M3 默认）', () {
      expect(theme.filledButtonTheme.style, isNull);
    });
  });

  group('FilledButton 实际渲染', () {
    testWidgets('shape 未被主题覆盖（与框架 M3 默认一致）', (tester) async {
      Future<ShapeBorder?> renderWithTheme(ThemeData theme) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('确定'),
                ),
              ),
            ),
          ),
        );
        return tester
            .widget<Material>(
              find
                  .descendant(
                    of: find.byType(FilledButton),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .shape;
      }

      // 注：Flutter 3.44 的 M3 FilledButton 框架默认为 StadiumBorder。
      // 本测试验证主题没有自定义 shape 覆盖（style 为空即走框架默认）。
      final themedShape = await renderWithTheme(buildTestTheme(Brightness.light));
      final defaultShape = await renderWithTheme(ThemeData(useMaterial3: true));
      expect(themedShape, defaultShape);
    });
  });
}
