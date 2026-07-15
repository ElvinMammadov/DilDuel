import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

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
  Widget build(BuildContext context) => AlertDialog(
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
              style: const TextStyle(color: AppTheme.textSecondaryLight),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mainColor,
            ),
            child: Text('common.confirm'.tr()),
          ),
        ],
      );
} 