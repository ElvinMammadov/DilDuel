import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A reusable bottom sheet scaffold: drag handle + titled header with a
/// close button + arbitrary [child] content.
///
/// Use [AppBottomSheet.show] to open it so the [showModalBottomSheet]
/// options (transparent background, barrier colour) stay consistent
/// across the app.
///
/// ```dart
/// AppBottomSheet.show(
///   context,
///   child: const LanguageBottomSheet(),
///   isScrollControlled: true,
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  final String title;
  final Widget child;

  /// Called when the × button is tapped. Defaults to [Navigator.pop].
  final VoidCallback? onClose;

  /// Opens [child] inside a transparent modal bottom sheet with the
  /// standard barrier colour.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = false,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) => child,
      );

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.borderRadiusSheet),
        ),
        border: Border(
          top: BorderSide(color: colors.border),
          left: BorderSide(color: colors.border),
          right: BorderSide(color: colors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Handle(color: colors.border),
            _Header(
              title: title,
              iconBg: colors.chipBg,
              iconColor: colors.textSecondary,
              onClose: onClose ?? () => Navigator.of(context).pop(),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Dimensions.padding12),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(Dimensions.borderRadiusPill),
            ),
            child: const SizedBox(
              width: Dimensions.itemWidth36,
              height: Dimensions.itemHeight4,
            ),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.iconBg,
    required this.iconColor,
    required this.onClose,
  });

  final String title;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding20,
        Dimensions.padding12,
        Dimensions.padding20,
        Dimensions.padding16,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium(colors.textPrimary)
                  .copyWith(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: Dimensions.itemWidth32,
                height: Dimensions.itemHeight32,
                child: Icon(
                  Icons.close,
                  size: Dimensions.itemWidth16,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
