import 'package:flutter/material.dart';

class MisskeyAntennasPage extends StatelessWidget {
  const MisskeyAntennasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.satellite_alt),
            title: Text('Antenna ${index + 1}'),
            subtitle: Text('Keywords: flutter, dart, misskey (Match all)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}