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
          final AppColors colors = AppColors.of(context);
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
            iconColor: colors.primary,
            title: 'settings.theme'.tr(),
            subtitle: themeText,
            onTap: () => _showThemeBottomSheet(context),
          );
        },
      );
}
