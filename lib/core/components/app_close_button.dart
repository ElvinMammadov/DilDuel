import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A small circular "×" button for dismissing a sheet or dialog.
///
/// Matches the close button in [AppBottomSheet]'s header.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.chipBg,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: Dimensions.itemWidth32,
            height: Dimensions.itemHeight32,
            child: Icon(
              Icons.close,
              size: Dimensions.itemWidth16,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
