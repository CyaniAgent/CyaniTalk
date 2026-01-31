import 'package:flutter/material.dart';

/// UI 工具扩展
/// 提供常用的UI操作快捷方式

extension BuildContextExtension on BuildContext {
  /// 获取媒体查询数据
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 获取屏幕宽度
  double get screenWidth => mediaQuery.size.width;

  /// 获取屏幕高度
  double get screenHeight => mediaQuery.size.height;

  /// 获取屏幕是否为横屏
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// 获取屏幕是否为竖屏
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// 获取键盘高度
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// 判断是否有键盘打开
  bool get hasKeyboard => keyboardHeight > 0;

  /// 获取应用的主题
  ThemeData get theme => Theme.of(this);

  /// 获取应用的配色方案
  ColorScheme get colorScheme => theme.colorScheme;

  /// 获取应用的文本主题
  TextTheme get textTheme => theme.textTheme;

  /// 判断是否为深色主题
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// 显示 SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration, action: action),
    );
  }

  /// 显示错误 SnackBar
  void showErrorSnackBar(String message) {
    showSnackBar(message, duration: const Duration(seconds: 3));
  }

  /// 推送新页面
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// 替换当前页面
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// 弹出当前页面
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// 获取设备像素比
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// 响应式设计：根据宽度返回值
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

/// Widget 扩展
extension WidgetExtension on Widget {
  /// 为 Widget 添加填充
  Padding padding(EdgeInsetsGeometry insets) =>
      Padding(padding: insets, child: this);

  /// 为 Widget 添加居中
  Center centered() => Center(child: this);

  /// 为 Widget 添加阴影效果
  Material withShadow({double elevation = 4, ShapeBorder? shape}) =>
      Material(elevation: elevation, shape: shape, child: this);

  /// 为 Widget 添加单击处理
  GestureDetector onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);

  /// 为 Widget 添加透明度
  Opacity withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// 为 Widget 限制宽度
  ConstrainedBox withMaxWidth(double maxWidth) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: this,
  );

  /// 为 Widget 限制高度
  ConstrainedBox withMaxHeight(double maxHeight) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: maxHeight),
    child: this,
  );

  /// 为 Widget 添加背景色
  Container withBackgroundColor(Color color) =>
      Container(color: color, child: this);

  /// 为 Widget 添加边框
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

/// 响应式布局助手
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

// 使用示例:
//
// // BuildContext 扩展
// context.showSnackBar('Hello');
// bool isDark = context.isDarkMode;
// double width = context.screenWidth;
//
// // Widget 扩展
// Text('Hello').padding(EdgeInsets.all(16)).centered();
// Button().onTap(() => print('Clicked'));
// Image.network(url).withOpacity(0.5);
//
// // 响应式设计
// child: context.responsiveValue(
//   mobile: MobileLayout(),
//   tablet: TabletLayout(),
//   desktop: DesktopLayout(),
// );
