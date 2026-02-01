// 外观设置页面
//
// 该文件包含AppearancePage组件，用于管理应用程序的外观设置，
// 包括深色模式和动态色彩功能。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'appearance_page.g.dart';

/// 外观设置状态
class AppearanceSettings {
  /// 是否启用深色模式
  final bool isDarkMode;

  /// 是否启用动态色彩
  final bool useDynamicColor;

  /// 是否使用自定义颜色
  final bool useCustomColor;

  /// 自定义主色调
  final Color? primaryColor;

  /// 创建外观设置实例
  const AppearanceSettings({
    required this.isDarkMode,
    required this.useDynamicColor,
    this.useCustomColor = false,
    this.primaryColor,
  });

  /// 复制并更新外观设置
  AppearanceSettings copyWith({
    bool? isDarkMode,
    bool? useDynamicColor,
    bool? useCustomColor,
    Color? primaryColor,
  }) {
    return AppearanceSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useCustomColor: useCustomColor ?? this.useCustomColor,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

/// 外观设置状态管理器
@Riverpod(keepAlive: true)
class AppearanceSettingsNotifier extends _$AppearanceSettingsNotifier {
  /// 初始化外观设置状态
  @override
  Future<AppearanceSettings> build() async {
    // 初始化时尝试从持久化存储加载设置
    final settings = await _loadFromStorage();
    return settings;
  }

  /// 从持久化存储加载设置
  Future<AppearanceSettings> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载设置
      final isDarkMode = prefs.getBool('appearance_dark_mode') ?? false;
      final useDynamicColor = prefs.getBool('appearance_dynamic_color') ?? true;
      final useCustomColor = prefs.getBool('appearance_custom_color') ?? false;
      final primaryColorValue = prefs.getInt('appearance_primary_color');
      final primaryColor = primaryColorValue != null
          ? Color(primaryColorValue)
          : null;

      return AppearanceSettings(
        isDarkMode: isDarkMode,
        useDynamicColor: useDynamicColor,
        useCustomColor: useCustomColor,
        primaryColor: primaryColor,
      );
    } catch (e) {
      // 加载失败时返回默认设置
      return const AppearanceSettings(
        isDarkMode: false,
        useDynamicColor: true,
        useCustomColor: false,
        primaryColor: null,
      );
    }
  }

  /// 保存设置到持久化存储
  Future<void> _saveToStorage(AppearanceSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存设置
      await prefs.setBool('appearance_dark_mode', settings.isDarkMode);
      await prefs.setBool('appearance_dynamic_color', settings.useDynamicColor);
      await prefs.setBool('appearance_custom_color', settings.useCustomColor);
      if (settings.primaryColor != null) {
        await prefs.setInt(
          'appearance_primary_color',
          settings.primaryColor!.toARGB32(),
        );
      } else {
        await prefs.remove('appearance_primary_color');
      }
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 切换深色模式
  Future<void> toggleDarkMode() async {
    final newState = state.value!.copyWith(
      isDarkMode: !state.value!.isDarkMode,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 切换动态色彩
  Future<void> toggleDynamicColor() async {
    final newState = state.value!.copyWith(
      useDynamicColor: !state.value!.useDynamicColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 切换自定义颜色
  Future<void> toggleCustomColor() async {
    final newState = state.value!.copyWith(
      useCustomColor: !state.value!.useCustomColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新自定义主色调
  Future<void> updatePrimaryColor(Color color) async {
    final newState = state.value!.copyWith(
      primaryColor: color,
      useCustomColor: true,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 重置为默认颜色
  Future<void> resetToDefaultColor() async {
    final newState = state.value!.copyWith(
      useCustomColor: false,
      primaryColor: null,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
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
    final appearanceSettingsAsync = ref.watch(appearanceSettingsProvider);
    final appearanceNotifier = ref.read(appearanceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings_appearance_title'.tr())),
      body: appearanceSettingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('settings_appearance_error_loading'.tr())),
        data: (appearanceSettings) {
          return ListView(
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

              // 自定义颜色设置
              _buildSwitchTile(
                context,
                Icons.palette_outlined,
                'settings_appearance_custom_color'.tr(),
                'settings_appearance_custom_color_description'.tr(),
                appearanceSettings.useCustomColor,
                (value) => appearanceNotifier.toggleCustomColor(),
              ),

              // 颜色选择器
              if (appearanceSettings.useCustomColor) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'settings_appearance_primary_color'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    appearanceSettings.primaryColor ??
                                    Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () => _showColorPicker(
                                  context,
                                  appearanceNotifier,
                                ),
                                child: const Center(
                                  child: Icon(Icons.color_lens),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () =>
                                appearanceNotifier.resetToDefaultColor(),
                            child: Text('settings_appearance_reset_color'.tr()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              _buildSectionHeader(
                context,
                'settings_appearance_section_preview'.tr(),
              ),

              // 外观预览卡片
              _buildPreviewCard(context, appearanceSettings),
            ],
          );
        },
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

  /// 显示颜色选择器
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [notifier] - 外观设置状态管理器
  Future<void> _showColorPicker(
    BuildContext context,
    AppearanceSettingsNotifier notifier,
  ) async {
    final appearanceSettings = ref.read(appearanceSettingsProvider);
    final currentColor =
        appearanceSettings.value?.primaryColor ??
        Theme.of(context).colorScheme.primary;

    // 这里使用简单的颜色选择器，实际项目中可以使用更复杂的颜色选择库
    final List<Color> presetColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      const Color(0xFF39C5BB), // 默认的mikuColor
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_appearance_select_color'.tr()),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presetColors.map((color) {
            return GestureDetector(
              onTap: () {
                notifier.updatePrimaryColor(color);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: currentColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('settings_appearance_cancel'.tr()),
          ),
        ],
      ),
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
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
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
            if (settings.useCustomColor) ...[
              const SizedBox(height: 4),
              Text(
                'settings_appearance_preview_custom'.tr(),
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
