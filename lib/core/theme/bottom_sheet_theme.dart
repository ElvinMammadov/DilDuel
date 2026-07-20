import 'package:flutter/material.dart';
import 'package:flutter_dic/core/utils/sizes.dart';

class CustomBottomSheetTheme extends BottomSheetThemeData {
  const CustomBottomSheetTheme()
      : super(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppSizes.topRadius),
              topLeft: Radius.circular(AppSizes.topRadius),
            ),
          ),
        );
}
