import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class AppElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const AppElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  ButtonStyle _getButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.buttonColor,
        foregroundColor: textColor ?? Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: Dimensions.itemHeight16,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding24,
          vertical: Dimensions.padding14,
        ),
        elevation: Dimensions.itemHeight1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.itemHeight4),
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: ElevatedButton(
          style: _getButtonStyle().copyWith(
            overlayColor:
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return (textColor ?? Colors.white).withAlpha(26);
              }
              return null;
            }),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: Dimensions.itemHeight20,
                  width: Dimensions.itemWidth20,
                  child: CircularProgressIndicator(
                    strokeWidth: Dimensions.itemWidth2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white),
                  ),
                )
              : Text(text),
        ),
      );
}
