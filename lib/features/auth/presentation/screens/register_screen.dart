part of auth;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    String? nameErr;
    String? emailErr;
    String? passErr;
    String? confirmErr;

    if (_nameCtrl.text.trim().isEmpty) {
      nameErr = 'auth.validation.name_required'.tr();
    } else if (_nameCtrl.text.trim().split(' ').length < 2) {
      nameErr = 'auth.validation.name_full_required'.tr();
    }

    final String email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      emailErr = 'auth.validation.email_required'.tr();
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = 'auth.validation.email_invalid'.tr();
    }

    if (_passwordCtrl.text.isEmpty) {
      passErr = 'auth.validation.password_required'.tr();
    } else if (_passwordCtrl.text.length < 6) {
      passErr = 'auth.validation.password_min_length'.tr();
    }

    if (_confirmCtrl.text.isEmpty) {
      confirmErr = 'auth.validation.confirm_required'.tr();
    } else if (_confirmCtrl.text != _passwordCtrl.text) {
      confirmErr = 'auth.validation.passwords_mismatch'.tr();
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  void togglePasswordVisibility() =>
      setState(() => _showPassword = !_showPassword);

  void toggleConfirmVisibility() =>
      setState(() => _showConfirm = !_showConfirm);

  void _submit() {
    if (!_validate()) return;
    context.read<AuthCubit>().registerWithEmailAndPassword(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext ctx, AuthState state) {
          if (state is AuthAuthenticated) {
            Navigator.of(ctx).popUntil((Route<dynamic> r) => r.isFirst);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            ctx.read<AuthCubit>().clearError();
          }
        },
        // Not const: _RegisterView reads mutable state via
        // findAncestorStateOfType, so it must rebuild on setState.
        // ignore: prefer_const_constructors
        child: _RegisterView(),
      );
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final _RegisterScreenState state =
        context.findAncestorStateOfType<_RegisterScreenState>()!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color bg =
        isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: Dimensions.itemHeight20, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.padding24,
            Dimensions.padding4,
            Dimensions.padding24,
            Dimensions.padding30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ── Heading ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(Dimensions.padding16),
                decoration: BoxDecoration(
                  color: primaryTint,
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: Dimensions.itemWidth40,
                      height: Dimensions.itemHeight40,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius:
                            BorderRadius.circular(Dimensions.borderRadius),
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.itemWidth12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'auth.register.title'.tr(),
                            style: AppTextStyles.titleMedium(textPrimary),
                          ),
                          Text(
                            'auth.register.subtitle'.tr(),
                            style: AppTextStyles.bodySmall(textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Name field ───────────────────────────────────────────────
              _AuthTextField(
                label: 'auth.register.name_label'.tr(),
                hint: 'auth.register.name_hint'.tr(),
                controller: state._nameCtrl,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                errorText: state._nameError,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: Dimensions.itemHeight14),
              // ── Email field ──────────────────────────────────────────────
              _AuthTextField(
                label: 'auth.register.email_label'.tr(),
                hint: 'auth.register.email_hint'.tr(),
                controller: state._emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: state._emailError,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: Dimensions.itemHeight14),
              // ── Password field ───────────────────────────────────────────
              _AuthTextField(
                label: 'auth.register.password_label'.tr(),
                hint: '••••••••',
                controller: state._passwordCtrl,
                obscureText: !state._showPassword,
                textInputAction: TextInputAction.next,
                errorText: state._passwordError,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    state._showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: Dimensions.itemHeight20,
                    color: textSecondary,
                  ),
                  onPressed: state.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight14),
              // ── Confirm password ─────────────────────────────────────────
              _AuthTextField(
                label: 'auth.register.confirm_label'.tr(),
                hint: '••••••••',
                controller: state._confirmCtrl,
                obscureText: !state._showConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => state._submit(),
                errorText: state._confirmError,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    state._showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: Dimensions.itemHeight20,
                    color: textSecondary,
                  ),
                  onPressed: state.toggleConfirmVisibility,
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight8),
              // ── Hint ─────────────────────────────────────────────────────
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 13,
                    color: textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: Dimensions.itemWidth4),
                  Text(
                    'auth.register.password_hint'.tr(),
                    style: AppTextStyles.bodySmall(
                      textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Register button ──────────────────────────────────────────
              BlocBuilder<AuthCubit, AuthState>(
                builder: (BuildContext ctx, AuthState authState) =>
                    AppElevatedButton(
                  text: 'auth.register.button'.tr(),
                  isLoading: authState is AuthLoading,
                  onPressed: state._submit,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Divider ──────────────────────────────────────────────────
              _OrDivider(textSecondary: textSecondary, border: border),
              const SizedBox(height: Dimensions.itemHeight20),
              // ── Social buttons ───────────────────────────────────────────
              _SocialButton(
                label: 'auth.register.google_button'.tr(),
                logo: const _GoogleLogo(size: 20),
                border: border,
                textPrimary: textPrimary,
                onTap: () => context.read<AuthCubit>().signInWithGoogle(),
              ),
              if (Platform.isIOS) ...<Widget>[
                const SizedBox(height: Dimensions.itemHeight12),
                _SocialButton(
                  label: 'auth.register.apple_button'.tr(),
                  logo: Icon(Icons.apple,
                      size: Dimensions.itemHeight22, color: textPrimary),
                  border: border,
                  textPrimary: textPrimary,
                  onTap: () => context.read<AuthCubit>().signInWithApple(),
                ),
              ],
              const SizedBox(height: Dimensions.itemHeight30),
              // ── Sign-in link ─────────────────────────────────────────────
              _BottomNavRow(
                question: 'auth.register.has_account'.tr(),
                actionLabel: 'auth.register.sign_in_link'.tr(),
                textSecondary: textSecondary,
                primary: primary,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
