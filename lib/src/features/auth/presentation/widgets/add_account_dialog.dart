import 'package:flutter/material.dart';
import 'login_form.dart';

/// 统一的添加账户或端点底部表单
class AddAccountBottomSheet {
  /// 显示添加账户底部表单
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LoginForm(isBottomSheet: true),
    );
  }
}
