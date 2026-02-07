// 外观设置页面
//
// 该文件包含AppearancePage组件，用于管理应用程序的外观设置，
// 包括深色模式和动态色彩功能。
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'appearance_page.g.dart';

/// 外观设置状态
class AppearanceSettings {
  /// 显示模式
  final ThemeMode displayMode;

  /// 是否启用动态色彩
  final bool useDynamicColor;

  /// 是否使用自定义颜色
  final bool useCustomColor;

  /// 自定义主色调
  final Color? primaryColor;

  /// 创建外观设置实例
  const AppearanceSettings({
    required this.displayMode,
    required this.useDynamicColor,
    this.useCustomColor = false,
    this.primaryColor,
  });

  /// 方便获取实际的深色模式状态（用于主题构建）
  bool get isDarkMode => displayMode == ThemeMode.dark;

  /// 复制并更新外观设置
  AppearanceSettings copyWith({
    ThemeMode? displayMode,
    bool? useDynamicColor,
    bool? useCustomColor,
    Color? primaryColor,
  }) {
    return AppearanceSettings(
      displayMode: displayMode ?? this.displayMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useCustomColor: useCustomColor ?? this.useCustomColor,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppearanceSettings &&
          runtimeType == other.runtimeType &&
          displayMode == other.displayMode &&
          useDynamicColor == other.useDynamicColor &&
          useCustomColor == other.useCustomColor &&
          primaryColor?.toARGB32() == other.primaryColor?.toARGB32();

  @override
  int get hashCode =>
      displayMode.hashCode ^
      useDynamicColor.hashCode ^
      useCustomColor.hashCode ^
      (primaryColor?.toARGB32().hashCode ?? 0);
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
      final themeModeIndex = prefs.getInt('appearance_display_mode') ?? 0; // Default to system
      final displayMode = ThemeMode.values[themeModeIndex];
      
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;
      // If not android, dynamic color should be false
      final useDynamicColor = isAndroid ? (prefs.getBool('appearance_dynamic_color') ?? true) : false;
      final useCustomColor = prefs.getBool('appearance_custom_color') ?? (!isAndroid); // Default to custom on non-android
      
      final primaryColorValue = prefs.getInt('appearance_primary_color');
      final primaryColor = primaryColorValue != null
          ? Color(primaryColorValue)
          : const Color(0xFF39C5BB);

      return AppearanceSettings(
        displayMode: displayMode,
        useDynamicColor: useDynamicColor,
        useCustomColor: useCustomColor,
        primaryColor: primaryColor,
      );
    } catch (e) {
      // 加载失败时返回默认设置
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;
      return AppearanceSettings(
        displayMode: ThemeMode.system,
        useDynamicColor: isAndroid,
        useCustomColor: !isAndroid,
        primaryColor: const Color(0xFF39C5BB),
      );
    }
  }

  /// 保存设置到持久化存储
  Future<void> _saveToStorage(AppearanceSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存设置
      await prefs.setInt('appearance_display_mode', settings.displayMode.index);
      await prefs.setBool('appearance_dynamic_color', settings.useDynamicColor);
      await prefs.setBool('appearance_custom_color', settings.useCustomColor);
      if (settings.primaryColor != null) {
        await prefs.setInt(
          'appearance_primary_color',
          settings.primaryColor!.toARGB32(),
        );
      }
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 更新显示模式
  Future<void> updateDisplayMode(ThemeMode mode) async {
    final newState = state.value!.copyWith(displayMode: mode);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 切换动态色彩
  Future<void> toggleDynamicColor(bool value) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    
    final newState = state.value!.copyWith(
      useDynamicColor: value,
      // 如果启用动态色彩，禁用自定义颜色
      useCustomColor: value ? false : state.value!.useCustomColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 切换自定义颜色
  Future<void> toggleCustomColor(bool value) async {
    final newState = state.value!.copyWith(
      useCustomColor: value,
      // 如果启用自定义颜色，禁用动态色彩
      useDynamicColor: value ? false : state.value!.useDynamicColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新自定义主色调
  Future<void> updatePrimaryColor(Color color) async {
    final newState = state.value!.copyWith(
      primaryColor: color,
      useCustomColor: true,
      useDynamicColor: false,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 重置配置
  Future<void> resetSettings() async {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final AppearanceSettings newState;
    
    if (isAndroid) {
      newState = const AppearanceSettings(
        displayMode: ThemeMode.system,
        useDynamicColor: true,
        useCustomColor: false,
        primaryColor: Color(0xFF39C5BB),
      );
    } else {
      newState = const AppearanceSettings(
        displayMode: ThemeMode.system,
        useDynamicColor: false,
        useCustomColor: true,
        primaryColor: Color(0xFF39C5BB),
      );
    }
    
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
          final isAndroid = defaultTargetPlatform == TargetPlatform.android;

          return ListView(
            children: [
              _buildSectionHeader(
                context,
                'settings_appearance_section_display'.tr(),
              ),

              // 显示模式设置
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings_appearance_display_mode'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('settings_appearance_system'.tr()),
                          icon: const Icon(Icons.settings_suggest_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('settings_appearance_light'.tr()),
                          icon: const Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('settings_appearance_dark'.tr()),
                          icon: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: {appearanceSettings.displayMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        appearanceNotifier.updateDisplayMode(newSelection.first);
                      },
                    ),
                  ],
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              // 动态色彩设置
              _buildSwitchTile(
                context,
                Icons.color_lens_outlined,
                'settings_appearance_dynamic_color'.tr(),
                'settings_appearance_dynamic_color_description'.tr(),
                appearanceSettings.useDynamicColor,
                isAndroid 
                    ? (value) => appearanceNotifier.toggleDynamicColor(value)
                    : null, // Disable if not Android
              ),
              if (!isAndroid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 4),
                  child: Text(
                    'settings_appearance_dynamic_color_android_only'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

              // 自定义颜色设置
              _buildSwitchTile(
                context,
                Icons.palette_outlined,
                'settings_appearance_custom_color'.tr(),
                'settings_appearance_custom_color_description'.tr(),
                appearanceSettings.useCustomColor,
                (value) => appearanceNotifier.toggleCustomColor(value),
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
                                appearanceNotifier.resetSettings(),
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

              const SizedBox(height: 24),
              // 重置主题配置按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () => _showResetConfirmation(context, appearanceNotifier),
                  icon: const Icon(Icons.restart_alt),
                  label: Text('settings_appearance_reset_config'.tr()),
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

  void _showResetConfirmation(BuildContext context, AppearanceSettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_appearance_reset_config'.tr()),
        content: Text('settings_appearance_reset_confirm'.tr()),
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
                SnackBar(content: Text('settings_appearance_reset_done'.tr())),
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
      leading: Icon(icon, color: onChanged == null ? Theme.of(context).disabledColor : null),
      title: Text(
        title,
        style: TextStyle(color: onChanged == null ? Theme.of(context).disabledColor : null),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: onChanged == null ? Theme.of(context).disabledColor : null),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      enabled: onChanged != null,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'settings_appearance_design_example'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'settings_appearance_design_example_subtitle'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),

            // Mock UI Stage
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Mock App Bar
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: const Text(
                          "01",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.notifications_none, size: 18, color: colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Mock Message Bubble
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        "Producer-san, let's make the best stage! (≧▽≦)",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Mock Post Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, size: 16, color: colorScheme.onSecondaryContainer),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: colorScheme.outline,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage('https://api.dicebear.com/7.x/shapes/png?seed=miku&backgroundColor=39c5bb'),
                              fit: BoxFit.cover,
                              opacity: 0.3,
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.play_circle_outline, color: colorScheme.primary, size: 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mock Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMockButton(colorScheme.primary, Icons.favorite),
                      _buildMockButton(colorScheme.secondary, Icons.share),
                      _buildMockButton(colorScheme.tertiary, Icons.bookmark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // Status Info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(
                  context,
                  settings.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                if (settings.useDynamicColor)
                  _buildStatusChip(context, 'Dynamic', Icons.auto_fix_high),
                if (settings.useCustomColor)
                  _buildStatusChip(context, 'Custom', Icons.palette),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockButton(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
