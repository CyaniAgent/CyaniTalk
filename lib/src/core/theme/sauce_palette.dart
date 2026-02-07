import 'package:flutter/material.dart';

/// 酱汁调色盘 (Sauce Palette)
/// 
/// 核心颜色定义类，基于 Material 3 标准并融入初音未来 (Hatsune Miku) 主题色。
/// 包含从 Material Theme Builder 生成的精确色值。
class SaucePalette {
  /// 初音未来核心主题色 (Miku Green)
  static const Color mikuGreen = Color(0xFF39C5BB);
  
  /// 备用核心色 (Teal)
  static const Color primarySeed = Color(0xFF006A64);

  // --- 亮色模式色值 (Light Scheme) ---
  static const Color lightPrimary = Color(0xff006a64);
  static const Color lightOnPrimary = Color(0xffffffff);
  static const Color lightPrimaryContainer = Color(0xff9df2e9);
  static const Color lightOnPrimaryContainer = Color(0xff00504b);
  
  static const Color lightSecondary = Color(0xff4a6360);
  static const Color lightOnSecondary = Color(0xffffffff);
  static const Color lightSecondaryContainer = Color(0xffcce8e4);
  static const Color lightOnSecondaryContainer = Color(0xff324b49);
  
  static const Color lightTertiary = Color(0xff48617a);
  static const Color lightOnTertiary = Color(0xffffffff);
  static const Color lightTertiaryContainer = Color(0xffcfe5ff);
  static const Color lightOnTertiaryContainer = Color(0xff304962);
  
  static const Color lightSurface = Color(0xfff4fbf9);
  static const Color lightOnSurface = Color(0xff161d1c);
  static const Color lightOnSurfaceVariant = Color(0xff3f4947);
  static const Color lightOutline = Color(0xff6f7977);
  static const Color lightOutlineVariant = Color(0xffbec9c6);

  static const Color lightPrimaryFixed = Color(0xff9df2e9);
  static const Color lightOnPrimaryFixed = Color(0xff00201e);
  static const Color lightPrimaryFixedDim = Color(0xff81d5cd);
  static const Color lightOnPrimaryFixedVariant = Color(0xff00504b);

  static const Color lightSecondaryFixed = Color(0xffcce8e4);
  static const Color lightOnSecondaryFixed = Color(0xff051f1d);
  static const Color lightSecondaryFixedDim = Color(0xffb0ccc8);
  static const Color lightOnSecondaryFixedVariant = Color(0xff324b49);

  // --- 暗色模式色值 (Dark Scheme) ---
  static const Color darkPrimary = Color(0xff81d5cd);
  static const Color darkOnPrimary = Color(0xff003734);
  static const Color darkPrimaryContainer = Color(0xff00504b);
  static const Color darkOnPrimaryContainer = Color(0xff9df2e9);
  
  static const Color darkSecondary = Color(0xffb0ccc8);
  static const Color darkOnSecondary = Color(0xff1c3532);
  static const Color darkSecondaryContainer = Color(0xff324b49);
  static const Color darkOnSecondaryContainer = Color(0xffcce8e4);
  
  static const Color darkTertiary = Color(0xffafc9e7);
  static const Color darkOnTertiary = Color(0xff18324a);
  static const Color darkTertiaryContainer = Color(0xff304962);
  static const Color darkOnTertiaryContainer = Color(0xffcfe5ff);
  
  static const Color darkSurface = Color(0xff0e1514);
  static const Color darkOnSurface = Color(0xffdde4e2);
  static const Color darkOnSurfaceVariant = Color(0xffbec9c6);
  static const Color darkOutline = Color(0xff899391);
  static const Color darkOutlineVariant = Color(0xff3f4947);

  static const Color darkPrimaryFixed = Color(0xff9df2e9);
  static const Color darkOnPrimaryFixed = Color(0xff00201e);
  static const Color darkPrimaryFixedDim = Color(0xff81d5cd);
  static const Color darkOnPrimaryFixedVariant = Color(0xff00504b);

  /// 根据种子颜色生成配色方案
  static ColorScheme schemeFromSeed(Color seed, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
  }

  /// 获取酱汁调色盘预设配色方案 (亮色)
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      surfaceTint: lightPrimary,
      onPrimary: lightOnPrimary,
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: lightOnPrimaryContainer,
      secondary: lightSecondary,
      onSecondary: lightOnSecondary,
      secondaryContainer: lightSecondaryContainer,
      onSecondaryContainer: lightOnSecondaryContainer,
      tertiary: lightTertiary,
      onTertiary: lightOnTertiary,
      tertiaryContainer: lightTertiaryContainer,
      onTertiaryContainer: lightOnTertiaryContainer,
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3231),
      inversePrimary: Color(0xff81d5cd),
      primaryFixed: lightPrimaryFixed,
      onPrimaryFixed: lightOnPrimaryFixed,
      primaryFixedDim: lightPrimaryFixedDim,
      onPrimaryFixedVariant: lightOnPrimaryFixedVariant,
      secondaryFixed: lightSecondaryFixed,
      onSecondaryFixed: lightOnSecondaryFixed,
      secondaryFixedDim: lightSecondaryFixedDim,
      onSecondaryFixedVariant: lightOnSecondaryFixedVariant,
    );
  }

  /// 获取酱汁调色盘预设配色方案 (暗色)
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      surfaceTint: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkOnPrimaryContainer,
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkOnSecondaryContainer,
      tertiary: darkTertiary,
      onTertiary: darkOnTertiary,
      tertiaryContainer: darkTertiaryContainer,
      onTertiaryContainer: darkOnTertiaryContainer,
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e2),
      inversePrimary: Color(0xff006a64),
      primaryFixed: darkPrimaryFixed,
      onPrimaryFixed: darkOnPrimaryFixed,
      primaryFixedDim: darkPrimaryFixedDim,
      onPrimaryFixedVariant: darkOnPrimaryFixedVariant,
    );
  }
}