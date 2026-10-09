part of '../settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  void _openSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SignInScreen(onAuthenticated: () => Navigator.of(context).pop()),
      ),
    );
  }

  void _openFaq() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const FaqScreen()));
  }

  void _openFeedback() {
    final AuthState authState = context.read<AuthCubit>().state;
    final String name = switch (authState) {
      AuthAuthenticated(:final AuthUser user) => user.displayName ?? '',
      _ => '',
    };
    FeedbackBottomSheet.show(context, initialName: name);
  }

  Future<void> _openLink(Uri Function(String languageCode) pageFor) async {
    final String languageCode = context.locale.languageCode;
    final bool opened = await launchUrl(
      pageFor(languageCode),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      AppSnackbar.show(
        context,
        type: SnackbarType.error,
        title: 'settings.link_error'.tr(),
      );
    }
  }

  void _showLanguageBottomSheet() {
    AppBottomSheet.show<void>(
      context,
      child: const LanguageBottomSheet(),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          (previous is AuthAuthenticated && current is AuthUnauthenticated) ||
          (previous is AuthUnauthenticated && current is AuthAuthenticated),
      listener: (BuildContext ctx, AuthState state) {
        if (state is AuthUnauthenticated) {
          AppSnackbar.show(
            ctx,
            type: SnackbarType.success,
            title: state is AuthAccountDeleted
                ? 'settings.delete_account.success'.tr()
                : 'settings.logout_success'.tr(),
          );
        } else if (state is AuthAuthenticated) {
          AppSnackbar.show(
            ctx,
            type: SnackbarType.success,
            title: 'auth.sign_in.success'.tr(),
            subtitle: 'auth.sign_in.success_subtitle'.tr(),
          );
        }
      },
      child: Scaffold(
        appBar: DilDuelAppBar(
          title: 'settings.title'.tr(),
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
            _ProfileCard(onSignIn: _openSignIn),
            const SizedBox(height: Dimensions.itemHeight14),
            _SettingsGroup(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.language_outlined,
                  iconBackground: colors.levelB1,
                  title: 'settings.language'.tr(),
                  subtitle: 'settings.language_name'.tr(),
                  onTap: _showLanguageBottomSheet,
                ),
                const ThemeRow(),
              ],
            ),
            const SizedBox(height: Dimensions.itemHeight14),
            _SettingsGroup(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.help_outline,
                  iconBackground: colors.quizCard,
                  title: 'settings.faq.title'.tr(),
                  subtitle: 'settings.faq.row_subtitle'.tr(
                    args: <String>['${FaqScreen.itemCount}'],
                  ),
                  onTap: _openFaq,
                ),
                _SettingsRow(
                  icon: Icons.rate_review_outlined,
                  iconBackground: colors.resultsCard,
                  title: 'settings.feedback.title'.tr(),
                  subtitle: 'settings.feedback.row_subtitle'.tr(),
                  onTap: _openFeedback,
                ),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  iconBackground: colors.levelB2,
                  title: 'settings.privacy_policy.title'.tr(),
                  subtitle: 'settings.privacy_policy.subtitle'.tr(),
                  onTap: () => _openLink(LegalLinks.privacyPolicy),
                ),
                _SettingsRow(
                  icon: Icons.gavel_outlined,
                  iconBackground: colors.unknownCard,
                  title: 'settings.legal_notice.title'.tr(),
                  subtitle: 'settings.legal_notice.subtitle'.tr(),
                  onTap: () => _openLink(LegalLinks.impressum),
                ),
              ],
            ),
            const _AccountActions(),
            const SizedBox(height: Dimensions.itemHeight24),
            _VersionFooter(packageInfo: _packageInfo),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onSignIn;

  const _ProfileCard({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        final AuthUser? user = switch (authState) {
          AuthAuthenticated(:final AuthUser user) => user,
          _ => null,
        };
        final bool isSignedIn = authState is AuthAuthenticated;
        final String? subtitle = isSignedIn
            ? user?.visibleEmail
            : 'settings.profile.guest_hint'.tr();

        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding20,
            vertical: Dimensions.padding24,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: Dimensions.itemHeight36,
                  backgroundColor: isSignedIn
                      ? colors.primary
                      : colors.primaryTint,
                  child: Icon(
                    Icons.person,
                    size: Dimensions.itemWidth28,
                    color: isSignedIn ? colors.onPrimary : colors.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.itemHeight10),
                Text(
                  isSignedIn
                      ? user?.displayName ?? 'settings.profile.title'.tr()
                      : 'settings.profile.guest'.tr(),
                  style: AppTextStyles.titleMedium(colors.textPrimary),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: Dimensions.itemHeight2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (!isSignedIn) ...<Widget>[
                  const SizedBox(height: Dimensions.itemHeight14),
                  AppElevatedButton(
                    text: 'settings.sign_in'.tr(),
                    onPressed: onSignIn,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState authState) {
      if (authState is! AuthAuthenticated) {
        return const SizedBox.shrink();
      }
      final AppColors colors = AppColors.of(context);

      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.itemHeight14),
        child: Column(
          children: <Widget>[
            AppElevatedButton(
              text: 'settings.logout'.tr(),
              onPressed: () => context.read<AuthCubit>().signOut(),
              width: double.infinity,
              backgroundColor: colors.errorTint,
              textColor: colors.error,
            ),
            const SizedBox(height: Dimensions.itemHeight10),
            AppOutlinedButton(
              text: 'settings.delete_account.button'.tr(),
              onPressed: () => _DeleteAccountDialog.show(context),
              width: double.infinity,
              borderColor: colors.error,
            ),
          ],
        ),
      );
    },
  );
}

class _VersionFooter extends StatelessWidget {
  final Future<PackageInfo> packageInfo;

  const _VersionFooter({required this.packageInfo});

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: packageInfo,
    builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
      final String version = snapshot.data?.version ?? '...';
      return Text(
        'settings.version'.tr(args: <String>[version]),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption(AppColors.of(context).textSecondary),
      );
    },
  );
}

/// One card holding several [_SettingsRow]s separated by inset dividers.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  static const double _dividerIndent =
      Dimensions.padding16 + Dimensions.itemWidth32 + Dimensions.itemWidth12;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = AppColors.of(context).border;

    return AppCard(
      child: Column(
        children: <Widget>[
          for (int index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: Dimensions.itemHeight1,
                indent: _dividerIndent,
                color: dividerColor,
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding12,
        ),
        child: Row(
          children: <Widget>[
            _IconTile(icon: icon, background: iconBackground),
            const SizedBox(width: Dimensions.itemWidth12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(colors.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: Dimensions.itemWidth16,
              color: colors.textSecondary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style rounded square with a white glyph on a colored background.
class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color background;

  const _IconTile({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
    ),
    child: SizedBox(
      width: Dimensions.itemWidth32,
      height: Dimensions.itemHeight32,
      child: Icon(icon, size: Dimensions.itemWidth18, color: Colors.white),
    ),
  );
}
