import 'package:flutter/material.dart';
import '/src/shared/widgets/adaptive_sheet.dart';
import 'login_form.dart';

/// 统一的添加账户或端点底部表单
class AddAccountBottomSheet {
  /// 显示添加账户底部表单
  static Future<void> show(BuildContext context) {
    return showAdaptiveSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LoginForm(isBottomSheet: true),
    );
  }
}
