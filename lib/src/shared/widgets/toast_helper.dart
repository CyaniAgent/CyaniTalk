import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

export 'package:toastification/toastification.dart' show ToastificationItem, ToastificationType, toastification;

/// 显示一个 Toast 通知，返回 [ToastificationItem] 可用于后续 dismiss。
ToastificationItem showToast({
  required String title,
  ToastificationType type = ToastificationType.info,
  String? description,
  Duration? autoCloseDuration,
  VoidCallback? onTap,
  bool showIcon = true,
}) {
  return toastification.show(
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(title),
    description: description != null ? Text(description) : null,
    autoCloseDuration: autoCloseDuration ?? const Duration(seconds: 3),
    showIcon: showIcon,
    callbacks: onTap != null
        ? ToastificationCallbacks(onTap: (_) => onTap())
        : const ToastificationCallbacks(),
  );
}
