// 设置页面
//
// 该文件包含SettingsPage组件，用于显示应用程序的设置选项。
import 'package:flutter/material.dart';
import 'about_page.dart';

/// 应用程序设置页面组件
///
/// 显示应用程序的各种设置选项，包括账户管理、连接配置、界面设置等。
class SettingsPage extends StatelessWidget {
  /// 创建一个新的SettingsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const SettingsPage({super.key});

  /// 构建设置页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含各种设置选项的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(context, Icons.person_outline, 'Account', 'Manage your accounts'),
          
          _buildSectionHeader(context, 'Connections'),
          _buildSettingsTile(context, Icons.api, 'Flarum Endpoint', 'Configure Flarum server URL'),
          _buildSettingsTile(context, Icons.wifi, 'Network & Real-time', 'WebSocket and API settings'),

          _buildSectionHeader(context, 'Interface'),
          _buildSettingsTile(context, Icons.palette_outlined, 'Appearance', 'Theme, colors, and layout'),
          _buildSettingsTile(context, Icons.notifications_outlined, 'Notifications', 'Push and in-app alerts'),
          _buildSettingsTile(context, Icons.volume_up_outlined, 'Sound', 'Volume and sound effects'),

          _buildSectionHeader(context, 'System'),
          _buildSettingsTile(context, Icons.history, 'Logs', 'View application logs'),
          _buildSettingsTile(context, Icons.storage_outlined, 'Storage', 'Cache and data management'),
          
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            Icons.info_outline,
            'About CyaniTalk',
            'Version, licenses, and contributors',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建设置页面的分区标题
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [title] - 分区标题文本
  ///
  /// 返回一个显示分区标题的Widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// 构建设置选项瓦片
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [icon] - 选项图标
  /// [title] - 选项标题
  /// [subtitle] - 选项描述
  /// [onTap] - 点击事件回调
  ///
  /// 返回一个显示设置选项的ListTile组件
  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped $title')),
            );
          },
    );
  }
}
