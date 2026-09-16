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
  Widget build(BuildContext context) {
    final Color primary = AppColors.of(context).primary;
    return Padding(
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
              leading: Icon(Icons.language, color: primary),
              title: Text('settings.language_azerbaijani'.tr()),
              trailing: _selectedLanguage == 'az'
                  ? Icon(Icons.check, color: primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'az';
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: primary),
              title: Text('settings.language_german'.tr()),
              trailing: _selectedLanguage == 'de'
                  ? Icon(Icons.check, color: primary)
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
}
