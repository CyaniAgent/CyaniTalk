// Misskey发现页面
//
// 该文件包含MisskeyExplorePage组件，用于显示Misskey的发现内容，包括热门话题、标签和用户。
import 'package:flutter/material.dart';

/// Misskey发现页面组件
///
/// 显示Misskey平台上的热门内容，包括热门话题、标签和用户列表。
class MisskeyExplorePage extends StatelessWidget {
  /// 创建一个新的MisskeyExplorePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyExplorePage({super.key});

  /// 构建发现页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含TabBar和TabBarView的Column组件
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Trending'),
              Tab(text: 'Hashtags'),
              Tab(text: 'Users'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTrendingList(context),
                _buildHashtagList(context),
                _buildUserList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建热门话题列表
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示热门话题的ListView.builder组件
  Widget _buildTrendingList(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(
            '#${index + 1}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text('Trending Topic ${index + 1}'),
          subtitle: Text('${(10 - index) * 100} posts'),
          trailing: const Icon(Icons.trending_up),
        );
      },
    );
  }

  /// 构建标签列表
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示热门标签的ListView.builder组件
  Widget _buildHashtagList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: Text('#Hashtag${index + 1}'),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  /// 构建热门用户列表
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示热门用户的ListView.builder组件
  Widget _buildUserList(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('Popular User ${index + 1}'),
          subtitle: const Text('@popular@example.com'),
          trailing: FilledButton.tonal(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        );
      },
    );
  }
}