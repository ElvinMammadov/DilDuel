part of '../settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _packageInfo;

  // TODO: replace with real auth state once sign-in is implemented
  static const bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => const LanguageBottomSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.itemHeight16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark = theme.brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color error = isDark ? AppTheme.errorColorDark : AppTheme.errorColor;
    final Color errorTint =
        isDark ? AppTheme.errorTintDark : AppTheme.errorTint;

    return Scaffold(
      appBar: DilDuelAppBar(
        title: 'settings.title'.tr(),
        showBackButton: true,
        showProfileButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        children: <Widget>[
          // Profile card
          _SettingsCard(
            border: border,
            surface: surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _isSignedIn ? primary : primaryTint,
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: _isSignedIn ? Colors.white : primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isSignedIn) ...<Widget>[
                    Text(
                      'settings.profile.name'.tr(),
                      style: AppTheme.titleMedium(textPrimary)
                          .copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'settings.profile.email'.tr(),
                      style: AppTheme.bodyMedium(textSecondary)
                          .copyWith(fontSize: 13),
                    ),
                  ] else ...<Widget>[
                    Text(
                      'settings.profile.guest'.tr(),
                      style: AppTheme.titleMedium(textPrimary)
                          .copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'settings.profile.guest_hint'.tr(),
                      style: AppTheme.bodyMedium(textSecondary)
                          .copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusPill),
                      ),
                      child: Text(
                        _isSignedIn
                            ? 'settings.profile.edit'.tr()
                            : 'settings.sign_in'.tr(),
                        style: AppTheme.bodyMedium(Colors.white).copyWith(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Language
          _SettingsCard(
            border: border,
            surface: surface,
            child: _SettingsRow(
              icon: Icons.language_outlined,
              iconColor: primary,
              title: 'settings.language'.tr(),
              subtitle: context.locale.languageCode == 'az'
                  ? 'Azərbaycan dili'
                  : 'German',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: _showLanguageBottomSheet,
            ),
          ),
          const SizedBox(height: 8),

          // Theme
          _SettingsCard(
            border: border,
            surface: surface,
            child: const ThemeCard(),
          ),
          const SizedBox(height: 8),

          // FAQ
          _SettingsCard(
            border: border,
            surface: surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Text('settings.faq.title'.tr(),
                      style: AppTheme.titleMedium(textPrimary)),
                ),
                Divider(height: 1, color: border),
                _FaqItem(
                  question: 'settings.faq.dictionary_usage'.tr(),
                  answer: 'Axtar bölməsində sözü yazın '
                      'və ya mikrofon düyməsi ilə səsli axtarış edin.',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  showDivider: true,
                ),
                _FaqItem(
                  question: 'settings.faq.quiz_usage'.tr(),
                  answer: 'Hər testdə 10 sual olur. '
                      'Düzgün cavabları seçərək xalınızı artırın.',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // About
          _SettingsCard(
            border: border,
            surface: surface,
            child: FutureBuilder<PackageInfo>(
              future: _packageInfo,
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                final String version =
                    snapshot.hasData ? snapshot.data!.version : '...';
                return _SettingsRow(
                  icon: Icons.info_outline,
                  iconColor: primary,
                  title: 'settings.about'.tr(),
                  subtitle: 'settings.version'.tr(args: <String>[version]),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  showChevron: false,
                  onTap: () {},
                );
              },
            ),
          ),

          // Logout — only shown when signed in
          if (_isSignedIn) ...<Widget>[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: errorTint,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Text(
                  'settings.logout'.tr(),
                  style: AppTheme.titleMedium(error).copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color border;
  final Color surface;

  const _SettingsCard(
      {required this.child, required this.border, required this.surface});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      );
}

class _SettingsRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsRow({
    this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: AppTheme.titleMedium(textPrimary)
                            .copyWith(fontSize: 15)),
                    Text(subtitle,
                        style: AppTheme.bodyMedium(textSecondary)
                            .copyWith(fontSize: 13)),
                  ],
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right,
                    size: 16, color: textSecondary.withValues(alpha: 0.4)),
            ],
          ),
        ),
      );
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final bool showDivider;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.showDivider,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(widget.question,
                          style: AppTheme.bodyLarge(widget.textPrimary)
                              .copyWith(fontSize: 14))),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _open ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 18, color: widget.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(widget.answer,
                  style: AppTheme.bodyMedium(widget.textSecondary)
                      .copyWith(height: 1.5, fontSize: 13)),
            ),
          if (widget.showDivider) Divider(height: 1, color: widget.border),
        ],
      );
}
