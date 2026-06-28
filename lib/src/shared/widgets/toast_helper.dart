import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

export 'package:toastification/toastification.dart' show ToastificationType, toastification;

void showToast({
  required String title,
  ToastificationType type = ToastificationType.info,
  String? description,
  Duration autoCloseDuration = const Duration(seconds: 3),
  VoidCallback? onTap,
  bool showIcon = true,
}) {
  toastification.show(
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(title),
    description: description != null ? Text(description) : null,
    autoCloseDuration: autoCloseDuration,
    showIcon: showIcon,
    callbacks: onTap != null
        ? ToastificationCallbacks(onTap: (_) => onTap())
        : ToastificationCallbacks(),
  );
}
