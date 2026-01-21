import 'package:flutter/material.dart';

class MisskeyDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MisskeyDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.pop(context); // Close the drawer
      },
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'Misskey Menu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.timeline_outlined),
          selectedIcon: Icon(Icons.timeline),
          label: Text('Timeline'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.note_outlined),
          selectedIcon: Icon(Icons.note),
          label: Text('Notes'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.satellite_alt_outlined),
          selectedIcon: Icon(Icons.satellite_alt),
          label: Text('Antennas'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.hub_outlined),
          selectedIcon: Icon(Icons.hub),
          label: Text('Channels'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text('Explore'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.travel_explore_outlined),
          selectedIcon: Icon(Icons.travel_explore),
          label: Text('Discover'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person_add_outlined),
          selectedIcon: Icon(Icons.person_add),
          label: Text('Follow Requests'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign),
          label: Text('Announcements'),
        ),
      ],
    );
  }
}
