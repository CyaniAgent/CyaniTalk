import 'package:flutter/material.dart';
import 'sauce_palette.dart';

/// 应用程序主题工厂
/// 
/// 负责根据配色方案构建 ThemeData。
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  ThemeData light(ColorScheme? dynamicScheme) {
    return _buildTheme(dynamicScheme ?? SaucePalette.lightScheme());
  }

  ThemeData dark(ColorScheme? dynamicScheme) {
    return _buildTheme(dynamicScheme ?? SaucePalette.darkScheme());
  }

  ThemeData _buildTheme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
     fontFamily: 'MiSans',
  );
}
