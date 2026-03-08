import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '/src/routing/router.dart' show rootNavigatorKey;

enum AppNoticeType { info, success, warning, error }

String _extractSnackBarMessage(Widget content) {
  if (content is Text) {
    return content.data ?? content.textSpan?.toPlainText() ?? '';
  }
  return content.toStringShort();
}

AppNoticeType _inferNoticeType(BuildContext context, SnackBar snackBar) {
  final bg = snackBar.backgroundColor;
  if (bg != null) {
    final error = Theme.of(context).colorScheme.error;
    final diff =
        ((bg.r - error.r) * 255).abs() +
        ((bg.g - error.g) * 255).abs() +
        ((bg.b - error.b) * 255).abs();
    if (diff < 40) return AppNoticeType.error;
  }
  return AppNoticeType.info;
}

void _showTopNotice(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  AppNoticeType type = AppNoticeType.info,
  SnackBarAction? action,
}) {
  final navigatorContext =
      rootNavigatorKey.currentContext ??
      Navigator.maybeOf(context, rootNavigator: true)?.context ??
      Navigator.maybeOf(context)?.context;
  if (navigatorContext == null) return;

  final theme = Theme.of(navigatorContext);
  final isDark = theme.brightness == Brightness.dark;
  final media = MediaQuery.of(navigatorContext);

  final (icon, accentColor) = switch (type) {
    AppNoticeType.success => (Icons.check_circle_rounded, Colors.green),
    AppNoticeType.warning => (Icons.warning_rounded, Colors.orange),
    AppNoticeType.error => (Icons.error_rounded, theme.colorScheme.error),
    AppNoticeType.info => (Icons.info_rounded, theme.colorScheme.primary),
  };

  final bgColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
  final textColor = isDark ? const Color(0xFFEDEDED) : Colors.black;
  final borderColor = isDark
      ? Colors.white.withValues(alpha: 0.18)
      : Colors.black.withValues(alpha: 0.10);

  final maxWidth = (media.size.width - 24).clamp(240.0, 680.0);

  Flushbar<void>(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: EdgeInsets.only(
      top: media.padding.top + 8,
      left: 12,
      right: 12,
    ),
    borderRadius: BorderRadius.circular(24),
    borderColor: borderColor,
    borderWidth: 1,
    maxWidth: maxWidth,
    backgroundColor: bgColor,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
        blurRadius: 14,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    isDismissible: true,
    animationDuration: const Duration(milliseconds: 220),
    forwardAnimationCurve: Curves.easeOutQuart,
    reverseAnimationCurve: Curves.easeInQuart,
    duration: duration,
    icon: Icon(icon, color: accentColor, size: 20),
    shouldIconPulse: false,
    messageText: Text(
      message,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    mainButton: action == null
        ? null
        : TextButton(
            onPressed: action.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Text(action.label),
          ),
  ).show(navigatorContext);
}

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

  void showTopNotice(
    String message, {
    Duration duration = const Duration(seconds: 2),
    AppNoticeType type = AppNoticeType.info,
    SnackBarAction? action,
  }) {
    if (!mounted) return;
    _showTopNotice(
      this,
      message,
      duration: duration,
      type: type,
      action: action,
    );
  }

  void showTopSnackBar(SnackBar snackBar) {
    if (!mounted) return;
    _showTopNotice(
      this,
      _extractSnackBarMessage(snackBar.content),
      duration: snackBar.duration,
      type: _inferNoticeType(this, snackBar),
      action: snackBar.action,
    );
  }

  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showTopNotice(
      message,
      duration: duration,
      type: AppNoticeType.info,
      action: action,
    );
  }

  void showErrorSnackBar(String message) {
    showTopNotice(
      message,
      duration: const Duration(seconds: 3),
      type: AppNoticeType.error,
    );
  }

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

extension ScaffoldMessengerNoticeExtension on ScaffoldMessengerState {
  void showTopSnackBar(SnackBar snackBar) {
    _showTopNotice(
      context,
      _extractSnackBarMessage(snackBar.content),
      duration: snackBar.duration,
      type: _inferNoticeType(context, snackBar),
      action: snackBar.action,
    );
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
