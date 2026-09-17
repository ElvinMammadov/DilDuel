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
        builder: (_) => const SignInScreen(),
      ),
    );
  }

  Future<void> _signOut() => context.read<AuthCubit>().signOut();

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
          previous is AuthAuthenticated && current is AuthUnauthenticated,
      listener: (BuildContext ctx, AuthState state) {
        final NavigatorState navigator = Navigator.of(ctx);
        final OverlayState? overlay = navigator.overlay;
        navigator.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (overlay != null && overlay.mounted) {
            AppSnackbar.showOnOverlay(
              overlay,
              type: SnackbarType.success,
              title: 'settings.logout_success'.tr(),
            );
          }
        });
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
            // Profile card
            BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext ctx, AuthState authState) {
                final bool isSignedIn = authState is AuthAuthenticated;
                final AuthUser? user = switch (authState) {
                  AuthAuthenticated(:final AuthUser user) => user,
                  _ => null,
                };
                final AppColors ctxColors = AppColors.of(ctx);

                return _SettingsCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.padding20,
                      Dimensions.padding24,
                      Dimensions.padding20,
                      Dimensions.padding24,
                    ),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: Dimensions.itemHeight36,
                          backgroundColor: isSignedIn
                              ? ctxColors.primary
                              : ctxColors.primaryTint,
                          child: Icon(
                            Icons.person,
                            size: Dimensions.itemWidth28,
                            color:
                                isSignedIn ? Colors.white : ctxColors.primary,
                          ),
                        ),
                        const SizedBox(height: Dimensions.itemHeight10),
                        if (isSignedIn) ...<Widget>[
                          Text(
                            user?.displayName ?? 'settings.profile.name'.tr(),
                            style: AppTextStyles.titleMedium(
                              ctxColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: Dimensions.itemHeight2),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.bodySmall(
                              ctxColors.textSecondary,
                            ),
                          ),
                        ] else ...<Widget>[
                          Text(
                            'settings.profile.guest'.tr(),
                            style: AppTextStyles.titleMedium(
                              ctxColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: Dimensions.itemHeight2),
                          Text(
                            'settings.profile.guest_hint'.tr(),
                            style: AppTextStyles.bodyMedium(
                              ctxColors.textSecondary,
                            ).copyWith(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: Dimensions.itemHeight14),
                        if (!isSignedIn)
                          GestureDetector(
                            onTap: _openSignIn,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.padding22,
                                  vertical: Dimensions.padding10),
                              decoration: BoxDecoration(
                                color: ctxColors.primary,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.borderRadiusPill),
                              ),
                              child: Text(
                                'settings.sign_in'.tr(),
                                style: AppTextStyles.labelMedium(Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Dimensions.itemHeight14),

            // Language
            _SettingsCard(
              child: _SettingsRow(
                icon: Icons.language_outlined,
                iconColor: colors.primary,
                title: 'settings.language'.tr(),
                subtitle: 'settings.language_name'.tr(),
                onTap: _showLanguageBottomSheet,
              ),
            ),
            const SizedBox(height: Dimensions.padding8),

            // Theme
            const _SettingsCard(child: ThemeCard()),
            const SizedBox(height: Dimensions.padding8),

            // FAQ
            _SettingsCard(
              child: _SettingsRow(
                icon: Icons.help_outline,
                iconColor: colors.primary,
                title: 'settings.faq.title'.tr(),
                subtitle: 'settings.faq.row_subtitle'.tr(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FaqScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.padding8),

            // About
            _SettingsCard(
              child: FutureBuilder<PackageInfo>(
                future: _packageInfo,
                builder: (BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot) {
                  final String version =
                      snapshot.hasData ? snapshot.data!.version : '...';
                  return _SettingsRow(
                    icon: Icons.info_outline,
                    iconColor: AppColors.of(context).primary,
                    title: 'settings.about'.tr(),
                    subtitle: 'settings.version'.tr(args: <String>[version]),
                    showChevron: false,
                    onTap: () {},
                  );
                },
              ),
            ),

            // Logout — only shown when signed in
            BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext ctx, AuthState authState) {
                if (authState is! AuthAuthenticated) {
                  return const SizedBox.shrink();
                }
                final AppColors ctxColors = AppColors.of(ctx);
                return Column(
                  children: <Widget>[
                    const SizedBox(height: Dimensions.itemHeight14),
                    AppElevatedButton(
                      text: 'settings.logout'.tr(),
                      onPressed: _signOut,
                      width: double.infinity,
                      backgroundColor: ctxColors.errorTint,
                      textColor: ctxColors.error,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsRow({
    this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16, vertical: Dimensions.padding14),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: Dimensions.itemWidth20, color: iconColor),
              const SizedBox(width: Dimensions.itemWidth12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: AppTextStyles.titleSmall(colors.textPrimary)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall(colors.textSecondary)),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right,
                  size: Dimensions.itemWidth16,
                  color: colors.textSecondary.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.showDivider,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding16,
                vertical: Dimensions.padding14),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(widget.question,
                        style: AppTextStyles.bodyMedium(colors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600))),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _open ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: Dimensions.itemWidth18,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.padding16,
              0,
              Dimensions.padding16,
              Dimensions.padding14,
            ),
            child: Text(widget.answer,
                style: AppTextStyles.bodyMedium(colors.textPrimary)
                    .copyWith(height: 1.5, fontSize: 13)),
          ),
        if (widget.showDivider) Divider(height: 1, color: colors.border),
      ],
    );
  }
}
