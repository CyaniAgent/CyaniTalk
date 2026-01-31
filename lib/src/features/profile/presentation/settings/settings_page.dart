// 设置页面
//
// 该文件包含SettingsPage组件，用于显示应用程序的设置选项。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'about_page.dart';
import 'accounts_page.dart';

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
        title: Text('settings_title'.tr()),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'settings_section_account'.tr()),
          _buildSettingsTile(
            context,
            Icons.person_outline,
            'settings_account_title'.tr(),
            'settings_account_description'.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountsPage()),
              );
            },
          ),
          
          _buildSectionHeader(context, 'settings_section_connections'.tr()),
          _buildSettingsTile(context, Icons.api, 'settings_flarum_endpoint_title'.tr(), 'settings_flarum_endpoint_description'.tr()),
          _buildSettingsTile(context, Icons.wifi, 'settings_network_title'.tr(), 'settings_network_description'.tr()),

          _buildSectionHeader(context, 'settings_section_interface'.tr()),
          _buildSettingsTile(context, Icons.palette_outlined, 'settings_appearance_title'.tr(), 'settings_appearance_description'.tr()),
          _buildSettingsTile(
            context,
            Icons.language_outlined,
            'settings_language_title'.tr(),
            'settings_language_description'.tr(),
            onTap: () => _showLanguageDialog(context),
          ),
          _buildSettingsTile(context, Icons.notifications_outlined, 'settings_notifications_title'.tr(), 'settings_notifications_description'.tr()),
          _buildSettingsTile(context, Icons.volume_up_outlined, 'settings_sound_title'.tr(), 'settings_sound_description'.tr()),

          _buildSectionHeader(context, 'settings_section_system'.tr()),
          _buildSettingsTile(context, Icons.history, 'settings_logs_title'.tr(), 'settings_logs_description'.tr()),
          _buildSettingsTile(context, Icons.storage_outlined, 'settings_storage_title'.tr(), 'settings_storage_description'.tr()),
          
          _buildSectionHeader(context, 'settings_section_about'.tr()),
          _buildSettingsTile(
            context,
            Icons.info_outline,
            'settings_about_title'.tr(),
            'settings_about_description'.tr(),
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
              SnackBar(content: Text('settings_tapped'.tr(namedArgs: {'title': title}))),
            );
          },
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final currentLocale = context.locale;
        return AlertDialog(
          title: Text('settings_language_select_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('settings_language_chinese'.tr()),
                onTap: () {
                  context.setLocale(const Locale('zh', 'CN'));
                  Navigator.pop(context);
                },
                trailing: currentLocale == const Locale('zh', 'CN')
                    ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
                    : Icon(Icons.radio_button_off, color: Theme.of(context).colorScheme.outline),
              ),
              ListTile(
                title: Text('settings_language_english'.tr()),
                onTap: () {
                  context.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
                trailing: currentLocale == const Locale('en', 'US')
                    ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
                    : Icon(Icons.radio_button_off, color: Theme.of(context).colorScheme.outline),
              ),
              ListTile(
                title: Text('settings_language_japanese'.tr()),
                onTap: () {
                  context.setLocale(const Locale('ja', 'JP'));
                  Navigator.pop(context);
                },
                trailing: currentLocale == const Locale('ja', 'JP')
                    ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
                    : Icon(Icons.radio_button_off, color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
        );
      },
    );
  }
}
