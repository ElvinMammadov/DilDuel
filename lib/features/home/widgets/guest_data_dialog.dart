import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_dialog.dart';
import 'package:flutter_dic/features/auth/auth.dart';

/// Asks a user who just signed in whether the data collected as a guest
/// should be uploaded to the account or thrown away.
///
/// The dialog cannot be dismissed: the sign-in flow stays on hold until one
/// of the two buttons resolves it through [AuthCubit].
class GuestDataDialog extends StatelessWidget {
  const GuestDataDialog({super.key, required this.cubit});

  final AuthCubit cubit;

  static Future<void> show(BuildContext context, AuthCubit cubit) =>
      AppDialog.show<void>(
        context,
        barrierDismissible: false,
        builder: (_) => GuestDataDialog(cubit: cubit),
      );

  void _resolve(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: AppDialog(
          icon: Icons.cloud_upload_outlined,
          title: 'auth.guest_data.title'.tr(),
          message: 'auth.guest_data.message'.tr(),
          primary: AppDialogAction(
            label: 'auth.guest_data.keep'.tr(),
            onPressed: () => _resolve(context, cubit.keepGuestData),
          ),
          secondary: AppDialogAction(
            label: 'auth.guest_data.discard'.tr(),
            onPressed: () => _resolve(context, cubit.discardGuestData),
            isDestructive: true,
          ),
        ),
      );
}
