part of '../settings.dart';

class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  late String _selectedLanguage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _selectedLanguage = context.locale.languageCode;
      _initialized = true;
    }
  }

  void _apply() {
    final OverlayState? overlay = Navigator.of(context).overlay;
    final String selected = _selectedLanguage;
    context.setLocale(Locale(selected));
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (overlay != null && overlay.mounted) {
        final String langName = selected == 'az'
            ? 'settings.language_azerbaijani'.tr()
            : 'settings.language_german'.tr();
        AppSnackbar.showOnOverlay(
          overlay,
          type: SnackbarType.success,
          title: 'settings.language_changed'.tr(),
          subtitle: 'settings.language_changed_to'.tr(args: <String>[langName]),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return AppBottomSheet(
      title: 'settings.choose_language'.tr(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(height: 1, color: colors.border),
          _LanguageRow(
            flag: '🇦🇿',
            name: 'settings.language_azerbaijani'.tr(),
            isSelected: _selectedLanguage == 'az',
            onTap: () => setState(() => _selectedLanguage = 'az'),
          ),
          _LanguageRow(
            flag: '🇩🇪',
            name: 'settings.language_german'.tr(),
            isSelected: _selectedLanguage == 'de',
            onTap: () => setState(() => _selectedLanguage = 'de'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.padding20,
              Dimensions.padding14,
              Dimensions.padding20,
              Dimensions.padding24,
            ),
            child: AppElevatedButton(
              text: 'common.confirm'.tr(),
              onPressed: _apply,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected ? colors.primaryTint : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding20,
            vertical: Dimensions.padding14,
          ),
          child: Row(
            children: <Widget>[
              Text(
                flag,
                style: const TextStyle(fontSize: Dimensions.itemHeight20),
              ),
              const SizedBox(width: Dimensions.itemWidth14),
              Expanded(
                child: Text(
                  name,
                  style: isSelected
                      ? AppTextStyles.titleSmall(colors.textPrimary)
                      : AppTextStyles.bodyMedium(colors.textSecondary)
                          .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              if (isSelected)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: Dimensions.itemWidth18,
                    height: Dimensions.itemHeight18,
                    child: Icon(Icons.check, size: 11, color: Colors.white),
                  ),
                )
              else
                const SizedBox(
                  width: Dimensions.itemWidth18,
                  height: Dimensions.itemHeight18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
