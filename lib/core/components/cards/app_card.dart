import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final ShapeBorder? shape;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: elevation ?? Dimensions.itemHeight1,
        shadowColor: Colors.black12,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.itemHeight8),
            ),
        color: backgroundColor ?? AppTheme.surfaceLight,
        borderOnForeground: true,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Dimensions.padding16),
          child: child,
        ),
      );
}
