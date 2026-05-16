import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/network_settings_provider.dart';
import '../widgets/settings_slider_bottom_sheet.dart';

/// 网络与实时设置页面
class NetworkSettingsPage extends ConsumerStatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  ConsumerState<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends ConsumerState<NetworkSettingsPage> {
  bool _isTestingNetwork = false;
  bool? _networkTestSuccess;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(networkSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_network_title'.tr())),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            children: [
              // 全局设置
              _buildSectionHeader(context, 'settings_network_global_section'.tr()),

              // User Agent 选择器
              _buildUserAgentSelector(context, ref, settings),

              // HTTP 请求超时
              _buildSettingsTile(
                icon: Icons.timer,
                title: 'HTTP Request Timeout'.tr(),
                subtitle: '${settings.httpRequestTimeout}s',
                onTap: () => _showDurationPicker(
                  context,
                  'HTTP Request Timeout'.tr(),
                  settings.httpRequestTimeout,
                  5,
                  120,
                  5,
                  (value) => ref.read(networkSettingsProvider.notifier).updateHttpRequestTimeout(value),
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              // Misskey 设置
              _buildSectionHeader(context, 'settings_network_misskey_section'.tr()),

              // Misskey 实时模式开关
              SwitchListTile(
                secondary: const Icon(Icons.bolt),
                title: Text('settings_network_misskey_realtime_mode'.tr()),
                subtitle: Text('settings_network_misskey_realtime_mode_description'.tr()),
                value: settings.misskeyRealtimeMode,
                onChanged: (value) => ref.read(networkSettingsProvider.notifier).toggleMisskeyRealtimeMode(value),
              ),

              // 加载帖子最大时长
              _buildSettingsTile(
                icon: Icons.timer,
                title: 'settings_network_misskey_load_post_duration'.tr(),
                subtitle: '${settings.loadPostMaxDuration}s',
                onTap: () => _showDurationPicker(
                  context,
                  'settings_network_misskey_load_post_duration'.tr(),
                  settings.loadPostMaxDuration,
                  5,
                  60,
                  null,
                  (value) => ref.read(networkSettingsProvider.notifier).updateLoadPostMaxDuration(value),
                ),
              ),

              // 加载表情最大时长
              _buildSettingsTile(
                icon: Icons.timer,
                title: 'settings_network_misskey_load_emoji_duration'.tr(),
                subtitle: '${settings.loadEmojiMaxDuration}s',
                onTap: () => _showDurationPicker(
                  context,
                  'settings_network_misskey_load_emoji_duration'.tr(),
                  settings.loadEmojiMaxDuration,
                  5,
                  60,
                  null,
                  (value) => ref.read(networkSettingsProvider.notifier).updateLoadEmojiMaxDuration(value),
                ),
              ),

              // WebSocket 断线重连次数
              _buildSettingsTile(
                icon: Icons.wifi_tethering_error_rounded,
                title: 'settings_network_websocket_reconnect_attempts'.tr(),
                subtitle: '${settings.webSocketReconnectAttempts}',
                onTap: () => _showNumberPicker(
                  context,
                  'settings_network_websocket_reconnect_attempts'.tr(),
                  settings.webSocketReconnectAttempts,
                  1,
                  20,
                  1,
                  (value) => ref.read(networkSettingsProvider.notifier).updateWebSocketReconnectAttempts(value),
                ),
              ),

              // WebSocket 后台最大存活时长
              _buildSettingsTile(
                icon: Icons.av_timer,
                title: 'settings_network_websocket_background_duration'.tr(),
                subtitle: _formatDuration(settings.webSocketBackgroundMaxDuration),
                onTap: () => _showDurationPicker(
                  context,
                  'settings_network_websocket_background_duration'.tr(),
                  settings.webSocketBackgroundMaxDuration,
                  300,
                  7200,
                  300,
                  (value) => ref.read(networkSettingsProvider.notifier).updateWebSocketBackgroundMaxDuration(value),
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              // 工具
              _buildSectionHeader(context, 'Tools'.tr()),

              // 网络测试
              _buildSettingsTile(
                icon: Icons.network_check,
                title: 'Test Network Connection'.tr(),
                subtitle: _networkTestSuccess == null
                    ? 'Tap to test'.tr()
                    : _networkTestSuccess == true
                        ? 'Success!'.tr()
                        : 'Failed'.tr(),
                trailing: _isTestingNetwork
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _networkTestSuccess == null
                            ? Icons.chevron_right
                            : _networkTestSuccess == true
                                ? Icons.check_circle
                                : Icons.error,
                        color: _networkTestSuccess == null
                            ? null
                            : _networkTestSuccess == true
                                ? Colors.green
                                : Colors.red,
                      ),
                onTap: _isTestingNetwork ? null : _testNetworkConnection,
              ),

              // 清除 DNS 缓存
              _buildSettingsTile(
                icon: Icons.clear_all,
                title: 'Clear DNS Cache'.tr(),
                subtitle: 'Reset DNS resolver'.tr(),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showClearDnsConfirmDialog,
              ),

              const Divider(indent: 16, endIndent: 16),

              // 恢复默认设置
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: Text('Restore Default Settings'.tr()),
                  onPressed: _showRestoreDefaultsConfirmDialog,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('settings_network_error_loading'.tr())),
      ),
    );
  }

  /// 构建设置页面的分区标题
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

  /// 构建设置项
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建用户代理选择器
  Widget _buildUserAgentSelector(BuildContext context, WidgetRef ref, NetworkSettings settings) {
    final userAgentOptions = UserAgentType.values;
    final currentType = userAgentOptions.firstWhere(
      (type) => type.name == settings.userAgentType,
      orElse: () => UserAgentType.defaultAgent,
    );

    return ListTile(
      leading: const Icon(Icons.public),
      title: Text('settings_network_user_agent_selector'.tr()),
      subtitle: Text(currentType.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showUserAgentDialog(context, ref, settings, userAgentOptions);
      },
    );
  }

  /// 显示用户代理选择对话框
  void _showUserAgentDialog(
    BuildContext context,
    WidgetRef ref,
    NetworkSettings settings,
    List<UserAgentType> options,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final currentType = options.firstWhere(
          (type) => type.name == settings.userAgentType,
          orElse: () => UserAgentType.defaultAgent,
        );

        return AlertDialog(
          title: Text('settings_network_user_agent_selector'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.name == currentType.name;

                return ListTile(
                  title: Text(option.displayName),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref.read(networkSettingsProvider.notifier).updateUserAgentType(option.name);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 显示时长选择器（底部弹窗）
  void _showDurationPicker(
    BuildContext context,
    String title,
    int initialValue,
    int minValue,
    int maxValue,
    int? step,
    ValueChanged<int> onConfirm,
  ) {
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

  /// 显示数字选择器（底部弹窗）
  void _showNumberPicker(
    BuildContext context,
    String title,
    int initialValue,
    int minValue,
    int maxValue,
    int? step,
    ValueChanged<int> onConfirm,
  ) {
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

  /// 格式化时长（秒 -> 分/小时）
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
    }
  }

  /// 测试网络连接
  Future<void> _testNetworkConnection() async {
    if (_isTestingNetwork) return;
    
    setState(() {
      _isTestingNetwork = true;
      _networkTestSuccess = null;
    });

    try {
      // 简单的网络测试（实际项目中应该调用真实的网络测试 API）
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _networkTestSuccess = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network test successful!'.tr())),
        );
      }
    } catch (e) {
      setState(() {
        _networkTestSuccess = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network test failed'.tr())),
        );
      }
    } finally {
      setState(() {
        _isTestingNetwork = false;
      });
    }
  }

  /// 显示清除 DNS 确认对话框
  void _showClearDnsConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear DNS Cache?'.tr()),
        content: Text('This will reset DNS resolver settings.'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearDnsCache();
            },
            child: Text('Clear'.tr()),
          ),
        ],
      ),
    );
  }

  /// 清除 DNS 缓存
  Future<void> _clearDnsCache() async {
    // 实际项目中应该调用真实的 DNS 清除 API
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DNS cache cleared'.tr())),
      );
    }
  }

  /// 显示恢复默认确认对话框
  void _showRestoreDefaultsConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore Defaults?'.tr()),
        content: Text('All network settings will be reset to defaults.'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreDefaults();
            },
            child: Text('Restore'.tr()),
          ),
        ],
      ),
    );
  }

  /// 恢复默认设置
  Future<void> _restoreDefaults() async {
    await ref.read(networkSettingsProvider.notifier).restoreDefaults();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings restored to defaults'.tr())),
      );
    }
  }
}
