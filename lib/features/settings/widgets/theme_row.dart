part of '../settings.dart';

class ThemeRow extends StatelessWidget {
  const ThemeRow({super.key});

  void _showThemeBottomSheet(BuildContext context) {
    AppBottomSheet.show<void>(
      context,
      child: const ThemeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          final String themeText = switch (state.themeType) {
            ThemeType.light => 'settings.light'.tr(),
            ThemeType.dark => 'settings.dark'.tr(),
            ThemeType.system => 'settings.system'.tr(),
          };

          return _SettingsRow(
            icon: Icons.palette_outlined,
            iconBackground: AppColors.of(context).bookmarksCard,
            title: 'settings.theme'.tr(),
            subtitle: themeText,
            onTap: () => _showThemeBottomSheet(context),
          );
        },
      );
}
