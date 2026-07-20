import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final Color? borderColor;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = borderColor ?? AppTheme.mainColor;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: color,
            width: Dimensions.itemWidth2,
          ),
          foregroundColor: color,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Dimensions.itemHeight16,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.itemHeight8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding24,
            vertical: Dimensions.padding14,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: Dimensions.itemHeight20,
                width: Dimensions.itemWidth20,
                child: CircularProgressIndicator(
                  strokeWidth: Dimensions.itemWidth2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Text(text),
      ),
    );
  }
}
