import 'package:flutter/material.dart';

/// 酱汁字型 (Sauce Typography)
///
/// 负责定义应用程序的文字排版规范。
/// 支持跨平台自适应缩放，并针对 Android 进行了微调。
class SauceTypography {
  /// 创建自适应的 TextTheme
  ///
  /// [platform] 当前运行的平台
  static TextTheme createTextTheme(TargetPlatform platform) {
    // Android 平台字体略微缩小，以适应较小的屏幕像素密度感
    final bool isAndroid = platform == TargetPlatform.android;
    final double scale = isAndroid ? 0.94 : 1.0;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57 * scale,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45 * scale,
        fontWeight: FontWeight.w400,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36 * scale,
        fontWeight: FontWeight.w400,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w400,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28 * scale,
        fontWeight: FontWeight.w400,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24 * scale,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.w400,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
