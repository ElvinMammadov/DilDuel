part of '../settings.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  void _applyTheme(
    BuildContext context,
    ThemeCubit cubit,
    ThemeType type,
    String themeName,
  ) {
    final OverlayState? overlay = Navigator.of(context).overlay;
    cubit.setTheme(type);
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (overlay != null && overlay.mounted) {
        AppSnackbar.showOnOverlay(
          overlay,
          type: SnackbarType.success,
          title: 'settings.theme_changed'.tr(),
          subtitle: 'settings.theme_changed_to'.tr(args: <String>[themeName]),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          final ThemeCubit cubit = context.read<ThemeCubit>();
          return AppBottomSheet(
            title: 'settings.choose_theme'.tr(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding20,
                Dimensions.padding8,
                Dimensions.padding20,
                Dimensions.padding24,
              ),
              child: Row(
                children: <Widget>[
                  _ThemeOption(
                    label: 'settings.light'.tr(),
                    icon: const _LightThemeIcon(),
                    isSelected: state.themeType == ThemeType.light,
                    onTap: () => _applyTheme(
                      context,
                      cubit,
                      ThemeType.light,
                      'settings.light'.tr(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.itemWidth8),
                  _ThemeOption(
                    label: 'settings.dark'.tr(),
                    icon: const _DarkThemeIcon(),
                    isSelected: state.themeType == ThemeType.dark,
                    onTap: () => _applyTheme(
                      context,
                      cubit,
                      ThemeType.dark,
                      'settings.dark'.tr(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.itemWidth8),
                  _ThemeOption(
                    label: 'settings.system'.tr(),
                    icon: const _SystemThemeIcon(),
                    isSelected: state.themeType == ThemeType.system,
                    onTap: () => _applyTheme(
                      context,
                      cubit,
                      ThemeType.system,
                      'settings.system'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primaryTint
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(Dimensions.borderRadius16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding10,
              vertical: Dimensions.padding14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon,
                const SizedBox(height: Dimensions.itemHeight8),
                Text(
                  label,
                  style: AppTextStyles.bodySmall(
                    isSelected ? colors.primary : colors.textSecondary,
                  ).copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LightThemeIcon extends StatelessWidget {
  const _LightThemeIcon();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F5FB),
          border: Border.all(color: const Color(0xFFE7E4F3)),
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        ),
        child: const SizedBox(
          width: Dimensions.itemWidth44,
          height: Dimensions.itemHeight44,
          child: Icon(
            Icons.wb_sunny_outlined,
            size: Dimensions.itemWidth20,
            color: Color(0xFF4F3DE0),
          ),
        ),
      );
}

class _DarkThemeIcon extends StatelessWidget {
  const _DarkThemeIcon();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B2E),
          border: Border.all(
            color: const Color(0x1AFFFFFF),
          ),
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        ),
        child: const SizedBox(
          width: Dimensions.itemWidth44,
          height: Dimensions.itemHeight44,
          child: Icon(
            Icons.nightlight_outlined,
            size: Dimensions.itemWidth20,
            color: Color(0xFF8C7DFF),
          ),
        ),
      );
}

class _SystemThemeIcon extends StatelessWidget {
  const _SystemThemeIcon();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: <double>[0.5, 0.5],
            colors: <Color>[Color(0xFFF6F5FB), Color(0xFF1E1B2E)],
          ),
          border: Border.all(color: const Color(0xFFE7E4F3)),
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        ),
        child: const SizedBox(
          width: Dimensions.itemWidth44,
          height: Dimensions.itemHeight44,
          child: Icon(
            Icons.brightness_auto_outlined,
            size: Dimensions.itemWidth20,
            color: Color(0xFF4F3DE0),
          ),
        ),
      );
}
