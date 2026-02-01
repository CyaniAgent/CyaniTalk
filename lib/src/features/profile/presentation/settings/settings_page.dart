// 设置页面
//
// 该文件包含SettingsPage组件，用于显示应用程序的设置选项。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_page.dart';
import 'accounts_page.dart';
import 'appearance_page.dart';

/// 应用程序设置页面组件
///
/// 显示应用程序的各种设置选项，包括账户管理、连接配置、界面设置等。
class SettingsPage extends StatefulWidget {
  /// 创建一个新的SettingsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// 是否显示喵星语选项
  bool showMiaoLanguage = false;

  @override
  void initState() {
    super.initState();
    _loadShowMiaoLanguage();
  }

  /// 加载是否显示喵星语选项的设置
  Future<void> _loadShowMiaoLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool('show_miao_language') ?? false;
      setState(() {
        showMiaoLanguage = value;
      });
    } catch (e) {
      // 加载失败时使用默认值
      setState(() {
        showMiaoLanguage = false;
      });
    }
  }

  /// 保存是否显示喵星语选项的设置
  Future<void> _saveShowMiaoLanguage(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_miao_language', value);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 构建设置页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含各种设置选项的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
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
          _buildSettingsTile(
            context,
            Icons.api,
            'settings_flarum_endpoint_title'.tr(),
            'settings_flarum_endpoint_description'.tr(),
          ),
          _buildSettingsTile(
            context,
            Icons.wifi,
            'settings_network_title'.tr(),
            'settings_network_description'.tr(),
          ),

          _buildSectionHeader(context, 'settings_section_interface'.tr()),
          _buildSettingsTile(
            context,
            Icons.palette_outlined,
            'settings_appearance_title'.tr(),
            'settings_appearance_description'.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppearancePage()),
              );
            },
          ),
          GestureDetector(
            onDoubleTap: () {
              final newValue = !showMiaoLanguage;
              setState(() {
                showMiaoLanguage = newValue;
              });
              _saveShowMiaoLanguage(newValue);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(newValue ? '已解锁喵星语选项！' : '已隐藏喵星语选项')),
              );
            },
            child: _buildSettingsTile(
              context,
              Icons.language_outlined,
              'settings_language_title'.tr(),
              'settings_language_description'.tr(),
              onTap: () => _showLanguageDialog(context),
            ),
          ),
          _buildSettingsTile(
            context,
            Icons.notifications_outlined,
            'settings_notifications_title'.tr(),
            'settings_notifications_description'.tr(),
          ),
          _buildSettingsTile(
            context,
            Icons.volume_up_outlined,
            'settings_sound_title'.tr(),
            'settings_sound_description'.tr(),
          ),

          _buildSectionHeader(context, 'settings_section_system'.tr()),
          _buildSettingsTile(
            context,
            Icons.history,
            'settings_logs_title'.tr(),
            'settings_logs_description'.tr(),
          ),
          _buildSettingsTile(
            context,
            Icons.storage_outlined,
            'settings_storage_title'.tr(),
            'settings_storage_description'.tr(),
          ),

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
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'settings_tapped'.tr(namedArgs: {'title': title}),
                ),
              ),
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
        final List<Widget> languageOptions = [
          ListTile(
            title: Text('settings_language_chinese'.tr()),
            onTap: () {
              context.setLocale(const Locale('zh', 'CN'));
              Navigator.pop(context);
            },
            trailing: currentLocale == const Locale('zh', 'CN')
                ? Icon(
                    Icons.radio_button_checked,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.radio_button_off,
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
          ListTile(
            title: Text('settings_language_english'.tr()),
            onTap: () {
              context.setLocale(const Locale('en', 'US'));
              Navigator.pop(context);
            },
            trailing: currentLocale == const Locale('en', 'US')
                ? Icon(
                    Icons.radio_button_checked,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.radio_button_off,
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
          ListTile(
            title: Text('settings_language_japanese'.tr()),
            onTap: () {
              context.setLocale(const Locale('ja', 'JP'));
              Navigator.pop(context);
            },
            trailing: currentLocale == const Locale('ja', 'JP')
                ? Icon(
                    Icons.radio_button_checked,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.radio_button_off,
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
        ];

        // 如果启用了喵星语选项，添加喵星语相关选项
        if (showMiaoLanguage) {
          languageOptions.addAll([
            ListTile(
              title: Text('喵星语'),
              onTap: () {
                context.setLocale(const Locale('zh', 'Miao'));
                Navigator.pop(context);
              },
              trailing: currentLocale == const Locale('zh', 'Miao')
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.outline,
                    ),
            ),
            ListTile(
              title: Text('にゃ語'),
              onTap: () {
                context.setLocale(const Locale('ja', 'Miao'));
                Navigator.pop(context);
              },
              trailing: currentLocale == const Locale('ja', 'Miao')
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.outline,
                    ),
            ),
            ListTile(
              title: Text('Meow Language（英文）'),
              onTap: () {
                context.setLocale(const Locale('en', 'Miao'));
                Navigator.pop(context);
              },
              trailing: currentLocale == const Locale('en', 'Miao')
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.outline,
                    ),
            ),
            ListTile(
              title: Text('Meow Meow Meow'),
              onTap: () {
                context.setLocale(const Locale('miao', 'Miao'));
                Navigator.pop(context);
              },
              trailing: currentLocale == const Locale('miao', 'Miao')
                  ? Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.outline,
                    ),
            ),
          ]);
        }

        return AlertDialog(
          title: Text('settings_language_select_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languageOptions,
          ),
        );
      },
    );
  }
}
