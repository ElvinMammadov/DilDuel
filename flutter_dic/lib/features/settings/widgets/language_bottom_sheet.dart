part of '../settings.dart';

class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  String? _selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage ??= context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Dimensions.padding16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'settings.language'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Dimensions.itemHeight24),
            ListTile(
              leading: const Icon(
                Icons.language,
                color: AppTheme.mainColor,
              ),
              title: const Text('Azerbaijani'),
              trailing: _selectedLanguage == 'az'
                  ? const Icon(Icons.check, color: AppTheme.mainColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'az';
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.language,
                color: AppTheme.mainColor,
              ),
              title: const Text('German'),
              trailing: _selectedLanguage == 'de'
                  ? const Icon(Icons.check, color: AppTheme.mainColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'de';
                });
              },
            ),
            const SizedBox(height: Dimensions.itemHeight24),
            AppElevatedButton(
              text: 'common.confirm'.tr(),
              onPressed: () {
                if (_selectedLanguage != null) {
                  context.setLocale(Locale(_selectedLanguage!));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
} 