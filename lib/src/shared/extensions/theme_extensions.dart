import 'package:flutter/material.dart';

/// 主题颜色扩展工具
/// 提供统一的主题颜色访问方式，确保主题一致性

/// 主题颜色扩展
extension ThemeColorExtension on BuildContext {
  /// 获取主颜色
  Color get primaryColor => Theme.of(this).primaryColor;

  /// 获取主颜色（Material 3）
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 获取背景颜色
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// 获取卡片颜色
  Color get cardColor => Theme.of(this).cardColor;

  /// 获取文本颜色
  Color get textColor =>
      Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  /// 获取次要文本颜色
  Color get secondaryTextColor =>
      Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey;

  /// 获取错误颜色
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// 获取禁用颜色
  Color get disabledColor => Theme.of(this).disabledColor;

  /// 获取提示颜色
  Color get hintColor => Theme.of(this).hintColor;
}

/// 颜色工具类
class ColorUtils {
  /// 透明色
  static const Color transparent = Color(0x00000000);

  /// 从十六进制字符串创建颜色
  /// [hex] 十六进制颜色字符串，支持 #RRGGBB 或 RRGGBB 格式
  static Color fromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// 将颜色转换为十六进制字符串
  /// [color] 颜色对象
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// 调整颜色亮度
  /// [color] 原始颜色
  /// [factor] 调整因子，大于1增亮，小于1变暗
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final adjusted = hsl.withLightness(
      (hsl.lightness * factor).clamp(0.0, 1.0),
    );
    return adjusted.toColor();
  }

  /// 获取颜色的对比色
  /// [color] 原始颜色
  static Color getContrastColor(Color color) {
    final brightness = color.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}
