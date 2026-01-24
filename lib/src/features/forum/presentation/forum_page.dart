import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../flarum/presentation/widgets/flarum_drawer.dart';
import '../../flarum/presentation/pages/flarum_discussion_page.dart';
import '../../flarum/presentation/pages/flarum_tags_page.dart';
import '../../flarum/presentation/pages/flarum_notifications_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FlarumDiscussionPage(key: ValueKey('discussion')),
    FlarumTagsPage(key: ValueKey('tags')),
    FlarumNotificationsPage(key: ValueKey('notifications')),
  ];

  final List<String> _titles = const [
    'Discussions',
    'Tags',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FlarumDrawer(
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
