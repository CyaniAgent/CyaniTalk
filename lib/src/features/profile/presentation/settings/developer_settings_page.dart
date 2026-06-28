import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/features/profile/application/developer_settings_provider.dart';
import '/src/features/welcome/application/welcome_state.dart';
import '/src/features/welcome/presentation/welcome_page.dart';
import '/src/core/widgets/settings_widgets.dart';
import 'design_playground_page.dart';
import 'log_settings_page.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import '/src/shared/widgets/toast_helper.dart';

class DeveloperSettingsPage extends ConsumerStatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  ConsumerState<DeveloperSettingsPage> createState() =>
      _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends ConsumerState<DeveloperSettingsPage> {
  static const _amber = Color(0xFFFFCA28);
  static const _brown = Color(0xFF8D6E63);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        showToast(
          title: 'could_not_launch_url'.tr(namedArgs: {'url': urlString}),
          type: ToastificationType.error,
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
      appBar: AppBar(title: Text('settings_developer_title'.tr())),
      body: developerModeAsync.when(
        data: (developerMode) => ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            SettingsCardGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.bug_report_outlined,
                  iconColor: _amber,
                  title: 'settings_developer_mode_title'.tr(),
                  subtitle: 'settings_developer_mode_description'.tr(),
                  value: developerMode,
                  onChanged: (value) {
                    if (value) {
                      _showDeveloperModeWarning();
                    } else {
                      ref
                          .read(developerSettingsProvider.notifier)
                          .setDeveloperMode(false);
                    }
                  },
                ),
              ],
            ),

            if (developerMode) ...[
              const SizedBox(height: 16),
              SettingsCardGroup(
                children: [
                  SettingsTile(
                    icon: Icons.open_in_new,
                    iconColor: _amber,
                    title: 'settings_developer_welcome_title'.tr(),
                    subtitle: 'settings_developer_welcome_description'.tr(),
                    onTap: () {
                      ref.read(welcomeCompletedProvider.notifier).reset();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProviderScope(
                            overrides: [
                              currentWelcomeModeProvider.overrideWith(
                                (ref) => WelcomePageMode.debug,
                              ),
                            ],
                            child: const WelcomePage(),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    icon: Icons.design_services_outlined,
                    iconColor: _amber,
                    title: 'settings_developer_design_playground'.tr(),
                    subtitle: 'settings_developer_design_playground_description'.tr(),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DesignPlaygroundPage()),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            SettingsCardGroup(
              children: [
                SettingsTile(
                  icon: Icons.history,
                  iconColor: _brown,
                  title: 'settings_logs_title'.tr(),
                  subtitle: 'settings_logs_description'.tr(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LogSettingsPage()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            SettingsCardGroup(
              children: [
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  iconColor: _brown,
                  title: 'settings_developer_submit_issue'.tr(),
                  onTap: () =>
                      _launchUrl('https://github.com/CyaniAgent/CyaniTalk/issues'),
                ),
                SettingsTile(
                  icon: Icons.merge_type,
                  iconColor: _brown,
                  title: 'settings_developer_submit_pr'.tr(),
                  onTap: () =>
                      _launchUrl('https://github.com/CyaniAgent/CyaniTalk/pulls'),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CyaniLoadingIndicator()),
        error: (_, _) => Center(child: Text('Error')),
      ),
    );
  }

}
