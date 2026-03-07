import 'package:flutter/material.dart';

/// Semantic desktop colors to avoid flat/white-looking large surfaces.
class DesktopSemanticColors extends ThemeExtension<DesktopSemanticColors> {
  const DesktopSemanticColors({
    required this.appBackground,
    required this.paneBackground,
    required this.contentBackground,
    required this.timelineBackground,
    required this.timelineContainerBackground,
    required this.timelineBorder,
    required this.timelineShadow,
  });

  final Color appBackground;
  final Color paneBackground;
  final Color contentBackground;
  final Color timelineBackground;
  final Color timelineContainerBackground;
  final Color timelineBorder;
  final Color timelineShadow;

  factory DesktopSemanticColors.fromColorScheme(
    ColorScheme scheme, {
    required bool isDesktop,
  }) {
    if (!isDesktop) {
      return DesktopSemanticColors(
        appBackground: scheme.surface,
        paneBackground: scheme.surface,
        contentBackground: scheme.surface,
        timelineBackground: scheme.surface,
        timelineContainerBackground: scheme.surface,
        timelineBorder: scheme.outlineVariant,
        timelineShadow: Colors.transparent,
      );
    }

    final isDark = scheme.brightness == Brightness.dark;
    final appBackground = Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.20 : 0.24,
    )!;
    final paneBackground = Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.14 : 0.18,
    )!;
    final contentBackground = Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.09 : 0.12,
    )!;
    final timelineBackground = Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.16 : 0.20,
    )!;
    final timelineContainerBackground = Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.03 : 0.05,
    )!;

    return DesktopSemanticColors(
      appBackground: appBackground,
      paneBackground: paneBackground,
      contentBackground: contentBackground,
      timelineBackground: timelineBackground,
      timelineContainerBackground: timelineContainerBackground,
      timelineBorder: scheme.outlineVariant.withValues(
        alpha: isDark ? 0.72 : 0.78,
      ),
      timelineShadow: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
    );
  }

  @override
  DesktopSemanticColors copyWith({
    Color? appBackground,
    Color? paneBackground,
    Color? contentBackground,
    Color? timelineBackground,
    Color? timelineContainerBackground,
    Color? timelineBorder,
    Color? timelineShadow,
  }) {
    return DesktopSemanticColors(
      appBackground: appBackground ?? this.appBackground,
      paneBackground: paneBackground ?? this.paneBackground,
      contentBackground: contentBackground ?? this.contentBackground,
      timelineBackground: timelineBackground ?? this.timelineBackground,
      timelineContainerBackground:
          timelineContainerBackground ?? this.timelineContainerBackground,
      timelineBorder: timelineBorder ?? this.timelineBorder,
      timelineShadow: timelineShadow ?? this.timelineShadow,
    );
  }

  @override
  ThemeExtension<DesktopSemanticColors> lerp(
    covariant ThemeExtension<DesktopSemanticColors>? other,
    double t,
  ) {
    if (other is! DesktopSemanticColors) return this;
    return DesktopSemanticColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      paneBackground: Color.lerp(paneBackground, other.paneBackground, t)!,
      contentBackground: Color.lerp(
        contentBackground,
        other.contentBackground,
        t,
      )!,
      timelineBackground: Color.lerp(
        timelineBackground,
        other.timelineBackground,
        t,
      )!,
      timelineContainerBackground: Color.lerp(
        timelineContainerBackground,
        other.timelineContainerBackground,
        t,
      )!,
      timelineBorder: Color.lerp(timelineBorder, other.timelineBorder, t)!,
      timelineShadow: Color.lerp(timelineShadow, other.timelineShadow, t)!,
    );
  }
}

extension DesktopSemanticColorsContext on BuildContext {
  bool get isDesktopPlatform {
    final platform = Theme.of(this).platform;
    return platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux;
  }

  DesktopSemanticColors get desktopSemanticColors {
    final theme = Theme.of(this);
    return theme.extension<DesktopSemanticColors>() ??
        DesktopSemanticColors.fromColorScheme(
          theme.colorScheme,
          isDesktop: isDesktopPlatform,
        );
  }
}
