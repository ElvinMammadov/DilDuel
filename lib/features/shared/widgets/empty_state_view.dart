import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A reusable empty / placeholder state widget.
///
/// The icon circle is always centered in the available space. The [title] and
/// optional [description] hang directly below the circle with a fixed gap, so
/// varying text length never shifts the icon's vertical position.
///
/// Works in any height-constrained parent — [Expanded], [SizedBox], or a full
/// screen. Avoid placing it inside an unconstrained column.
class EmptyStateView extends StatelessWidget {
  /// Icon drawn inside the tinted circle.
  final IconData icon;

  /// Foreground color for the icon.
  final Color color;

  /// Background tint of the circle. Falls back to the theme primary tint.
  final Color? tintColor;

  /// Bold heading below the circle.
  final String title;

  /// Smaller secondary text below the title. Pass `null` to hide.
  final String? description;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.color,
    this.tintColor,
    required this.title,
    this.description,
  });

  static const double _circleSize = Dimensions.itemHeight72;
  static const double _iconSize = Dimensions.itemWidth36;
  static const double _circleRadius = _circleSize / 2;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color circleBg = tintColor ?? colors.primaryTint;

    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final double centerY = constraints.maxHeight / 2;

        return Stack(
          children: <Widget>[
            // ── Icon circle — always at true vertical center ──────────
            Positioned(
              top: centerY - _circleRadius,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: _circleSize,
                  height: _circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: _iconSize, color: color),
                ),
              ),
            ),

            // ── Text block — hangs below the circle ───────────────────
            Positioned(
              top: centerY + _circleRadius + Dimensions.itemHeight16,
              left: Dimensions.padding32,
              right: Dimensions.padding32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.titleMedium(colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  if (description != null) ...<Widget>[
                    const SizedBox(height: Dimensions.itemHeight6),
                    Text(
                      description!,
                      style: AppTextStyles.bodyMedium(colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
