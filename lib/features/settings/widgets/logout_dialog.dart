part of '../settings.dart';

/// Asks for confirmation before signing out and explains what happens to
/// the data on the device: it is removed locally but stays in the cloud
/// account, so signing in again restores it.
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  static Future<void> show(BuildContext context) {
    final AuthCubit cubit = context.read<AuthCubit>();
    return AppDialog.show<void>(
      context,
      builder: (_) => _LogoutDialog(onConfirm: cubit.signOut),
    );
  }

  @override
  Widget build(BuildContext context) => AppDialog(
        icon: Icons.logout_rounded,
        isDestructive: true,
        title: 'settings.logout_dialog.title'.tr(),
        message: 'settings.logout_dialog.message'.tr(),
        primary: AppDialogAction(
          label: 'settings.logout_dialog.cancel'.tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        secondary: AppDialogAction(
          label: 'settings.logout_dialog.confirm'.tr(),
          isDestructive: true,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      );
}
