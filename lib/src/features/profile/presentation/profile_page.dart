// 用户个人资料页面
//
// 该文件包含ProfilePage组件，用于显示用户的个人资料信息和关联账户。
import 'package:flutter/material.dart';
import 'widgets/associated_accounts_section.dart';
import 'settings/settings_page.dart';

/// 用户个人资料主页面组件
///
/// 显示用户的个人资料信息，包括关联账户列表和设置入口。
class ProfilePage extends StatelessWidget {
  /// 创建一个新的ProfilePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const ProfilePage({super.key});

  /// 构建用户个人资料页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含标题栏、关联账户列表和设置入口的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: const [AssociatedAccountsSection()]),
      ),
    );
  }
}
