import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/core/theme/design_tokens.dart';
import 'package:Nyachi/src/core/theme/desktop_semantic_colors.dart';

import '../../helpers/theme_test_helper.dart';

/// M3E token 注册可见性测试：通过 widget 树中 `Theme.of(context).extension`
/// 与 `context.m3e*` 扩展读取注册值，验证 app.dart 主题里注册的 5 个 token
/// 对消费者可见；未注册时 `m3e*` 扩展回退到 standard。
void main() {
  group('M3E token 注册后消费者可获取', () {
    testWidgets('Theme.of(context).extension 返回已注册 token', (tester) async {
      late M3ETitleBarTokens? titleBar;
      late M3EShapeTokens? shape;
      late M3ESliderTokens? slider;
      late M3EMenuTokens? menu;
      late M3ESoundPickerTokens? soundPicker;
      late DesktopSemanticColors? semantic;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTestTheme(Brightness.light),
          home: Builder(
            builder: (context) {
              titleBar = Theme.of(context).extension<M3ETitleBarTokens>();
              shape = Theme.of(context).extension<M3EShapeTokens>();
              slider = Theme.of(context).extension<M3ESliderTokens>();
              menu = Theme.of(context).extension<M3EMenuTokens>();
              soundPicker =
                  Theme.of(context).extension<M3ESoundPickerTokens>();
              semantic = Theme.of(context).extension<DesktopSemanticColors>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(titleBar, isNotNull);
      expect(shape, isNotNull);
      expect(slider, isNotNull);
      expect(menu, isNotNull);
      expect(soundPicker, isNotNull);
      expect(semantic, isNotNull);
    });

    testWidgets('context.m3e* 扩展返回注册的实例（而非回退 standard）', (tester) async {
      const custom = M3EShapeTokens(
        bottomSheet: 99,
        button: 99,
        sliderTrack: 99,
        container: 99,
      );
      final base = buildTestTheme(Brightness.light);
      final themeWithCustom = base.copyWith(
        extensions: [...base.extensions.values, custom],
      );

      late M3EShapeTokens shape;
      await tester.pumpWidget(
        MaterialApp(
          theme: themeWithCustom,
          home: Builder(
            builder: (context) {
              shape = context.m3eShape;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(shape, same(custom));
    });
  });

  group('M3E token 未注册时回退', () {
    testWidgets('context.m3e* 回退到 standard', (tester) async {
      late M3EShapeTokens shape;
      late M3ESliderTokens slider;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              shape = context.m3eShape;
              slider = context.m3eSlider;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(shape, M3EShapeTokens.standard);
      expect(slider, M3ESliderTokens.standard);
    });
  });
}
