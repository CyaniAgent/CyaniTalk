import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'log_settings_page.dart';

/// 开发者设置页面组件
class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  bool _developerMode = false;

  @override
  void initState() {
    super.initState();
    _loadDeveloperMode();
  }

  Future<void> _loadDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _developerMode = prefs.getBool('developer_mode') ?? false;
    });
  }

  Future<void> _toggleDeveloperMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('developer_mode', value);
    setState(() {
      _developerMode = value;
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_launch_url'.tr(namedArgs: {'url': urlString}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_developer_title'.tr()),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'settings_logs_section_basic'.tr()),
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: Text('settings_developer_mode_title'.tr()),
            subtitle: Text('settings_developer_mode_description'.tr()),
            value: _developerMode,
            onChanged: _toggleDeveloperMode,
          ),
          
          const Divider(),
          _buildSectionHeader(context, 'settings_section_system'.tr()),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text('settings_logs_title'.tr()),
            subtitle: Text('settings_logs_description'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LogSettingsPage()),
              );
            },
          ),

          const Divider(),
          _buildSectionHeader(context, 'about_contributors'.tr()),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text('settings_developer_submit_issue'.tr()),
            onTap: () => _launchUrl('https://github.com/CyaniAgent/CyaniTalk/issues'),
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: Text('settings_developer_submit_pr'.tr()),
            onTap: () => _launchUrl('https://github.com/CyaniAgent/CyaniTalk/pulls'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
