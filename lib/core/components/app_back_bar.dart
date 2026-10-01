import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A compact top bar with a back arrow, optional [leading] and a [label],
/// shown when a section opened from a list of [AppFilledCard]s is active.
class AppBackBar extends StatelessWidget {
  const AppBackBar({
    super.key,
    required this.onBack,
    this.label,
    this.leading,
  });

  final VoidCallback onBack;
  final String? label;

  /// Optional widget shown between the back arrow and the [label].
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(Dimensions.padding4),
      child: Row(
        children: <Widget>[
          BackButton(color: colors.textPrimary, onPressed: onBack),
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: Dimensions.padding8),
          ],
          if (label != null)
            Text(label!, style: AppTextStyles.titleSmall(colors.textPrimary)),
        ],
      ),
    );
  }
}
