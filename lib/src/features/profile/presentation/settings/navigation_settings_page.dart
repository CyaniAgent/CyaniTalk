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

/// 导航项配置类
class NavigationItem {
  /// 导航项唯一标识
  final String id;

  /// 导航项标题
  final String title;

  /// 导航项图标
  final IconData icon;

  /// 是否启用
  final bool isEnabled;

  /// 是否可移除
  final bool isRemovable;

  /// 创建导航项实例
  const NavigationItem({
    required this.id,
    required this.title,
    required this.icon,
    this.isEnabled = true,
    this.isRemovable = true,
  });

  /// 复制并更新导航项
  NavigationItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    bool? isEnabled,
    bool? isRemovable,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      isRemovable: isRemovable ?? this.isRemovable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          icon == other.icon &&
          isEnabled == other.isEnabled &&
          isRemovable == other.isRemovable;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      icon.hashCode ^
      isEnabled.hashCode ^
      isRemovable.hashCode;

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isEnabled': isEnabled,
      'isRemovable': isRemovable,
    };
  }

  /// 从JSON格式创建
  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _getIconFromId(json['id'] as String),
      isEnabled: json['isEnabled'] as bool? ?? true,
      isRemovable: json['isRemovable'] as bool? ?? true,
    );
  }

  /// 根据ID获取图标
  static IconData _getIconFromId(String id) {
    switch (id) {
      case 'misskey':
        return Icons.public_outlined;
      case 'flarum':
        return Icons.forum_outlined;
      case 'drive':
        return Icons.cloud_queue_outlined;
      case 'messages':
        return Icons.chat_bubble_outline;
      case 'me':
        return Icons.person_outline;
      default:
        return Icons.star_outline;
    }
  }
}

/// 导航设置状态
class NavigationSettings {
  /// 导航项列表
  final List<NavigationItem> items;

  /// 创建导航设置实例
  const NavigationSettings({this.items = const []});

  /// 获取默认导航设置
  factory NavigationSettings.defaultSettings([BuildContext? context]) {
    return NavigationSettings(
      items: [
        NavigationItem(
          id: 'misskey',
          title: 'nav_misskey'.tr(),
          icon: Icons.public_outlined,
          isEnabled: true,
          isRemovable: true,
        ),
        NavigationItem(
          id: 'flarum',
          title: 'nav_flarum'.tr(),
          icon: Icons.forum_outlined,
          isEnabled: true,
          isRemovable: true,
        ),
        NavigationItem(
          id: 'drive',
          title: 'nav_drive'.tr(),
          icon: Icons.cloud_queue_outlined,
          isEnabled: true,
          isRemovable: true,
        ),
        NavigationItem(
          id: 'messages',
          title: 'nav_messages'.tr(),
          icon: Icons.chat_bubble_outline,
          isEnabled: true,
          isRemovable: true,
        ),
        NavigationItem(
          id: 'me',
          title: 'nav_me'.tr(),
          icon: Icons.person_outline,
          isEnabled: true,
          isRemovable: false, // 个人页面不可移除
        ),
      ],
    );
  }

  /// 复制并更新导航设置
  NavigationSettings copyWith({List<NavigationItem>? items}) {
    return NavigationSettings(items: items ?? this.items);
  }

  /// 获取启用的导航项数量
  int getEnabledCount() {
    return items.where((item) => item.isEnabled).length;
  }

  /// 获取可移除的导航项数量
  int getRemovableCount() {
    return items.where((item) => item.isRemovable).length;
  }

  /// 根据ID查找导航项
  NavigationItem? findItemById(String id) {
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => NavigationItem(id: '', title: '', icon: Icons.star_outline),
    );
  }

  /// 更新指定ID的导航项启用状态
  NavigationSettings updateItemEnabled(String id, bool isEnabled) {
    final updatedItems = items.map((item) {
      if (item.id == id) {
        return item.copyWith(isEnabled: isEnabled);
      }
      return item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  /// 更新导航项排序
  NavigationSettings updateItemOrder(List<NavigationItem> newOrder) {
    return copyWith(items: newOrder);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationSettings &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items);

  @override
  int get hashCode => items.hashCode;

  /// 列表相等性检查
  bool _listEquals<T>(List<T>? a, List<T>? b) {
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

      // 加载导航项配置
      final navigationItemsString = prefs.getString('navigation_items');
      final navigationOrderString = prefs.getString('navigation_order');

      NavigationSettings settings;

      if (navigationItemsString != null && navigationOrderString != null) {
        try {
          // 解析导航项配置
          final List<dynamic> itemsJson = navigationItemsString.split(';');
          final List<NavigationItem> items = [];

          for (final itemJson in itemsJson) {
            if (itemJson.isNotEmpty) {
              try {
                final Map<String, dynamic> itemMap = _parseJsonString(itemJson);
                final item = NavigationItem(
                  id: itemMap['id'] as String,
                  title: itemMap['title'] as String,
                  icon: NavigationItem._getIconFromId(itemMap['id'] as String),
                  isEnabled: itemMap['isEnabled'] as bool,
                  isRemovable: itemMap['isRemovable'] as bool,
                );
                items.add(item);
              } catch (e) {
                // 解析失败，跳过该项
              }
            }
          }

          // 解析排序顺序
          final List<String> orderList = navigationOrderString.split(',');
          final List<NavigationItem> orderedItems = [];

          // 按照存储的顺序排列导航项
          for (final id in orderList) {
            final item = items.firstWhere(
              (item) => item.id == id,
              orElse: () =>
                  NavigationItem(id: '', title: '', icon: Icons.star_outline),
            );
            if (item.id.isNotEmpty) {
              orderedItems.add(item);
            }
          }

          // 添加未在排序中的导航项
          for (final item in items) {
            if (!orderedItems.any((orderedItem) => orderedItem.id == item.id)) {
              orderedItems.add(item);
            }
          }

          settings = NavigationSettings(items: orderedItems);
        } catch (e) {
          // 解析失败，使用默认设置
          settings = NavigationSettings.defaultSettings();
        }
      } else {
        // 没有存储的设置，使用默认设置
        settings = NavigationSettings.defaultSettings();
      }

      // 检查并确保至少有两个导航项启用
      if (settings.getEnabledCount() < 2) {
        // 按照顺序尝试启用导航项
        final List<NavigationItem> updatedItems = List.from(settings.items);
        int enabledCount = settings.getEnabledCount();

        for (int i = 0; i < updatedItems.length && enabledCount < 2; i++) {
          final item = updatedItems[i];
          if (!item.isEnabled && item.isRemovable) {
            updatedItems[i] = item.copyWith(isEnabled: true);
            enabledCount++;
          }
        }

        settings = NavigationSettings(items: updatedItems);
        await _saveToStorage(settings);
      }

      return settings;
    } catch (e) {
      // 加载失败时返回默认设置
      return NavigationSettings.defaultSettings();
    }
  }

  /// 保存设置到持久化存储
  Future<void> _saveToStorage(NavigationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存导航项配置
      final itemsJson = settings.items
          .map((item) => _jsonToString(item.toJson()))
          .join(';');
      await prefs.setString('navigation_items', itemsJson);

      // 保存排序顺序
      final orderList = settings.items.map((item) => item.id).join(',');
      await prefs.setString('navigation_order', orderList);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  /// 解析JSON字符串
  Map<String, dynamic> _parseJsonString(String jsonString) {
    // 简单的JSON字符串解析
    final Map<String, dynamic> result = {};
    final cleanString = jsonString.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleanString.split(',');

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim().replaceAll('"', '');
        final value = parts[1].trim();

        if (value == 'true') {
          result[key] = true;
        } else if (value == 'false') {
          result[key] = false;
        } else if (value.startsWith('"') && value.endsWith('"')) {
          result[key] = value.replaceAll('"', '');
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  /// 将JSON对象转换为字符串
  String _jsonToString(Map<String, dynamic> json) {
    final pairs = json.entries
        .map((entry) => '"${entry.key}":${_valueToString(entry.value)}')
        .join(',');
    return '{$pairs}';
  }

  /// 将值转换为字符串
  String _valueToString(dynamic value) {
    if (value is String) {
      return '"$value"';
    }
    return value.toString();
  }

  /// 更新导航项启用状态
  Future<void> updateItemEnabled(
    String itemId,
    bool isEnabled,
    BuildContext context,
  ) async {
    // 查找要更新的导航项
    final item = state.value!.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => NavigationItem(id: '', title: '', icon: Icons.star_outline),
    );

    if (item.id.isEmpty) {
      return;
    }

    // 如果是不可移除的导航项（如个人页面），强制保持启用状态
    if (!item.isRemovable) {
      final newState = state.value!.updateItemEnabled(itemId, true);
      state = AsyncData(newState);
      await _saveToStorage(newState);
      return;
    }

    // 检查如果禁用该项后，是否还有至少两个导航项启用
    if (!isEnabled) {
      final tempState = state.value!.updateItemEnabled(itemId, false);
      if (tempState.getEnabledCount() < 2) {
        // 至少需要两个导航项启用，显示提示并取消禁用操作
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('至少需要启用两个导航项'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // 更新导航项启用状态
    final newState = state.value!.updateItemEnabled(itemId, isEnabled);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 更新导航项排序
  Future<void> updateItemOrder(List<NavigationItem> newOrder) async {
    // 确保所有原始导航项都在新排序中
    final originalItems = state.value!.items;
    final updatedOrder = List<NavigationItem>.from(newOrder);

    // 添加未在新排序中的导航项
    for (final item in originalItems) {
      if (!updatedOrder.any((updatedItem) => updatedItem.id == item.id)) {
        updatedOrder.add(item);
      }
    }

    final newState = state.value!.updateItemOrder(updatedOrder);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  /// 重置配置
  Future<void> resetSettings() async {
    final newState = NavigationSettings.defaultSettings();
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
                  children: navigationSettings.items.map((item) {
                    ValueChanged<bool>? onChanged;
                    if (item.isRemovable) {
                      onChanged = (value) => navigationNotifier
                          .updateItemEnabled(item.id, value, context);
                    }

                    return Container(
                      key: ValueKey(item.id),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(item.icon),
                            title: Text(item.title),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: item.isEnabled,
                                  onChanged: onChanged,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            enabled: onChanged != null,
                          ),
                          if (item != navigationSettings.items.last)
                            Divider(indent: 72, height: 1, thickness: 0.5),
                        ],
                      ),
                    );
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    final newOrder = List<NavigationItem>.from(
                      navigationSettings.items,
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
