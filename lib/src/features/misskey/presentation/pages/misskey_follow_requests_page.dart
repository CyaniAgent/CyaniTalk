import 'package:flutter/material.dart';

class MisskeyFollowRequestsPage extends StatelessWidget {
  const MisskeyFollowRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text('Requesting User ${index + 1}'),
          subtitle: const Text('Wants to follow you'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {},
                tooltip: 'Accept',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {},
                tooltip: 'Reject',
              ),
            ],
          ),
        );
      },
    );
  }
}