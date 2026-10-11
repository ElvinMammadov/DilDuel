part of '../settings.dart';

/// Shows the app name and version, and credits the sources of the dictionary
/// data and of the CEFR levels.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.packageInfo});

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DilDuelAppBar(
      title: 'settings.about.title'.tr(),
      showBackButton: true,
      showProfileButton: false,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding18,
        Dimensions.padding16,
        Dimensions.padding18,
        Dimensions.padding30,
      ),
      children: <Widget>[
        _AboutHeader(packageInfo: packageInfo),
        const SizedBox(height: Dimensions.padding24),
        _AboutSection(
          title: 'settings.about.dictionary_title'.tr(),
          text: 'settings.about.dictionary_text'.tr(),
        ),
        const SizedBox(height: Dimensions.padding12),
        _AboutSection(
          title: 'settings.about.levels_title'.tr(),
          text: 'settings.about.levels_text'.tr(),
        ),
      ],
    ),
  );
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.packageInfo});

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      children: <Widget>[
        SizedBox.square(
          dimension: Dimensions.itemHeight72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: Dimensions.itemWidth32,
              color: colors.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.padding12),
        Text(
          'DilDuel',
          style: AppTextStyles.headlineMedium(colors.textPrimary),
        ),
        FutureBuilder<PackageInfo>(
          future: packageInfo,
          builder:
              (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) =>
                  Text(
                    'settings.version'.tr(
                      args: <String>[snapshot.data?.version ?? '...'],
                    ),
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.padding16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: AppTextStyles.titleSmall(colors.textPrimary)),
            const SizedBox(height: Dimensions.padding8),
            Text(text, style: AppTextStyles.bodyMedium(colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
