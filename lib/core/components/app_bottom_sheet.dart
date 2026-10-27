import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_close_button.dart';
import 'package:flutter_dic/core/components/app_drag_handle.dart';
import 'package:flutter_dic/core/components/app_sheet_surface.dart';
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
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.of(context).barrier,
    builder: (_) => child,
  );

  @override
  Widget build(BuildContext context) => AppSheetSurface(
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: Dimensions.padding12),
            child: AppDragHandle(),
          ),
          _Header(
            title: title,
            onClose: onClose ?? () => Navigator.of(context).pop(),
          ),
          child,
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
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
            style: AppTextStyles.titleMedium(
              AppColors.of(context).textPrimary,
            ).copyWith(fontSize: 18),
          ),
        ),
        AppCloseButton(onTap: onClose),
      ],
    ),
  );
}
