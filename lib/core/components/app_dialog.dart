import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/components/buttons/app_outlined_button.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A button shown at the bottom of an [AppDialog].
class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String label;

  /// When `null` the button is disabled.
  final VoidCallback? onPressed;

  /// Paints the button in the error colour, for actions that delete or
  /// discard something.
  final bool isDestructive;

  /// Replaces the label with a spinner and disables the button.
  final bool isLoading;
}

/// The app's standard dialog: a tinted icon, a centred title and message,
/// an optional [body], and one or two full-width buttons.
///
/// The [primary] action is a filled pill and the optional [secondary] one is
/// an outlined button below it. Put the safe choice first so that the
/// destructive one needs a deliberate tap.
///
/// The dialog does not pop itself: each action's `onPressed` closes it, so
/// callers decide what happens first. Open it with [AppDialog.show].
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.primary,
    this.message,
    this.body,
    this.secondary,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Extra content shown under the [message], such as an input field.
  final Widget? body;

  final AppDialogAction primary;
  final AppDialogAction? secondary;

  /// Tints the icon with the error colour instead of the primary one.
  final bool isDestructive;

  /// Opens [builder]'s dialog with the standard barrier colour.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) =>
      showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: AppColors.of(context).barrier,
        builder: builder,
      );

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.all(Dimensions.padding24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSheet),
        side: BorderSide(color: colors.border),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.padding24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DialogIcon(icon: icon, isDestructive: isDestructive),
            const SizedBox(height: Dimensions.itemHeight20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleXLarge(colors.textPrimary),
            ),
            if (message case final String text) ...<Widget>[
              const SizedBox(height: Dimensions.itemHeight12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(colors.textSecondary)
                    .copyWith(height: 1.5),
              ),
            ],
            if (body case final Widget content) ...<Widget>[
              const SizedBox(height: Dimensions.itemHeight16),
              content,
            ],
            const SizedBox(height: Dimensions.itemHeight24),
            _PrimaryButton(action: primary, colors: colors),
            if (secondary case final AppDialogAction action) ...<Widget>[
              const SizedBox(height: Dimensions.itemHeight12),
              _SecondaryButton(action: action, colors: colors),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon({required this.icon, required this.isDestructive});

  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDestructive ? colors.errorTint : colors.primaryTint,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: Dimensions.itemHeight64,
        height: Dimensions.itemHeight64,
        child: Icon(
          icon,
          size: Dimensions.itemWidth32,
          color: isDestructive ? colors.error : colors.primary,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.action, required this.colors});

  final AppDialogAction action;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => AppElevatedButton(
        text: action.label,
        width: double.infinity,
        isLoading: action.isLoading,
        onPressed: action.onPressed,
        backgroundColor: action.isDestructive ? colors.error : null,
      );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.action, required this.colors});

  final AppDialogAction action;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => AppOutlinedButton(
        text: action.label,
        width: double.infinity,
        isLoading: action.isLoading,
        onPressed: action.onPressed,
        borderColor: action.isDestructive ? colors.error : null,
      );
}
