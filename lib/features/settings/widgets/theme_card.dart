part of '../settings.dart';

class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key});

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => const ThemeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          String themeText;
          switch (state.themeType) {
            case ThemeType.light:
              themeText = 'Light';
              break;
            case ThemeType.dark:
              themeText = 'Dark';
              break;
            case ThemeType.system:
              themeText = 'System';
              break;
          }

          return Card(
            child: ListTile(
              leading: const Icon(Icons.palette, color: AppTheme.mainColor),
              title: const Text('Theme'),
              subtitle: Text(themeText),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeBottomSheet(context),
            ),
          );
        },
      );
}
