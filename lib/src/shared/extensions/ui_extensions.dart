import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  double get keyboardHeight => mediaQuery.viewInsets.bottom;
  bool get hasKeyboard => keyboardHeight > 0;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  T responsiveValue<T>(
    T mobile,
    T tablet,
    T desktop, {
    double tabletBreakpoint = 600,
    double desktopBreakpoint = 1200,
  }) {
    if (screenWidth >= desktopBreakpoint) {
      return desktop;
    } else if (screenWidth >= tabletBreakpoint) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

extension WidgetExtension on Widget {
  Padding padding(EdgeInsetsGeometry insets) =>
      Padding(padding: insets, child: this);

  Center centered() => Center(child: this);

  Material withShadow({double elevation = 4, ShapeBorder? shape}) =>
      Material(elevation: elevation, shape: shape, child: this);

  GestureDetector onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);

  Opacity withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  ConstrainedBox withMaxWidth(double maxWidth) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: this,
  );

  ConstrainedBox withMaxHeight(double maxHeight) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: maxHeight),
    child: this,
  );

  Container withBackgroundColor(Color color) =>
      Container(color: color, child: this);

  Container withBorder({
    Color color = const Color(0xFF000000),
    double width = 1.0,
  }) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width),
    ),
    child: this,
  );
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, _getScreenType(context));
  }

  static ScreenType _getScreenType(BuildContext context) {
    final width = context.screenWidth;
    if (width >= 1200) {
      return ScreenType.desktop;
    } else if (width >= 600) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
}

enum ScreenType { mobile, tablet, desktop }