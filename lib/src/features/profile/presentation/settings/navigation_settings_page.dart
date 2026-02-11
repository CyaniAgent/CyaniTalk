// 导航设置页面
//
// 该文件包含NavigationSettingsPage组件，用于管理应用程序的导航设置，
// 包括底栏（侧栏）选项的显示/隐藏功能。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/navigation/navigation.dart';

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
