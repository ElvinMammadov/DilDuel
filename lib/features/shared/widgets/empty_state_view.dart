import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A reusable empty / placeholder state widget.
///
/// Shows a tinted circle with an [icon] inside, followed by a [title] and an
/// optional [description]. Uses [Spacer] widgets to position the content at a
/// consistent vertical position regardless of description length — the icon
/// always lands at roughly 40 % from the top of the available space.
///
/// **Must be placed inside a height-constrained parent** such as [Expanded] or
/// a [SizedBox] with a fixed height. Using it in an unconstrained context
/// (e.g., a plain [Column] with `mainAxisSize: min`) will throw a layout error
/// because [Spacer] requires bounded height.
class EmptyStateView extends StatelessWidget {
  /// Icon drawn inside the tinted circle.
  final IconData icon;

  /// Primary color used for the icon and (when [tintColor] is omitted) derived
  /// as a low-opacity overlay on the surface.
  final Color color;

  /// Background tint of the circle. Defaults to a light variant of [color].
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color circleBg = tintColor ??
        (isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint);

    // Spacer(flex: 2) above + Spacer(flex: 3) below anchors the icon at the
    // same relative position (40 % from top) regardless of description length,
    // so switching between tabs with different-length descriptions never shifts
    // the icon vertically.
    return Column(
      children: <Widget>[
        const Spacer(flex: 2),
        Container(
          width: Dimensions.itemHeight72,
          height: Dimensions.itemHeight72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: Dimensions.itemWidth36, color: color),
        ),
        const SizedBox(height: Dimensions.itemHeight16),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding32),
          child: Text(
            title,
            style: AppTextStyles.titleMedium(textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
        if (description != null) ...<Widget>[
          const SizedBox(height: Dimensions.itemHeight6),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding32),
            child: Text(
              description!,
              style: AppTextStyles.bodyMedium(textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const Spacer(flex: 3),
      ],
    );
  }
}
