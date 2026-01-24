// Misskey频道页面
//
// 该文件包含MisskeyChannelsPage组件，用于显示Misskey的频道列表。
import 'package:flutter/material.dart';

/// Misskey频道页面组件
///
/// 以网格布局显示Misskey平台上的频道列表，每个频道显示名称、描述和成员数量。
class MisskeyChannelsPage extends StatelessWidget {
  /// 创建一个新的MisskeyChannelsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyChannelsPage({super.key});

  /// 构建频道页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示频道列表的GridView.builder组件
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 80,
                color: Colors.primaries[index % Colors.primaries.length].withValues(alpha: 0.2),
                child: Center(
                  child: Icon(
                    Icons.hub,
                    size: 40,
                    color: Colors.primaries[index % Colors.primaries.length],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Channel ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A community for discussing topic ${index + 1}.',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${(index + 1) * 123} members',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}