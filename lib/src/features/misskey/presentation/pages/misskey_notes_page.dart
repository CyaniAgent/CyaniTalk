// Misskey笔记页面
//
// 该文件包含MisskeyNotesPage组件，用于显示用户的笔记列表。
import 'package:flutter/material.dart';

/// Misskey笔记页面组件
///
/// 显示用户创建的笔记列表，包括回复和自己发布的内容。
class MisskeyNotesPage extends StatelessWidget {
  /// 创建一个新的MisskeyNotesPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyNotesPage({super.key});

  /// 构建笔记页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示笔记列表的ListView.builder组件
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Username',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@me@example.com',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${index + 1}h',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This is note #$index from me. It might be a reply or a self-post.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}