import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A one-pixel horizontal rule in the app's border colour.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.thickness});

  /// Line thickness; defaults to the theme's divider thickness.
  final double? thickness;

  @override
  Widget build(BuildContext context) => Divider(
    height: Dimensions.itemHeight1,
    thickness: thickness,
    color: AppColors.of(context).border,
  );
}
