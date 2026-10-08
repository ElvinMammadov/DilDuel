part of '../settings.dart';

/// Confirmation dialog that permanently deletes the signed-in account.
///
/// Password accounts must enter their password; Google and Apple accounts
/// are asked to sign in again by the provider. The dialog stays open on
/// failure so the user can retry, and closes itself on success.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider<AuthCubit>.value(
          value: context.read<AuthCubit>(),
          child: const _DeleteAccountDialog(),
        ),
      );

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;
  String? _errorKey;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _delete(AuthCubit cubit) async {
    setState(() {
      _isDeleting = true;
      _errorKey = null;
    });
    final DeleteAccountResult result = await cubit.deleteAccount(
      password: cubit.deletionNeedsPassword ? _passwordController.text : null,
    );
    if (mounted) _applyResult(result);
  }

  void _applyResult(DeleteAccountResult result) {
    switch (result) {
      case DeleteAccountResult.success:
        Navigator.of(context).pop();
      case DeleteAccountResult.cancelled:
        setState(() => _isDeleting = false);
      case DeleteAccountResult.wrongPassword:
        _showError('settings.delete_account.error_wrong_password');
      case DeleteAccountResult.networkError:
        _showError('settings.delete_account.error_network');
      case DeleteAccountResult.failed:
        _showError('settings.delete_account.error_generic');
    }
  }

  void _showError(String key) => setState(() {
        _isDeleting = false;
        _errorKey = key;
      });

  @override
  Widget build(BuildContext context) {
    final AuthCubit cubit = context.read<AuthCubit>();
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: Text('settings.delete_account.title'.tr()),
        content: _DialogBody(
          needsPassword: cubit.deletionNeedsPassword,
          passwordController: _passwordController,
          enabled: !_isDeleting,
          errorKey: _errorKey,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
            child: Text('settings.delete_account.cancel'.tr()),
          ),
          _ConfirmDeleteButton(
            isDeleting: _isDeleting,
            onPressed: () => _delete(cubit),
          ),
        ],
      ),
    );
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({
    required this.needsPassword,
    required this.passwordController,
    required this.enabled,
    required this.errorKey,
  });

  final bool needsPassword;
  final TextEditingController passwordController;
  final bool enabled;
  final String? errorKey;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('settings.delete_account.message'.tr()),
          const SizedBox(height: Dimensions.itemHeight12),
          if (needsPassword)
            _PasswordField(controller: passwordController, enabled: enabled)
          else
            Text(
              'settings.delete_account.reauth_hint'.tr(),
              style: AppTextStyles.bodySmall(colors.textSecondary),
            ),
          if (errorKey != null) ...<Widget>[
            const SizedBox(height: Dimensions.itemHeight12),
            Text(
              errorKey!.tr(),
              style: AppTextStyles.bodySmall(colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        enabled: enabled,
        obscureText: true,
        autofillHints: const <String>[AutofillHints.password],
        decoration: InputDecoration(
          hintText: 'settings.delete_account.password_hint'.tr(),
        ),
      );
}

class _ConfirmDeleteButton extends StatelessWidget {
  const _ConfirmDeleteButton({
    required this.isDeleting,
    required this.onPressed,
  });

  final bool isDeleting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: isDeleting ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.of(context).error,
        ),
        child: isDeleting
            ? const SizedBox(
                width: Dimensions.itemWidth16,
                height: Dimensions.itemHeight16,
                child: CircularProgressIndicator(
                  strokeWidth: Dimensions.itemWidth2,
                ),
              )
            : Text('settings.delete_account.confirm'.tr()),
      );
}
