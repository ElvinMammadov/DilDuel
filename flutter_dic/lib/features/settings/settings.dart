import 'package:flutter/material.dart';
import 'package:flutter_dic/features/widgets/app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;

    return Scaffold(
      appBar: const DilDuelAppBar(
        title: 'Settings',
        showBackButton: true,
        showProfileButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Profile Header
          Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Elvin Mammadov', style: theme.textTheme.titleMedium),
                  Text('elvin@example.com',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurface.withOpacity(0.6),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings items
          _buildTile(
              context, Icons.language, 'Language', 'Azerbaijani - German',
              onTap: () {}),
          _buildTile(context, Icons.notifications, 'Notifications', 'Enabled',
              onTap: () {}),
          _buildTile(context, Icons.palette, 'Theme', 'System Default',
              onTap: () {}),
          _buildTile(context, Icons.lock, 'Privacy & Security', '',
              onTap: () {}),
          _buildTile(context, Icons.info, 'About', '', onTap: () {}),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    final ColorScheme color = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color.primary),
          title: Text(title),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
