import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A labelled, rounded text field in the app's standard style.
///
/// Set [maxLength] to cap the input; the character counter is only shown
/// when [showCounter] is true.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final bool obscureText;

  /// Icon shown inside the field before the text.
  final IconData? prefixIcon;

  /// Widget shown inside the field after the text, such as a visibility
  /// toggle.
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _border(
    Color color, {
    double width = Dimensions.itemWidth1,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimensions.borderRadius),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.labelMedium(colors.textSecondary)),
        const SizedBox(height: Dimensions.itemHeight6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: AppTextStyles.bodyLarge(colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge(
              colors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: Dimensions.itemWidth20,
                    color: colors.textSecondary,
                  ),
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: AppTextStyles.bodySmall(colors.error),
            counterText: showCounter ? null : '',
            counterStyle: AppTextStyles.caption(colors.textSecondary),
            filled: true,
            fillColor: colors.surface,
            border: _border(colors.border),
            enabledBorder: _border(colors.border),
            disabledBorder: _border(colors.border),
            focusedBorder: _border(
              colors.primary,
              width: Dimensions.itemWidth2,
            ),
            errorBorder: _border(colors.error),
            focusedErrorBorder: _border(
              colors.error,
              width: Dimensions.itemWidth2,
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
