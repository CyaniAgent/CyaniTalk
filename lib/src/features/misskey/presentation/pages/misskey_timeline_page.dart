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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                            child: Text('U$index'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User $index',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '@user$index@example.com',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '2h',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '[${_selectedTimeline.first}] This is a sample note content for item $index. Misskey notes can be quite long or short, and may contain MFM.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply_outlined),
                            onPressed: () {},
                            tooltip: 'Reply',
                          ),
                          IconButton(
                            icon: const Icon(Icons.repeat),
                            onPressed: () {},
                            tooltip: 'Renote',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_reaction_outlined),
                            onPressed: () {},
                            tooltip: 'React',
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {},
                            tooltip: 'More',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
