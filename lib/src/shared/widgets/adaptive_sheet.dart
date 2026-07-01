import 'dart:io' show Platform;
import 'package:flutter/material.dart';

bool get _isDesktop {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return true;
  return false;
}

Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  ShapeBorder? shape,
  Color? backgroundColor,
  Color? barrierColor,
  double sideSheetWidth = 400,
  BorderRadiusGeometry? sideSheetBorderRadius,
}) {
  if (_isDesktop) {
    return _showSideSheet<T>(
      context: context,
      builder: builder,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      sideSheetWidth: sideSheetWidth,
      sideSheetBorderRadius: sideSheetBorderRadius ??
          const BorderRadius.horizontal(left: Radius.circular(16)),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    shape: shape,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    builder: builder,
  );
}

Future<T?> _showSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  double sideSheetWidth = 400,
  BorderRadiusGeometry? sideSheetBorderRadius,
}) {
  final viewInsets = MediaQuery.viewInsetsOf(context);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        )),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: SizedBox(
              width: sideSheetWidth,
              child: Material(
                elevation: 8,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: sideSheetBorderRadius,
                clipBehavior: Clip.antiAlias,
                child: builder(context),
              ),
            ),
          ),
        ),
      );
    },
  );
}
