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
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final Color primary =
              isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
          final Color textPrimary =
              isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
          final Color textSecondary =
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

          final String themeText;
          switch (state.themeType) {
            case ThemeType.light:
              themeText = 'settings.light'.tr();
            case ThemeType.dark:
              themeText = 'settings.dark'.tr();
            case ThemeType.system:
              themeText = 'settings.system'.tr();
          }

          return _SettingsRow(
            icon: Icons.palette_outlined,
            iconColor: primary,
            title: 'settings.theme'.tr(),
            subtitle: themeText,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => _showThemeBottomSheet(context),
          );
        },
      );
}
