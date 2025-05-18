part of '../settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const DilDuelAppBar(
        title: 'Settings',
        showBackButton: true,
        showProfileButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.padding16),
        children: <Widget>[
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.padding16),
              child: Column(
                children: <Widget>[
                  const CircleAvatar(
                    radius: Dimensions.itemHeight40,
                    backgroundColor: AppTheme.mainColor,
                    child: Icon(
                      Icons.person,
                      size: Dimensions.itemHeight32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: Dimensions.itemHeight16),
                  Text(
                    'Elvin Mammadov',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    'elvin@example.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: Dimensions.itemHeight16),
                  AppElevatedButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      // TODO: Implement edit profile
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.itemHeight16),

          // Language Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: AppTheme.mainColor),
              title: const Text('Language'),
              subtitle: const Text('Azerbaijani - German'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement language selection
              },
            ),
          ),
          const SizedBox(height: Dimensions.itemHeight8),

          // Theme Card
          const ThemeCard(),
          const SizedBox(height: Dimensions.itemHeight8),

          // FAQ Card
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppTheme.mainColor,
                  ),
                  title: const Text('Frequently Asked Questions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement FAQ screen navigation
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('How to use the dictionary?'),
                  trailing: const Icon(Icons.expand_more),
                  onTap: () {
                    // TODO: Implement FAQ item expansion
                  },
                ),
                ListTile(
                  title: const Text('How does the quiz work?'),
                  trailing: const Icon(Icons.expand_more),
                  onTap: () {
                    // TODO: Implement FAQ item expansion
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.itemHeight8),

          // About Card
          Card(
            child: FutureBuilder<PackageInfo>(
              future: _packageInfo,
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                final String version =
                    snapshot.hasData ? snapshot.data!.version : '...';
                return ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: AppTheme.mainColor),
                  title: const Text('About'),
                  subtitle: Text('Version $version'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement about screen navigation
                  },
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.itemHeight24),

          // Logout Button
          AppElevatedButton(
            text: 'Logout',
            backgroundColor: AppTheme.errorColor,
            onPressed: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}
