import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            context.pop();
            onCancel?.call();
          },
          child: Text(
            'common.cancel'.tr(),
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop();
            onConfirm?.call();
          },
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          child: Text('common.confirm'.tr()),
        ),
      ],
    );
  }
}
