import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// The small pill at the top of a bottom sheet that hints it can be dragged.
///
/// It has no padding of its own; place it with the spacing the sheet needs.
class AppDragHandle extends StatelessWidget {
  const AppDragHandle({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.of(context).border,
      borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
    ),
    child: const SizedBox(
      width: Dimensions.itemWidth40,
      height: Dimensions.itemHeight4,
    ),
  );
}
