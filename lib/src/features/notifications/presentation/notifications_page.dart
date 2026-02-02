// 通知功能页面
//
// 该文件包含NotificationsPage组件，用于显示应用程序的通知列表。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// 通知功能的主页面组件
///
/// 显示应用程序的通知列表，包含标题栏和中心文本。
class NotificationsPage extends StatelessWidget {
  /// 创建一个新的NotificationsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const NotificationsPage({super.key});

  /// 构建通知页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含标题栏和中心文本的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notifications_title'.tr())),
      body: const NotificationsList(),
    );
  }
}

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('notifications_page'.tr()));
  }
}
