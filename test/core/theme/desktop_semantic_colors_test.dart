import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/core/theme/desktop_semantic_colors.dart';

/// DesktopSemanticColors 单元测试：桌面/移动分支色值、copyWith、lerp。
void main() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF39C5BB));

  group('DesktopSemanticColors.fromColorScheme', () {
    test('移动端分支：全部 surface + 透明阴影', () {
      final colors = DesktopSemanticColors.fromColorScheme(
        scheme,
        isDesktop: false,
      );
      expect(colors.appBackground, scheme.surface);
      expect(colors.paneBackground, scheme.surface);
      expect(colors.contentBackground, scheme.surface);
      expect(colors.timelineBackground, scheme.surface);
      expect(colors.timelineContainerBackground, scheme.surface);
      expect(colors.timelineBorder, scheme.outlineVariant);
      expect(colors.timelineShadow, Colors.transparent);
    });

    test('桌面端分支：使用 surfaceContainer 层级区分大面积表面', () {
      final colors = DesktopSemanticColors.fromColorScheme(
        scheme,
        isDesktop: true,
      );
      expect(colors.appBackground, scheme.surface);
      expect(colors.paneBackground, scheme.surfaceContainerLow);
      expect(colors.contentBackground, scheme.surface);
      expect(colors.timelineBackground, scheme.surfaceContainer);
      expect(colors.timelineContainerBackground, scheme.surfaceContainerHigh);
      expect(colors.timelineBorder, isNot(scheme.outlineVariant));
      expect(colors.timelineShadow, isNot(Colors.transparent));
    });

    test('copyWith 覆盖指定字段且保留其余', () {
      final colors = DesktopSemanticColors.fromColorScheme(
        scheme,
        isDesktop: true,
      );
      final updated = colors.copyWith(timelineBackground: Colors.black);
      expect(updated.timelineBackground, Colors.black);
      expect(updated.paneBackground, colors.paneBackground);
    });

    test('lerp 产出新实例且 t=1 取 other', () {
      final a = DesktopSemanticColors.fromColorScheme(
        scheme,
        isDesktop: true,
      );
      final b = DesktopSemanticColors.fromColorScheme(
        scheme,
        isDesktop: false,
      );
      final lerped = a.lerp(b, 1.0) as DesktopSemanticColors;
      expect(lerped, isA<DesktopSemanticColors>());
      expect(lerped.paneBackground, b.paneBackground);
    });
  });
}
