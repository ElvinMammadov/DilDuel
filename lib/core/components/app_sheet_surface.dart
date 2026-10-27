import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// The rounded, bordered surface behind the content of a bottom sheet.
///
/// Open the sheet with [AppBottomSheet.show], which leaves the route
/// transparent so this surface supplies the background.
class AppSheetSurface extends StatelessWidget {
  const AppSheetSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.borderRadiusSheet),
        ),
        border: Border(
          top: BorderSide(color: colors.border),
          left: BorderSide(color: colors.border),
          right: BorderSide(color: colors.border),
        ),
      ),
      child: child,
    );
  }
}
