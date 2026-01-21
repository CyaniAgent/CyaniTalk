import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/search/global_search_delegate.dart';
import 'widgets/misskey_drawer.dart';
import 'pages/misskey_timeline_page.dart';
import 'pages/misskey_notes_page.dart';
import 'pages/misskey_antennas_page.dart';
import 'pages/misskey_channels_page.dart';
import 'pages/misskey_explore_page.dart';
import 'pages/misskey_discover_page.dart';
import 'pages/misskey_follow_requests_page.dart';
import 'pages/misskey_announcements_page.dart';

class MisskeyPage extends StatefulWidget {
  const MisskeyPage({super.key});

  @override
  State<MisskeyPage> createState() => _MisskeyPageState();
}

class _MisskeyPageState extends State<MisskeyPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MisskeyTimelinePage(key: ValueKey('timeline')),
    MisskeyNotesPage(key: ValueKey('notes')),
    MisskeyAntennasPage(key: ValueKey('antennas')),
    MisskeyChannelsPage(key: ValueKey('channels')),
    MisskeyExplorePage(key: ValueKey('explore')),
    MisskeyDiscoverPage(key: ValueKey('discover')),
    MisskeyFollowRequestsPage(key: ValueKey('follow_requests')),
    MisskeyAnnouncementsPage(key: ValueKey('announcements')),
  ];

  final List<String> _titles = const [
    'Timeline',
    'Notes',
    'Antennas',
    'Channels',
    'Explore',
    'Discover',
    'Follow Requests',
    'Announcements',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MisskeyDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(_titles[_selectedIndex]),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.widgets_outlined),
                  tooltip: 'Widgets',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Misskey Widgets opened')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Global Search',
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: GlobalSearchDelegate(),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: AnimatedSwitcher(
          duration: 400.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }
}
