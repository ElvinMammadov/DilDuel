import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_filled_card.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// An [AppFilledCard] showing an [icon], a [label] and an optional [count].
class AppIconFilledCard extends StatelessWidget {
  const AppIconFilledCard({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    this.count,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final Color onPrimary = AppColors.of(context).onPrimary;
    return AppFilledCard(
      color: color,
      onTap: onTap,
      watermark: Icon(
        icon,
        size: Dimensions.itemHeight88,
        color: onPrimary.withValues(alpha: 0.10),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: Dimensions.itemWidth24, color: onPrimary),
          const SizedBox(width: Dimensions.padding12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleLarge(onPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count != null)
            Text('$count', style: AppTextStyles.titleLarge(onPrimary)),
        ],
      ),
    );
  }
}
