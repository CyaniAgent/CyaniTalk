// 导航设置页面
//
// 该文件包含NavigationSettingsPage组件，用于管理应用程序的导航设置，
// 包括底栏（侧栏）选项的显示/隐藏功能。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

part 'navigation_settings_page.g.dart';

/// 导航设置状态
class NavigationSettings {
  /// 是否显示Misskey选项
  final bool showMisskey;

  /// 是否显示Flarum选项
  final bool showFlarum;

  /// 是否显示Drive选项
  final bool showDrive;

  /// 是否显示Messages选项
  final bool showMessages;

  /// 是否显示Me选项
  final bool showMe;

  /// 创建导航设置实例
  const NavigationSettings({
    this.showMisskey = true,
    this.showFlarum = true,
    this.showDrive = true,
    this.showMessages = true,
    this.showMe = true,
  });

  /// 复制并更新导航设置
  NavigationSettings copyWith({
    bool? showMisskey,
    bool? showFlarum,
    bool? showDrive,
    bool? showMessages,
    bool? showMe,
  }) {
    return NavigationSettings(
      showMisskey: showMisskey ?? this.showMisskey,
      showFlarum: showFlarum ?? this.showFlarum,
      showDrive: showDrive ?? this.showDrive,
      showMessages: showMessages ?? this.showMessages,
      showMe: true, // 强制保持个人页面为启用状态
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationSettings &&
          runtimeType == other.runtimeType &&
          showMisskey == other.showMisskey &&
          showFlarum == other.showFlarum &&
          showDrive == other.showDrive &&
          showMessages == other.showMessages &&
          showMe == other.showMe;

  @override
  int get hashCode =>
      showMisskey.hashCode ^
      showFlarum.hashCode ^
      showDrive.hashCode ^
      showMessages.hashCode ^
      showMe.hashCode;
}

/// 导航设置状态管理器
@Riverpod(keepAlive: true)
class NavigationSettingsNotifier extends _$NavigationSettingsNotifier {
  /// 初始化导航设置状态
  @override
  Future<NavigationSettings> build() async {
    // 初始化时尝试从持久化存储加载设置
    final settings = await _loadFromStorage();
    return settings;
  }

  /// 从持久化存储加载设置
  Future<NavigationSettings> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载设置
      final showMisskey = prefs.getBool('navigation_show_misskey') ?? true;
      final showFlarum = prefs.getBool('navigation_show_flarum') ?? true;
      final showDrive = prefs.getBool('navigation_show_drive') ?? true;
      final showMessages = prefs.getBool('navigation_show_messages') ?? true;
      // 强制启用个人页面，不允许禁用
      const showMe = true;

      return NavigationSettings(
        showMisskey: showMisskey,
        showFlarum: showFlarum,
        showDrive: showDrive,
        showMessages: showMessages,
        showMe: showMe,
      );
    } catch (e) {
      // 加载失败时返回默认设置
      return const NavigationSettings();
    }
  }

  /// 保存设置到持久化存储
  Future<void> _saveToStorage(NavigationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存设置
      await prefs.setBool('navigation_show_misskey', settings.showMisskey);
      await prefs.setBool('navigation_show_flarum', settings.showFlarum);
      await prefs.setBool('navigation_show_drive', settings.showDrive);
      await prefs.setBool('navigation_show_messages', settings.showMessages);
      // 强制保存个人页面为启用状态
      await prefs.setBool('navigation_show_me', true);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 更新Misskey选项的显示状态
  Future<void> updateShowMisskey(bool value) async {
    final newState = state.value!.copyWith(showMisskey: value);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新Flarum选项的显示状态
  Future<void> updateShowFlarum(bool value) async {
    final newState = state.value!.copyWith(showFlarum: value);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新Drive选项的显示状态
  Future<void> updateShowDrive(bool value) async {
    final newState = state.value!.copyWith(showDrive: value);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新Messages选项的显示状态
  Future<void> updateShowMessages(bool value) async {
    final newState = state.value!.copyWith(showMessages: value);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新Me选项的显示状态
  /// 注意：个人页面不允许被禁用，此方法会忽略传入的value，始终保持启用状态
  Future<void> updateShowMe(bool value) async {
    // 强制启用个人页面，忽略传入的value
    final newState = state.value!.copyWith(showMe: true);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 重置配置
  Future<void> resetSettings() async {
    final newState = const NavigationSettings();
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }
}

/// 导航设置页面组件
///
/// 显示应用程序的导航设置选项，包括底栏（侧栏）选项的显示/隐藏切换。
class NavigationSettingsPage extends ConsumerStatefulWidget {
  /// 创建一个新的NavigationSettingsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const NavigationSettingsPage({super.key});

  @override
  ConsumerState<NavigationSettingsPage> createState() =>
      _NavigationSettingsPageState();
}

class _NavigationSettingsPageState
    extends ConsumerState<NavigationSettingsPage> {
  /// 构建导航设置页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含导航设置选项的Scaffold组件
  @override
  Widget build(BuildContext context) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);
    final navigationNotifier = ref.read(navigationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings_navigation_title'.tr())),
      body: navigationSettingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('settings_navigation_error_loading'.tr())),
        data: (navigationSettings) {
          return ListView(
            children: [
              _buildSectionHeader(
                context,
                'settings_navigation_section_items'.tr(),
              ),

              // 导航项设置
              _buildSwitchTile(
                context,
                Icons.public_outlined,
                'nav_misskey'.tr(),
                'settings_navigation_show_misskey'.tr(),
                navigationSettings.showMisskey,
                (value) => navigationNotifier.updateShowMisskey(value),
              ),

              Divider(indent: 72, height: 1, thickness: 0.5),

              _buildSwitchTile(
                context,
                Icons.forum_outlined,
                'nav_flarum'.tr(),
                'settings_navigation_show_flarum'.tr(),
                navigationSettings.showFlarum,
                (value) => navigationNotifier.updateShowFlarum(value),
              ),

              Divider(indent: 72, height: 1, thickness: 0.5),

              _buildSwitchTile(
                context,
                Icons.cloud_queue_outlined,
                'nav_drive'.tr(),
                'settings_navigation_show_drive'.tr(),
                navigationSettings.showDrive,
                (value) => navigationNotifier.updateShowDrive(value),
              ),

              Divider(indent: 72, height: 1, thickness: 0.5),

              _buildSwitchTile(
                context,
                Icons.chat_bubble_outline,
                'nav_messages'.tr(),
                'settings_navigation_show_messages'.tr(),
                navigationSettings.showMessages,
                (value) => navigationNotifier.updateShowMessages(value),
              ),

              Divider(indent: 72, height: 1, thickness: 0.5),

              _buildSwitchTile(
                context,
                Icons.person_outline,
                'nav_me'.tr(),
                'settings_navigation_show_me'.tr(),
                true, // 强制显示为开启状态
                null, // 禁用开关，不允许用户修改
              ),

              const SizedBox(height: 24),
              // 重置导航配置按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      _showResetConfirmation(context, navigationNotifier),
                  icon: const Icon(Icons.restart_alt),
                  label: Text('settings_navigation_reset_config'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    NavigationSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_navigation_reset_config'.tr()),
        content: Text('settings_navigation_reset_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('accounts_remove_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              notifier.resetSettings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('settings_navigation_reset_done'.tr())),
              );
            },
            child: Text('post_reset'.tr()),
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

  /// 构建带开关的设置瓦片
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [icon] - 选项图标
  /// [title] - 选项标题
  /// [subtitle] - 选项描述
  /// [value] - 开关当前值
  /// [onChanged] - 开关状态变化回调
  ///
  /// 返回一个带开关的ListTile组件
  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: onChanged == null ? Theme.of(context).disabledColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: onChanged == null ? Theme.of(context).disabledColor : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: onChanged == null ? Theme.of(context).disabledColor : null,
        ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      enabled: onChanged != null,
    );
  }
}
