import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/network_settings_provider.dart';

/// 网络与实时设置页面
class NetworkSettingsPage extends ConsumerWidget {
  const NetworkSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(networkSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings_network_title'.tr())),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'settings_network_global_section'.tr()),
              
              // User Agent 选择器
              _buildUserAgentSelector(context, ref, settings),
              
              const Divider(indent: 16, endIndent: 16),
              
              _buildSectionHeader(context, 'settings_network_misskey_section'.tr()),
              
              // Misskey 实时模式开关
              _buildSwitchTile(
                context,
                Icons.bolt,
                'settings_network_misskey_realtime_mode'.tr(),
                'settings_network_misskey_realtime_mode_description'.tr(),
                settings.misskeyRealtimeMode,
                (value) => ref.read(networkSettingsProvider.notifier).toggleMisskeyRealtimeMode(value),
              ),
              
              // 加载帖子最大时长
              _buildDurationTile(
                context,
                Icons.timer,
                'settings_network_misskey_load_post_duration'.tr(),
                settings.loadPostMaxDuration,
                (value) => ref.read(networkSettingsProvider.notifier).updateLoadPostMaxDuration(value),
                5, 60, // 5-60秒范围
              ),
              
              // 加载表情最大时长
              _buildDurationTile(
                context,
                Icons.timer,
                'settings_network_misskey_load_emoji_duration'.tr(),
                settings.loadEmojiMaxDuration,
                (value) => ref.read(networkSettingsProvider.notifier).updateLoadEmojiMaxDuration(value),
                5, 60, // 5-60秒范围
              ),
              
              // WebSocket 断线重连次数
              _buildNumberTile(
                context,
                Icons.wifi_tethering_error_rounded,
                'settings_network_websocket_reconnect_attempts'.tr(),
                settings.webSocketReconnectAttempts,
                (value) => ref.read(networkSettingsProvider.notifier).updateWebSocketReconnectAttempts(value),
                1, 20, // 1-20次范围
              ),
              
              // WebSocket 后台最大存活时长
              _buildDurationTile(
                context,
                Icons.av_timer,
                'settings_network_websocket_background_duration'.tr(),
                settings.webSocketBackgroundMaxDuration,
                (value) => ref.read(networkSettingsProvider.notifier).updateWebSocketBackgroundMaxDuration(value),
                300, 7200, // 5分钟-2小时范围
              ),
              
              const Divider(indent: 16, endIndent: 16),
              
              _buildSectionHeader(context, 'settings_network_flarum_section'.tr()),
              
              // Flarum 讨论最大加载时长
              _buildDurationTile(
                context,
                Icons.timer,
                'settings_network_flarum_discussion_max_load_duration'.tr(),
                settings.flarumDiscussionMaxLoadDuration,
                (value) => ref.read(networkSettingsProvider.notifier).updateFlarumDiscussionMaxLoadDuration(value),
                5, 60, // 5-60秒范围
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
                return RadioListTile<String>(
                  title: Text(option.displayName),
                  value: option.name,
                  groupValue: currentType.name,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(networkSettingsProvider.notifier).updateUserAgentType(value);
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  /// 构建时长设置项
  Widget _buildDurationTile(
    BuildContext context,
    IconData icon,
    String title,
    int currentValue,
    ValueChanged<int> onChanged,
    int minValue,
    int maxValue,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text('${currentValue}s'),
      trailing: SizedBox(
        width: 100,
        child: Slider(
          value: currentValue.toDouble(),
          min: minValue.toDouble(),
          max: maxValue.toDouble(),
          divisions: (maxValue - minValue),
          label: '${currentValue}s',
          onChanged: (value) {
            onChanged(value.round());
          },
        ),
      ),
      onTap: () {
        _showDurationInputDialog(
          context,
          title,
          currentValue,
          (value) => onChanged(value),
          minValue,
          maxValue,
        );
      },
    );
  }

  /// 构建数字设置项
  Widget _buildNumberTile(
    BuildContext context,
    IconData icon,
    String title,
    int currentValue,
    ValueChanged<int> onChanged,
    int minValue,
    int maxValue,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(currentValue.toString()),
      trailing: SizedBox(
        width: 100,
        child: Slider(
          value: currentValue.toDouble(),
          min: minValue.toDouble(),
          max: maxValue.toDouble(),
          divisions: (maxValue - minValue),
          label: currentValue.toString(),
          onChanged: (value) {
            onChanged(value.round());
          },
        ),
      ),
      onTap: () {
        _showNumberInputDialog(
          context,
          title,
          currentValue,
          (value) => onChanged(value),
          minValue,
          maxValue,
        );
      },
    );
  }

  /// 显示时长输入对话框
  void _showDurationInputDialog(
    BuildContext context,
    String title,
    int currentValue,
    ValueChanged<int> onChanged,
    int minValue,
    int maxValue,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '$minValue - $maxValue',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= minValue && value <= maxValue) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'.tr()),
            ),
          ],
        );
      },
    );
  }

  /// 显示数字输入对话框
  void _showNumberInputDialog(
    BuildContext context,
    String title,
    int currentValue,
    ValueChanged<int> onChanged,
    int minValue,
    int maxValue,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '$minValue - $maxValue',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= minValue && value <= maxValue) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'.tr()),
            ),
          ],
        );
      },
    );
  }
}