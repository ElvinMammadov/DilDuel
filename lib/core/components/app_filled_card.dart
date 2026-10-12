import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A wide, short card on the [AppColors.surface] background with a border,
/// a soft shadow and an optional oversized [watermark] in the bottom-right
/// corner.
///
/// A trailing chevron signals that the card is tappable. Content is expected
/// to use [AppColors.primary] for text and icons.
class AppFilledCard extends StatelessWidget {
  const AppFilledCard({
    super.key,
    required this.onTap,
    required this.child,
    this.watermark,
  });

  final VoidCallback onTap;
  final Widget child;
  final Widget? watermark;

  BoxDecoration _decoration(AppColors colors) => BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadowSubtle,
            blurRadius: Dimensions.itemHeight20,
            offset: const Offset(0, Dimensions.itemHeight8),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: _decoration(AppColors.of(context)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              child: SizedBox(
                height: Dimensions.itemHeight88,
                child: Stack(
                  children: <Widget>[
                    if (watermark case final Widget mark)
                      Positioned(
                        right: -Dimensions.padding8,
                        bottom: -Dimensions.padding20,
                        child: mark,
                      ),
                    Positioned.fill(child: _CardContent(child: child)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Dimensions.padding16),
        child: Row(
          children: <Widget>[
            Expanded(child: child),
            const SizedBox(width: Dimensions.padding8),
            Icon(
              Icons.chevron_right_rounded,
              size: Dimensions.itemWidth24,
              color: AppColors.of(context).primary.withValues(alpha: 0.70),
            ),
          ],
        ),
      );
}
