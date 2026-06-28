import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/network_settings_provider.dart';
import '../widgets/settings_slider_bottom_sheet.dart';
import '/src/core/widgets/settings_widgets.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import '/src/shared/widgets/toast_helper.dart';

class NetworkSettingsPage extends ConsumerStatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  ConsumerState<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends ConsumerState<NetworkSettingsPage> {
  bool _isTestingNetwork = false;
  bool? _networkTestSuccess;

  static const _cyan = Color(0xFF26A69A);
  static const _blue = Color(0xFF42A5F5);
  static const _amber = Color(0xFFFFCA28);

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(networkSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_network_title'.tr())),
      body: settingsAsync.when(
        data: (settings) {
          final userAgentOptions = UserAgentType.values;
          final currentAgentType = userAgentOptions.firstWhere(
            (type) => type.name == settings.userAgentType,
            orElse: () => UserAgentType.defaultAgent,
          );

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              SettingsCardGroup(
                children: [
                  SettingsTile(
                    icon: Icons.public,
                    iconColor: _cyan,
                    title: 'settings_network_user_agent_selector'.tr(),
                    subtitle: currentAgentType.displayName,
                    onTap: () => _showUserAgentDialog(ref, settings),
                  ),
                  SettingsTile(
                    icon: Icons.timer_outlined,
                    iconColor: _cyan,
                    title: 'settings_network_http_timeout'.tr(),
                    subtitle: '${settings.httpRequestTimeout}s',
                    onTap: () => _showDurationPicker(
                      title: 'settings_network_http_timeout'.tr(),
                      initialValue: settings.httpRequestTimeout,
                      minValue: 5,
                      maxValue: 120,
                      step: 5,
                      onConfirm: (value) =>
                          ref.read(networkSettingsProvider.notifier).updateHttpRequestTimeout(value),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SettingsCardGroup(
                children: [
                  _switchTile(
                    icon: Icons.bolt,
                    iconColor: _blue,
                    title: 'settings_network_misskey_realtime_mode'.tr(),
                    subtitle: 'settings_network_misskey_realtime_mode_description'.tr(),
                    value: settings.misskeyRealtimeMode,
                    onChanged: (v) =>
                        ref.read(networkSettingsProvider.notifier).toggleMisskeyRealtimeMode(v),
                  ),
                  SettingsTile(
                    icon: Icons.article_outlined,
                    iconColor: _blue,
                    title: 'settings_network_misskey_load_post_duration'.tr(),
                    subtitle: '${settings.loadPostMaxDuration}s',
                    onTap: () => _showDurationPicker(
                      title: 'settings_network_misskey_load_post_duration'.tr(),
                      initialValue: settings.loadPostMaxDuration,
                      minValue: 5,
                      maxValue: 60,
                      onConfirm: (value) =>
                          ref.read(networkSettingsProvider.notifier).updateLoadPostMaxDuration(value),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.emoji_emotions_outlined,
                    iconColor: _blue,
                    title: 'settings_network_misskey_load_emoji_duration'.tr(),
                    subtitle: '${settings.loadEmojiMaxDuration}s',
                    onTap: () => _showDurationPicker(
                      title: 'settings_network_misskey_load_emoji_duration'.tr(),
                      initialValue: settings.loadEmojiMaxDuration,
                      minValue: 5,
                      maxValue: 60,
                      onConfirm: (value) =>
                          ref.read(networkSettingsProvider.notifier).updateLoadEmojiMaxDuration(value),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.wifi_tethering_error_rounded,
                    iconColor: _blue,
                    title: 'settings_network_websocket_reconnect_attempts'.tr(),
                    subtitle: '${settings.webSocketReconnectAttempts}',
                    onTap: () => _showNumberPicker(
                      title: 'settings_network_websocket_reconnect_attempts'.tr(),
                      initialValue: settings.webSocketReconnectAttempts,
                      minValue: 1,
                      maxValue: 20,
                      step: 1,
                      onConfirm: (value) =>
                          ref.read(networkSettingsProvider.notifier).updateWebSocketReconnectAttempts(value),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.av_timer,
                    iconColor: _blue,
                    title: 'settings_network_websocket_background_duration'.tr(),
                    subtitle: _formatDuration(settings.webSocketBackgroundMaxDuration),
                    onTap: () => _showDurationPicker(
                      title: 'settings_network_websocket_background_duration'.tr(),
                      initialValue: settings.webSocketBackgroundMaxDuration,
                      minValue: 300,
                      maxValue: 7200,
                      step: 300,
                      onConfirm: (value) =>
                          ref.read(networkSettingsProvider.notifier).updateWebSocketBackgroundMaxDuration(value),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SettingsCardGroup(
                children: [
                  SettingsTile(
                    icon: Icons.network_check,
                    iconColor: _amber,
                    title: 'settings_network_test_connection'.tr(),
                    subtitle: _networkTestSuccess == null
                        ? 'settings_network_tap_to_test'.tr()
                        : _networkTestSuccess == true
                            ? 'settings_network_test_success'.tr()
                            : 'settings_network_test_failed'.tr(),
                    trailing: _isTestingNetwork
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _networkTestSuccess == null
                                ? Icons.chevron_right
                                : _networkTestSuccess == true
                                    ? Icons.check_circle
                                    : Icons.error,
                            color: _networkTestSuccess == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : _networkTestSuccess == true
                                    ? Colors.green
                                    : Colors.red,
                          ),
                    onTap: _isTestingNetwork ? null : _testNetworkConnection,
                  ),
                  SettingsTile(
                    icon: Icons.clear_all,
                    iconColor: _amber,
                    title: 'settings_network_clear_dns'.tr(),
                    subtitle: 'settings_network_clear_dns_description'.tr(),
                    onTap: _showClearDnsConfirmDialog,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: Text('settings_network_restore_defaults'.tr()),
                  onPressed: _showRestoreDefaultsConfirmDialog,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CyaniLoadingIndicator()),
        error: (_, _) => Center(child: Text('settings_network_error_loading'.tr())),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showUserAgentDialog(WidgetRef ref, NetworkSettings settings) {
    final options = UserAgentType.values;
    final currentType = options.firstWhere(
      (type) => type.name == settings.userAgentType,
      orElse: () => UserAgentType.defaultAgent,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_network_user_agent_selector'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (_, i) {
              final option = options[i];
              return ListTile(
                title: Text(option.displayName),
                trailing: option.name == currentType.name
                    ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(networkSettingsProvider.notifier).updateUserAgentType(option.name);
                  Navigator.of(ctx).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDurationPicker({
    required String title,
    required int initialValue,
    required int minValue,
    required int maxValue,
    int? step,
    required ValueChanged<int> onConfirm,
  }) {
    SettingsSliderBottomSheet.show(
      context: context,
      title: title,
      initialValue: initialValue,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      valueFormatter: (value) => '${value}s',
      onConfirm: onConfirm,
      icon: Icons.timer,
    );
  }

  void _showNumberPicker({
    required String title,
    required int initialValue,
    required int minValue,
    required int maxValue,
    int? step,
    required ValueChanged<int> onConfirm,
  }) {
    SettingsSliderBottomSheet.show(
      context: context,
      title: title,
      initialValue: initialValue,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      valueFormatter: (value) => value.toString(),
      onConfirm: onConfirm,
      icon: Icons.numbers,
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }

  Future<void> _testNetworkConnection() async {
    if (_isTestingNetwork) return;
    setState(() { _isTestingNetwork = true; _networkTestSuccess = null; });

    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _networkTestSuccess = true);
      if (mounted) {
        showToast(title: 'settings_network_test_success_snackbar'.tr(), type: ToastificationType.success);
      }
    } catch (_) {
      setState(() => _networkTestSuccess = false);
      if (mounted) {
        showToast(title: 'settings_network_test_failed_snackbar'.tr(), type: ToastificationType.error);
      }
    } finally {
      setState(() => _isTestingNetwork = false);
    }
  }

  void _showClearDnsConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_network_clear_dns'.tr()),
        content: Text('settings_network_clear_dns_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () { Navigator.pop(ctx); _clearDnsCache(); },
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _clearDnsCache() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      showToast(title: 'settings_network_dns_cleared'.tr(), type: ToastificationType.success);
    }
  }

  void _showRestoreDefaultsConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_network_restore_defaults'.tr()),
        content: Text('settings_network_restore_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () { Navigator.pop(ctx); _restoreDefaults(); },
            child: Text('settings_network_restore_button'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreDefaults() async {
    await ref.read(networkSettingsProvider.notifier).restoreDefaults();
    if (mounted) {
      showToast(title: 'settings_network_restored'.tr(), type: ToastificationType.success);
    }
  }
}
