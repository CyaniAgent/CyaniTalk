import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/developer_settings_provider.dart';
import 'log_settings_page.dart';

/// 开发者设置页面组件
class DeveloperSettingsPage extends ConsumerStatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  ConsumerState<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends ConsumerState<DeveloperSettingsPage> {
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

  Future<void> _showDeveloperModeWarning() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: Text('settings_developer_mode_warning_title'.tr()),
        content: Text('settings_developer_mode_warning_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('settings_developer_mode_warning_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('settings_developer_mode_warning_confirm'.tr()),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ref.read(developerSettingsProvider.notifier).setDeveloperMode(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final developerModeAsync = ref.watch(developerSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings_developer_title'.tr()),
      ),
      body: developerModeAsync.when(
        data: (developerMode) => ListView(
          children: [
            _buildSectionHeader(context, 'settings_logs_section_basic'.tr()),
            SwitchListTile(
              secondary: const Icon(Icons.bug_report_outlined),
              title: Text('settings_developer_mode_title'.tr()),
              subtitle: Text('settings_developer_mode_description'.tr()),
              value: developerMode,
              onChanged: (value) {
                if (value) {
                  _showDeveloperModeWarning();
                } else {
                  ref.read(developerSettingsProvider.notifier).setDeveloperMode(false);
                }
              },
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
