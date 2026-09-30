import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A standard surface card with the app's default border, radius, and
/// optional tap handling.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderWidth = 1.0,
    this.shadow,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  /// Overrides the default [AppColors.surface] background.
  final Color? color;
  final double borderWidth;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        border: Border.all(color: colors.border, width: borderWidth),
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        boxShadow: shadow != null ? <BoxShadow>[shadow!] : null,
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
