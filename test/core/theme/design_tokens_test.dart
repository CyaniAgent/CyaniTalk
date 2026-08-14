import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Nyachi/src/core/theme/design_tokens.dart';

/// M3E design token 类的单元测试：standard 常量、copyWith、lerp。
void main() {
  group('M3ETitleBarTokens', () {
    test('standard 常量符合桌面标题栏规格', () {
      expect(M3ETitleBarTokens.standard.height, 48);
      expect(M3ETitleBarTokens.standard.macOSTrafficLightSize, 12);
      expect(M3ETitleBarTokens.standard.windowButtonSize, 36);
    });

    test('copyWith 只覆盖指定字段', () {
      final updated = M3ETitleBarTokens.standard.copyWith(height: 64);
      expect(updated.height, 64);
      expect(
        updated.windowButtonSize,
        M3ETitleBarTokens.standard.windowButtonSize,
      );
    });

    test('lerp 产出新实例', () {
      const a = M3ETitleBarTokens.standard;
      final lerped = a.lerp(a, 0.5) as M3ETitleBarTokens;
      expect(lerped, isA<M3ETitleBarTokens>());
      expect(lerped.height, a.height);
    });
  });

  group('M3EShapeTokens', () {
    test('standard 角半径符合 M3E 规格', () {
      expect(M3EShapeTokens.standard.bottomSheet, 28);
      expect(M3EShapeTokens.standard.button, 16);
      expect(M3EShapeTokens.standard.sliderTrack, 4);
      expect(M3EShapeTokens.standard.container, 24);
    });

    test('copyWith / lerp', () {
      final updated = M3EShapeTokens.standard.copyWith(button: 8);
      expect(updated.button, 8);
      expect(updated.bottomSheet, M3EShapeTokens.standard.bottomSheet);

      final lerped =
          M3EShapeTokens.standard.lerp(M3EShapeTokens.standard, 0.5)
              as M3EShapeTokens;
      expect(lerped.bottomSheet, M3EShapeTokens.standard.bottomSheet);
    });
  });

  group('M3ESliderTokens', () {
    test('standard 为标准滑块规格（track 4 / thumb 8）', () {
      expect(M3ESliderTokens.standard.trackHeight, 4);
      expect(M3ESliderTokens.standard.thumbRadius, 8);
      expect(M3ESliderTokens.standard.overlayRadius, 16);
    });

    test('large 为大号滑块规格', () {
      expect(M3ESliderTokens.large.trackHeight, 8);
      expect(M3ESliderTokens.large.thumbRadius, 10);
      expect(M3ESliderTokens.large.overlayRadius, 20);
    });

    test('copyWith / lerp', () {
      final updated = M3ESliderTokens.standard.copyWith(trackHeight: 6);
      expect(updated.trackHeight, 6);
      expect(updated.thumbRadius, M3ESliderTokens.standard.thumbRadius);

      final lerped =
          M3ESliderTokens.standard.lerp(M3ESliderTokens.standard, 0.5)
              as M3ESliderTokens;
      expect(lerped.thumbRadius, M3ESliderTokens.standard.thumbRadius);
    });
  });

  group('M3EMenuTokens', () {
    test('standard 菜单规格', () {
      expect(M3EMenuTokens.standard.menuRadius, 16);
      expect(M3EMenuTokens.standard.itemRadius, 10);
      expect(
        M3EMenuTokens.standard.animationDuration,
        const Duration(milliseconds: 300),
      );
      expect(M3EMenuTokens.standard.gapHeight, 8);
    });

    test('copyWith / lerp', () {
      final updated = M3EMenuTokens.standard.copyWith(gapHeight: 12);
      expect(updated.gapHeight, 12);
      expect(updated.menuRadius, M3EMenuTokens.standard.menuRadius);
    });
  });

  group('M3ESoundPickerTokens', () {
    test('standard 声音选择 chip 规格', () {
      expect(M3ESoundPickerTokens.standard.chipRadius, 12);
      expect(M3ESoundPickerTokens.standard.chipHeight, 36);
      expect(
        M3ESoundPickerTokens.standard.chipPadding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(M3ESoundPickerTokens.standard.chipSpacing, 8);
      expect(M3ESoundPickerTokens.standard.iconSize, 20);
    });

    test('copyWith / lerp', () {
      final updated = M3ESoundPickerTokens.standard.copyWith(chipHeight: 40);
      expect(updated.chipHeight, 40);
      expect(updated.chipRadius, M3ESoundPickerTokens.standard.chipRadius);
    });
  });
}
