import 'package:flutter/material.dart';

class MisskeyExplorePage extends StatelessWidget {
  const MisskeyExplorePage({super.key});

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