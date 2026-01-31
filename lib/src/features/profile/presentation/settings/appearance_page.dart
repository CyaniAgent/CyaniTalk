// 外观设置页面
//
// 该文件包含AppearancePage组件，用于管理应用程序的外观设置，
// 包括深色模式和动态色彩功能。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_page.g.dart';

/// 外观设置状态
class AppearanceSettings {
  /// 是否启用深色模式
  final bool isDarkMode;

  /// 是否启用动态色彩
  final bool useDynamicColor;

  /// 创建外观设置实例
  const AppearanceSettings({
    required this.isDarkMode,
    required this.useDynamicColor,
  });

  /// 复制并更新外观设置
  AppearanceSettings copyWith({bool? isDarkMode, bool? useDynamicColor}) {
    return AppearanceSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
}

/// 外观设置状态管理器
@Riverpod(keepAlive: true)
class AppearanceSettingsNotifier extends _$AppearanceSettingsNotifier {
  /// 初始化外观设置状态
  @override
  AppearanceSettings build() {
    // 初始化时尝试从系统设置获取
    _initializeFromSystem();
    return const AppearanceSettings(isDarkMode: false, useDynamicColor: true);
  }

  /// 从系统设置初始化
  void _initializeFromSystem() {
    // 这里可以添加从持久化存储加载设置的逻辑
  }

  /// 切换深色模式
  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    // 这里可以添加保存设置到持久化存储的逻辑
  }

  /// 切换动态色彩
  void toggleDynamicColor() {
    state = state.copyWith(useDynamicColor: !state.useDynamicColor);
    // 这里可以添加保存设置到持久化存储的逻辑
  }
}

/// 外观设置页面组件
///
/// 显示应用程序的外观设置选项，包括深色模式和动态色彩切换。
class AppearancePage extends ConsumerStatefulWidget {
  /// 创建一个新的AppearancePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const AppearancePage({super.key});

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  /// 构建外观设置页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含外观设置选项的Scaffold组件
  @override
  Widget build(BuildContext context) {
    final appearanceSettings = ref.watch(appearanceSettingsProvider);
    final appearanceNotifier = ref.read(appearanceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings_appearance_title'.tr())),
      body: ListView(
        children: [
          _buildSectionHeader(
            context,
            'settings_appearance_section_display'.tr(),
          ),

          // 深色模式设置
          _buildSwitchTile(
            context,
            Icons.dark_mode_outlined,
            'settings_appearance_dark_mode'.tr(),
            'settings_appearance_dark_mode_description'.tr(),
            appearanceSettings.isDarkMode,
            (value) => appearanceNotifier.toggleDarkMode(),
          ),

          // 动态色彩设置
          _buildSwitchTile(
            context,
            Icons.color_lens_outlined,
            'settings_appearance_dynamic_color'.tr(),
            'settings_appearance_dynamic_color_description'.tr(),
            appearanceSettings.useDynamicColor,
            (value) => appearanceNotifier.toggleDynamicColor(),
          ),

          _buildSectionHeader(
            context,
            'settings_appearance_section_preview'.tr(),
          ),

          // 外观预览卡片
          _buildPreviewCard(context, appearanceSettings),
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
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  /// 构建外观预览卡片
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [settings] - 当前外观设置
  ///
  /// 返回一个显示外观预览的卡片组件
  Widget _buildPreviewCard(BuildContext context, AppearanceSettings settings) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings_appearance_preview'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // 预览内容
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: settings.isDarkMode
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings_appearance_preview_title'.tr(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'settings_appearance_preview_text'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('settings_appearance_preview_button'.tr()),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          'settings_appearance_preview_button_secondary'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              settings.isDarkMode
                  ? 'settings_appearance_preview_dark'.tr()
                  : 'settings_appearance_preview_light'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (settings.useDynamicColor) ...[
              const SizedBox(height: 4),
              Text(
                'settings_appearance_preview_dynamic'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
