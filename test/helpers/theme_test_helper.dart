import 'package:flutter/material.dart';
import 'package:Nyachi/src/core/theme/design_tokens.dart';
import 'package:Nyachi/src/core/theme/desktop_semantic_colors.dart';

/// 镜像 `lib/src/app.dart` 中 `_CyaniTalkAppState._buildTheme`（L425-528）的
/// MD3 主题构建逻辑。
///
/// 目的：`_buildTheme` 是私有方法且依赖大量 provider/service（pump 整个
/// CyaniTalkApp 需要 mock 一整套 Riverpod provider），这里用与生产代码完全
/// 相同的参数构造 ThemeData，供组件主题 / token 注册类测试断言。若生产主题
/// 增减组件主题或 token，此辅助函数需同步更新（见 learnings.md 测试基建记录）。
ThemeData buildTestTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF39C5BB),
    brightness: brightness,
  );

  final theme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    bannerTheme: const MaterialBannerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 3,
    ),
    badgeTheme: const BadgeThemeData(),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      showDragHandle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
    ),
    checkboxTheme: const CheckboxThemeData(),
    chipTheme: const ChipThemeData(),
    datePickerTheme: const DatePickerThemeData(),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
    ),
    dividerTheme: const DividerThemeData(),
    dropdownMenuTheme: const DropdownMenuThemeData(),
    expansionTileTheme: const ExpansionTileThemeData(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(),
    iconButtonTheme: const IconButtonThemeData(),
    inputDecorationTheme: const InputDecorationThemeData(
      filled: true,
      border: OutlineInputBorder(),
    ),
    listTileTheme: const ListTileThemeData(),
    menuTheme: const MenuThemeData(),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
    ),
    popupMenuTheme: const PopupMenuThemeData(),
    progressIndicatorTheme: const ProgressIndicatorThemeData(),
    radioTheme: const RadioThemeData(),
    segmentedButtonTheme: const SegmentedButtonThemeData(),
    sliderTheme: const SliderThemeData(),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: const SwitchThemeData(),
    tabBarTheme: const TabBarThemeData(),
    timePickerTheme: const TimePickerThemeData(),
    tooltipTheme: const TooltipThemeData(),
  );

  return theme.copyWith(
    extensions: [
      ...theme.extensions.values,
      DesktopSemanticColors.fromColorScheme(colorScheme, isDesktop: false),
      M3ETitleBarTokens.standard,
      M3EShapeTokens.standard,
      M3ESliderTokens.standard,
      M3EMenuTokens.standard,
      M3ESoundPickerTokens.standard,
    ],
  );
}
