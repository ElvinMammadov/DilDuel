import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_pill.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/article_color.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A pill showing a German [article] (der, die or das) in its grammar colour.
class ArticleChip extends StatelessWidget {
  const ArticleChip({super.key, required this.article});

  final String article;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = articleColor(article, colors, isDark: isDark);
    return AppPill(
      color: articleTintColor(article, colors, isDark: isDark),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding10,
        vertical: Dimensions.padding3,
      ),
      child: Text(article, style: AppTextStyles.labelMedium(color)),
    );
  }
}
