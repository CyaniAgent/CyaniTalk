import 'package:flutter/material.dart';

class MisskeyTimelinePage extends StatefulWidget {
  const MisskeyTimelinePage({super.key});

  @override
  State<MisskeyTimelinePage> createState() => _MisskeyTimelinePageState();
}

class _MisskeyTimelinePageState extends State<MisskeyTimelinePage> {
  Set<String> _selectedTimeline = {'Global'};

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
