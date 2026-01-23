import 'package:flutter/material.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(context, Icons.person_outline, 'Account', 'Manage your accounts'),
          
          _buildSectionHeader(context, 'Connections'),
          _buildSettingsTile(context, Icons.api, 'Flarum Endpoint', 'Configure Flarum server URL'),
          _buildSettingsTile(context, Icons.wifi, 'Network & Real-time', 'WebSocket and API settings'),

          _buildSectionHeader(context, 'Interface'),
          _buildSettingsTile(context, Icons.palette_outlined, 'Appearance', 'Theme, colors, and layout'),
          _buildSettingsTile(context, Icons.notifications_outlined, 'Notifications', 'Push and in-app alerts'),
          _buildSettingsTile(context, Icons.volume_up_outlined, 'Sound', 'Volume and sound effects'),

          _buildSectionHeader(context, 'System'),
          _buildSettingsTile(context, Icons.history, 'Logs', 'View application logs'),
          _buildSettingsTile(context, Icons.storage_outlined, 'Storage', 'Cache and data management'),
          
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            Icons.info_outline,
            'About CyaniTalk',
            'Version, licenses, and contributors',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped $title')),
            );
          },
    );
  }
}
