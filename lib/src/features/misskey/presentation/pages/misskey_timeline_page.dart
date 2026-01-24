// Misskey时间线页面
//
// 该文件包含MisskeyTimelinePage组件，用于显示Misskey的不同类型时间线。
import 'package:flutter/material.dart';


/// Misskey时间线页面组件
///
/// 显示Misskey平台上的时间线内容，支持切换不同类型的时间线（首页、本地、社交、全球）。
class MisskeyTimelinePage extends StatefulWidget {
  /// 创建一个新的MisskeyTimelinePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyTimelinePage({super.key});

  /// 创建MisskeyTimelinePage的状态管理对象
  @override
  State<MisskeyTimelinePage> createState() => _MisskeyTimelinePageState();
}

/// MisskeyTimelinePage的状态管理类
class _MisskeyTimelinePageState extends State<MisskeyTimelinePage> {
  /// 当前选中的时间线类型集合
  Set<String> _selectedTimeline = {'Global'};

  /// 构建时间线页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含分段按钮和时间线列表的Column组件
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'Home',
                  label: Text('Home'),
                  icon: Icon(Icons.home_outlined),
                ),
                ButtonSegment<String>(
                  value: 'Local',
                  label: Text('Local'),
                  icon: Icon(Icons.location_city),
                ),
                ButtonSegment<String>(
                  value: 'Social',
                  label: Text('Social'),
                  icon: Icon(Icons.group_outlined),
                ),
                ButtonSegment<String>(
                  value: 'Global',
                  label: Text('Global'),
                  icon: Icon(Icons.public),
                ),
              ],
              selected: _selectedTimeline,
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedTimeline = newSelection;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_motion_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No notes found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${_selectedTimeline.first} timeline is empty.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
