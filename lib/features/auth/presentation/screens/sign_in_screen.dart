part of auth;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() =>
      setState(() => _showPassword = !_showPassword);

  bool _validate() {
    String? emailErr;
    String? passErr;

    final String email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      emailErr = 'auth.validation.email_required'.tr();
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = 'auth.validation.email_invalid'.tr();
    }

    if (_passwordCtrl.text.isEmpty) {
      passErr = 'auth.validation.password_required'.tr();
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  void _submit() {
    if (!_validate()) return;
    context.read<AuthCubit>().signInWithEmailAndPassword(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  void _forgotPassword() {
    final String email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.sign_in.enter_email_first'.tr()),
        ),
      );
      return;
    }
    context.read<AuthCubit>().sendPasswordResetEmail(email);
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<AuthCubit>.value(
          value: context.read<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext ctx, AuthState state) {
          if (state is AuthAuthenticated) {
            Navigator.of(ctx).popUntil((Route<dynamic> r) => r.isFirst);
          }
          if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('auth.sign_in.reset_sent'.tr()),
                backgroundColor: AppColors.of(ctx).success,
              ),
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.of(ctx).error,
              ),
            );
            // Reset to unauthenticated so the error can fire again.
            ctx.read<AuthCubit>().clearError();
          }
        },
        // Not const: _SignInView reads mutable state via
        // findAncestorStateOfType, so it must rebuild on setState.
        // ignore: prefer_const_constructors
        child: _SignInView(),
      );
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final _SignInScreenState state =
        context.findAncestorStateOfType<_SignInScreenState>()!;
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: Dimensions.itemHeight20, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.padding24,
            Dimensions.padding8,
            Dimensions.padding24,
            Dimensions.padding30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ── Brand mark ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: Dimensions.itemWidth64,
                  height: Dimensions.itemHeight64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        colors.primary,
                        if (isDark)
                          const Color(0xFF6B5CE7)
                        else
                          const Color(0xFF7C6AEE),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(Dimensions.borderRadiusLarge),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Heading ─────────────────────────────────────────────────
              Text(
                'auth.sign_in.title'.tr(),
                style: AppTextStyles.titleLarge(colors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.itemHeight5),
              Text(
                'auth.sign_in.subtitle'.tr(),
                style: AppTextStyles.bodyMedium(colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.itemHeight30),
              // ── Email field ──────────────────────────────────────────────
              _AuthTextField(
                label: 'auth.sign_in.email_label'.tr(),
                hint: 'auth.sign_in.email_hint'.tr(),
                controller: state._emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: state._emailError,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: Dimensions.itemHeight16),
              // ── Password field ───────────────────────────────────────────
              _AuthTextField(
                label: 'auth.sign_in.password_label'.tr(),
                hint: '••••••••',
                controller: state._passwordCtrl,
                obscureText: !state._showPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => state._submit(),
                errorText: state._passwordError,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    state._showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: Dimensions.itemHeight20,
                    color: colors.textSecondary,
                  ),
                  onPressed: state.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight10),
              // ── Forgot password ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: state._forgotPassword,
                  child: Text(
                    'auth.sign_in.forgot_password'.tr(),
                    style: AppTextStyles.bodySmall(colors.primary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Sign-in button ───────────────────────────────────────────
              BlocBuilder<AuthCubit, AuthState>(
                builder: (BuildContext ctx, AuthState authState) =>
                    AppElevatedButton(
                  text: 'auth.sign_in.button'.tr(),
                  isLoading: authState is AuthLoading,
                  onPressed: state._submit,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: Dimensions.itemHeight24),
              // ── Divider ──────────────────────────────────────────────────
              const _OrDivider(),
              const SizedBox(height: Dimensions.itemHeight20),
              // ── Social buttons ───────────────────────────────────────────
              _SocialButton(
                label: 'auth.sign_in.google_button'.tr(),
                logo: const _GoogleLogo(size: 20),
                onTap: () => context.read<AuthCubit>().signInWithGoogle(),
              ),
              if (Platform.isIOS) ...<Widget>[
                const SizedBox(height: Dimensions.itemHeight12),
                _SocialButton(
                  label: 'auth.sign_in.apple_button'.tr(),
                  logo: Icon(Icons.apple,
                      size: Dimensions.itemHeight22,
                      color: colors.textPrimary),
                  onTap: () => context.read<AuthCubit>().signInWithApple(),
                ),
              ],
              const SizedBox(height: Dimensions.itemHeight30),
              // ── Register link ────────────────────────────────────────────
              _BottomNavRow(
                question: 'auth.sign_in.no_account'.tr(),
                actionLabel: 'auth.sign_in.register_link'.tr(),
                onTap: state._openRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared private widgets ──────────────────────────────────────────────────

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.labelMedium(colors.textSecondary),
        ),
        const SizedBox(height: Dimensions.itemHeight6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: AppTextStyles.bodyLarge(colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge(
              colors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: colors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: AppTextStyles.bodySmall(colors.error),
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding16,
              vertical: Dimensions.padding14,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Dimensions.padding12),
          child: Text(
            'auth.or_divider'.tr(),
            style: AppTextStyles.bodySmall(colors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.logo,
    required this.onTap,
  });

  final String label;
  final Widget logo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext ctx, AuthState state) {
        final bool loading = state is AuthLoading;
        return GestureDetector(
          onTap: loading ? null : onTap,
          child: AnimatedOpacity(
            opacity: loading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.border),
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
              child: SizedBox(
                height: Dimensions.itemHeight50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    logo,
                    const SizedBox(width: Dimensions.itemWidth12),
                    Text(
                      label,
                      style: AppTextStyles.titleSmall(colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavRow extends StatelessWidget {
  const _BottomNavRow({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(question, style: AppTextStyles.bodyMedium(colors.textSecondary)),
        const SizedBox(width: Dimensions.itemWidth5),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: AppTextStyles.bodyMedium(colors.primary).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Minimal inline Google 'G' logo.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _GoogleLogoPainter(),
      );
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset c = Offset(r, r);
    final double stroke = size.width * 0.13;

    _arc(canvas, c, r - stroke / 2, stroke, -15, 110, const Color(0xFF4285F4));
    _arc(canvas, c, r - stroke / 2, stroke, 95, 95, const Color(0xFFEA4335));
    _arc(canvas, c, r - stroke / 2, stroke, 190, 70, const Color(0xFFFBBC05));
    _arc(canvas, c, r - stroke / 2, stroke, 260, 100, const Color(0xFF34A853));

    final Paint bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(c, Offset(size.width * 0.92, r), bar);
  }

  void _arc(Canvas canvas, Offset center, double radius, double strokeWidth,
      double startDeg, double sweepDeg, Color color) {
    const double toRad = 3.14159265358979323846 / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startDeg * toRad,
      sweepDeg * toRad,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}
