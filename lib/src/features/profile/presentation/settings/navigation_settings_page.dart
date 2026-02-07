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

/// 导航项类型枚举
enum NavigationItemType { misskey, flarum, drive, messages, me }

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

  /// 导航项排序顺序
  final List<NavigationItemType> itemOrder;

  /// 创建导航设置实例
  const NavigationSettings({
    this.showMisskey = true,
    this.showFlarum = true,
    this.showDrive = true,
    this.showMessages = true,
    this.showMe = true,
    this.itemOrder = const [
      NavigationItemType.misskey,
      NavigationItemType.flarum,
      NavigationItemType.drive,
      NavigationItemType.messages,
      NavigationItemType.me,
    ],
  });

  /// 复制并更新导航设置
  NavigationSettings copyWith({
    bool? showMisskey,
    bool? showFlarum,
    bool? showDrive,
    bool? showMessages,
    bool? showMe,
    List<NavigationItemType>? itemOrder,
  }) {
    return NavigationSettings(
      showMisskey: showMisskey ?? this.showMisskey,
      showFlarum: showFlarum ?? this.showFlarum,
      showDrive: showDrive ?? this.showDrive,
      showMessages: showMessages ?? this.showMessages,
      showMe: true, // 强制保持个人页面为启用状态
      itemOrder: itemOrder ?? this.itemOrder,
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
          showMe == other.showMe &&
          ListEquality<NavigationItemType>().equals(itemOrder, other.itemOrder);

  @override
  int get hashCode =>
      showMisskey.hashCode ^
      showFlarum.hashCode ^
      showDrive.hashCode ^
      showMessages.hashCode ^
      showMe.hashCode ^
      itemOrder.hashCode;
}

/// 列表相等性比较器
class ListEquality<T> {
  bool equals(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
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

      // 加载排序顺序
      final itemOrderString = prefs.getString('navigation_item_order');
      List<NavigationItemType> itemOrder;
      if (itemOrderString != null) {
        try {
          final List<String> itemOrderList = itemOrderString.split(',');
          itemOrder = itemOrderList
              .map(
                (item) => NavigationItemType.values.firstWhere(
                  (e) => e.toString().split('.').last == item,
                  orElse: () => NavigationItemType.misskey,
                ),
              )
              .toList();
          // 确保排序列表包含所有导航项类型
          for (final type in NavigationItemType.values) {
            if (!itemOrder.contains(type)) {
              itemOrder.add(type);
            }
          }
        } catch (e) {
          // 解析失败时使用默认排序
          itemOrder = const [
            NavigationItemType.misskey,
            NavigationItemType.flarum,
            NavigationItemType.drive,
            NavigationItemType.messages,
            NavigationItemType.me,
          ];
        }
      } else {
        // 使用默认排序
        itemOrder = const [
          NavigationItemType.misskey,
          NavigationItemType.flarum,
          NavigationItemType.drive,
          NavigationItemType.messages,
          NavigationItemType.me,
        ];
      }

      return NavigationSettings(
        showMisskey: showMisskey,
        showFlarum: showFlarum,
        showDrive: showDrive,
        showMessages: showMessages,
        showMe: showMe,
        itemOrder: itemOrder,
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

      // 保存排序顺序
      final itemOrderString = settings.itemOrder
          .map((item) => item.toString().split('.').last)
          .join(',');
      await prefs.setString('navigation_item_order', itemOrderString);
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

  /// 更新排序顺序
  Future<void> updateItemOrder(List<NavigationItemType> newOrder) async {
    // 确保个人页面始终在排序列表中
    final updatedOrder = List<NavigationItemType>.from(newOrder);
    if (!updatedOrder.contains(NavigationItemType.me)) {
      updatedOrder.add(NavigationItemType.me);
    }
    final newState = state.value!.copyWith(itemOrder: updatedOrder);
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

              // 导航项排序
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '排序顺序',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '长按并拖动可以调整导航项的显示顺序',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // 可拖动排序的导航项列表
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: navigationSettings.itemOrder.map((itemType) {
                    IconData icon;
                    String title;
                    bool isEnabled;
                    ValueChanged<bool>? onChanged;

                    switch (itemType) {
                      case NavigationItemType.misskey:
                        icon = Icons.public_outlined;
                        title = 'nav_misskey'.tr();
                        isEnabled = navigationSettings.showMisskey;
                        onChanged = (value) =>
                            navigationNotifier.updateShowMisskey(value);
                        break;
                      case NavigationItemType.flarum:
                        icon = Icons.forum_outlined;
                        title = 'nav_flarum'.tr();
                        isEnabled = navigationSettings.showFlarum;
                        onChanged = (value) =>
                            navigationNotifier.updateShowFlarum(value);
                        break;
                      case NavigationItemType.drive:
                        icon = Icons.cloud_queue_outlined;
                        title = 'nav_drive'.tr();
                        isEnabled = navigationSettings.showDrive;
                        onChanged = (value) =>
                            navigationNotifier.updateShowDrive(value);
                        break;
                      case NavigationItemType.messages:
                        icon = Icons.chat_bubble_outline;
                        title = 'nav_messages'.tr();
                        isEnabled = navigationSettings.showMessages;
                        onChanged = (value) =>
                            navigationNotifier.updateShowMessages(value);
                        break;
                      case NavigationItemType.me:
                        icon = Icons.person_outline;
                        title = 'nav_me'.tr();
                        isEnabled = true; // 强制启用个人页面
                        onChanged = null; // 禁用开关，不允许用户修改
                        break;
                    }

                    return Container(
                      key: ValueKey(itemType),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(icon),
                            title: Text(title),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(value: isEnabled, onChanged: onChanged),
                                const SizedBox(width: 8),
                              ],
                            ),
                            enabled: onChanged != null,
                          ),
                          if (itemType != navigationSettings.itemOrder.last)
                            Divider(indent: 72, height: 1, thickness: 0.5),
                        ],
                      ),
                    );
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    final newOrder = List<NavigationItemType>.from(
                      navigationSettings.itemOrder,
                    );
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = newOrder.removeAt(oldIndex);
                    newOrder.insert(newIndex, item);
                    navigationNotifier.updateItemOrder(newOrder);
                  },
                ),
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
}
