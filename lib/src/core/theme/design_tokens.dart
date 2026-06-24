import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// M3E Title Bar Tokens — layout metrics for the custom desktop window chrome.
class M3ETitleBarTokens extends ThemeExtension<M3ETitleBarTokens> {
  final double height;
  final double macOSTrafficLightSize;
  final double macOSTrafficLightSpacing;
  final double macOSTrafficLightInset;
  final double windowButtonSize;
  final double windowButtonSpacing;
  final EdgeInsets windowButtonMargin;
  final BorderRadius windowButtonBorderRadius;

  const M3ETitleBarTokens({
    required this.height,
    required this.macOSTrafficLightSize,
    required this.macOSTrafficLightSpacing,
    required this.macOSTrafficLightInset,
    required this.windowButtonSize,
    required this.windowButtonSpacing,
    required this.windowButtonMargin,
    required this.windowButtonBorderRadius,
  });

  static const standard = M3ETitleBarTokens(
    height: 48,
    macOSTrafficLightSize: 12,
    macOSTrafficLightSpacing: 8,
    macOSTrafficLightInset: 16,
    windowButtonSize: 36,
    windowButtonSpacing: 4,
    windowButtonMargin: EdgeInsets.only(right: 8),
    windowButtonBorderRadius: BorderRadius.all(Radius.circular(8)),
  );

  @override
  M3ETitleBarTokens copyWith({
    double? height,
    double? macOSTrafficLightSize,
    double? macOSTrafficLightSpacing,
    double? macOSTrafficLightInset,
    double? windowButtonSize,
    double? windowButtonSpacing,
    EdgeInsets? windowButtonMargin,
    BorderRadius? windowButtonBorderRadius,
  }) {
    return M3ETitleBarTokens(
      height: height ?? this.height,
      macOSTrafficLightSize: macOSTrafficLightSize ?? this.macOSTrafficLightSize,
      macOSTrafficLightSpacing: macOSTrafficLightSpacing ?? this.macOSTrafficLightSpacing,
      macOSTrafficLightInset: macOSTrafficLightInset ?? this.macOSTrafficLightInset,
      windowButtonSize: windowButtonSize ?? this.windowButtonSize,
      windowButtonSpacing: windowButtonSpacing ?? this.windowButtonSpacing,
      windowButtonMargin: windowButtonMargin ?? this.windowButtonMargin,
      windowButtonBorderRadius: windowButtonBorderRadius ?? this.windowButtonBorderRadius,
    );
  }

  @override
  ThemeExtension<M3ETitleBarTokens> lerp(
    covariant ThemeExtension<M3ETitleBarTokens>? other,
    double t,
  ) {
    if (other is! M3ETitleBarTokens) return this;
    return M3ETitleBarTokens(
      height: lerpDouble(height, other.height, t)!,
      macOSTrafficLightSize: lerpDouble(macOSTrafficLightSize, other.macOSTrafficLightSize, t)!,
      macOSTrafficLightSpacing: lerpDouble(macOSTrafficLightSpacing, other.macOSTrafficLightSpacing, t)!,
      macOSTrafficLightInset: lerpDouble(macOSTrafficLightInset, other.macOSTrafficLightInset, t)!,
      windowButtonSize: lerpDouble(windowButtonSize, other.windowButtonSize, t)!,
      windowButtonSpacing: lerpDouble(windowButtonSpacing, other.windowButtonSpacing, t)!,
      windowButtonMargin: t < 0.5 ? windowButtonMargin : other.windowButtonMargin,
      windowButtonBorderRadius: t < 0.5 ? windowButtonBorderRadius : other.windowButtonBorderRadius,
    );
  }
}

/// M3E Shape Tokens — corner radii for expressive components.
class M3EShapeTokens extends ThemeExtension<M3EShapeTokens> {
  final double bottomSheet;
  final double button;
  final double sliderTrack;
  final double container;

  const M3EShapeTokens({
    required this.bottomSheet,
    required this.button,
    required this.sliderTrack,
    required this.container,
  });

  static const standard = M3EShapeTokens(
    bottomSheet: 28,
    button: 16,
    sliderTrack: 4,
    container: 24,
  );

  @override
  M3EShapeTokens copyWith({
    double? bottomSheet,
    double? button,
    double? sliderTrack,
    double? container,
  }) {
    return M3EShapeTokens(
      bottomSheet: bottomSheet ?? this.bottomSheet,
      button: button ?? this.button,
      sliderTrack: sliderTrack ?? this.sliderTrack,
      container: container ?? this.container,
    );
  }

  @override
  ThemeExtension<M3EShapeTokens> lerp(
    covariant ThemeExtension<M3EShapeTokens>? other,
    double t,
  ) {
    if (other is! M3EShapeTokens) return this;
    return M3EShapeTokens(
      bottomSheet: lerpDouble(bottomSheet, other.bottomSheet, t)!,
      button: lerpDouble(button, other.button, t)!,
      sliderTrack: lerpDouble(sliderTrack, other.sliderTrack, t)!,
      container: lerpDouble(container, other.container, t)!,
    );
  }
}

/// M3E Slider Tokens — track height, thumb size, shape family.
class M3ESliderTokens extends ThemeExtension<M3ESliderTokens> {
  final double trackHeight;
  final double thumbRadius;
  final double overlayRadius;

  const M3ESliderTokens({
    required this.trackHeight,
    required this.thumbRadius,
    required this.overlayRadius,
  });

  /// "Large" size per M3E expressive slider spec (track ≈8dp, thumb ≈14dp).
  static const large = M3ESliderTokens(
    trackHeight: 8,
    thumbRadius: 10,
    overlayRadius: 20,
  );

  @override
  M3ESliderTokens copyWith({
    double? trackHeight,
    double? thumbRadius,
    double? overlayRadius,
  }) {
    return M3ESliderTokens(
      trackHeight: trackHeight ?? this.trackHeight,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      overlayRadius: overlayRadius ?? this.overlayRadius,
    );
  }

  @override
  ThemeExtension<M3ESliderTokens> lerp(
    covariant ThemeExtension<M3ESliderTokens>? other,
    double t,
  ) {
    if (other is! M3ESliderTokens) return this;
    return M3ESliderTokens(
      trackHeight: lerpDouble(trackHeight, other.trackHeight, t)!,
      thumbRadius: lerpDouble(thumbRadius, other.thumbRadius, t)!,
      overlayRadius: lerpDouble(overlayRadius, other.overlayRadius, t)!,
    );
  }
}

/// M3E Menu Tokens — shape, motion, and layout for expressive context menus.
class M3EMenuTokens extends ThemeExtension<M3EMenuTokens> {
  final double menuRadius;
  final double itemRadius;
  final Duration animationDuration;
  final double gapHeight;

  const M3EMenuTokens({
    required this.menuRadius,
    required this.itemRadius,
    required this.animationDuration,
    required this.gapHeight,
  });

  /// Default expressive vertical‑menu tokens per M3E spec.
  static const standard = M3EMenuTokens(
    menuRadius: 16,
    itemRadius: 10,
    animationDuration: Duration(milliseconds: 300),
    gapHeight: 8,
  );

  @override
  M3EMenuTokens copyWith({
    double? menuRadius,
    double? itemRadius,
    Duration? animationDuration,
    double? gapHeight,
  }) {
    return M3EMenuTokens(
      menuRadius: menuRadius ?? this.menuRadius,
      itemRadius: itemRadius ?? this.itemRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      gapHeight: gapHeight ?? this.gapHeight,
    );
  }

  @override
  ThemeExtension<M3EMenuTokens> lerp(
    covariant ThemeExtension<M3EMenuTokens>? other,
    double t,
  ) {
    if (other is! M3EMenuTokens) return this;
    return M3EMenuTokens(
      menuRadius: lerpDouble(menuRadius, other.menuRadius, t)!,
      itemRadius: lerpDouble(itemRadius, other.itemRadius, t)!,
      animationDuration: t < 0.5
          ? animationDuration
          : other.animationDuration,
      gapHeight: lerpDouble(gapHeight, other.gapHeight, t)!,
    );
  }
}

/// M3E Sound Picker Tokens — shape, spacing, and layout for expressive
/// sound-selection chips (M3E segmented‑list variant).
class M3ESoundPickerTokens extends ThemeExtension<M3ESoundPickerTokens> {
  final double chipRadius;
  final double chipHeight;
  final EdgeInsets chipPadding;
  final double chipSpacing;
  final double gapBetweenChips;
  final double iconSize;

  const M3ESoundPickerTokens({
    required this.chipRadius,
    required this.chipHeight,
    required this.chipPadding,
    required this.chipSpacing,
    required this.gapBetweenChips,
    required this.iconSize,
  });

  static const standard = M3ESoundPickerTokens(
    chipRadius: 12,
    chipHeight: 36,
    chipPadding: EdgeInsets.symmetric(horizontal: 16),
    chipSpacing: 8,
    gapBetweenChips: 8,
    iconSize: 20,
  );

  @override
  M3ESoundPickerTokens copyWith({
    double? chipRadius,
    double? chipHeight,
    EdgeInsets? chipPadding,
    double? chipSpacing,
    double? gapBetweenChips,
    double? iconSize,
  }) {
    return M3ESoundPickerTokens(
      chipRadius: chipRadius ?? this.chipRadius,
      chipHeight: chipHeight ?? this.chipHeight,
      chipPadding: chipPadding ?? this.chipPadding,
      chipSpacing: chipSpacing ?? this.chipSpacing,
      gapBetweenChips: gapBetweenChips ?? this.gapBetweenChips,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  @override
  ThemeExtension<M3ESoundPickerTokens> lerp(
    covariant ThemeExtension<M3ESoundPickerTokens>? other,
    double t,
  ) {
    if (other is! M3ESoundPickerTokens) return this;
    return M3ESoundPickerTokens(
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t)!,
      chipHeight: lerpDouble(chipHeight, other.chipHeight, t)!,
      chipPadding: t < 0.5 ? chipPadding : other.chipPadding,
      chipSpacing: lerpDouble(chipSpacing, other.chipSpacing, t)!,
      gapBetweenChips: lerpDouble(gapBetweenChips, other.gapBetweenChips, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
    );
  }
}

/// Convenience extension to access M3E tokens from [BuildContext].
extension M3ETokensContext on BuildContext {
  M3EShapeTokens get m3eShape => Theme.of(this).extension<M3EShapeTokens>() ??
      M3EShapeTokens.standard;

  M3ESliderTokens get m3eSlider => Theme.of(this).extension<M3ESliderTokens>() ??
      M3ESliderTokens.large;

  M3EMenuTokens get m3eMenu => Theme.of(this).extension<M3EMenuTokens>() ??
      M3EMenuTokens.standard;

  M3ETitleBarTokens get m3eTitleBar =>
      Theme.of(this).extension<M3ETitleBarTokens>() ??
      M3ETitleBarTokens.standard;

  M3ESoundPickerTokens get m3eSoundPicker =>
      Theme.of(this).extension<M3ESoundPickerTokens>() ??
      M3ESoundPickerTokens.standard;
}
