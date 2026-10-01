import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A wide, short card filled with a solid [color], with a soft colored
/// shadow and an optional oversized [watermark] in the bottom-right corner.
///
/// A trailing chevron signals that the card is tappable. Content is expected
/// to use [AppColors.onPrimary] for text and icons.
class AppFilledCard extends StatelessWidget {
  const AppFilledCard({
    super.key,
    required this.color,
    required this.onTap,
    required this.child,
    this.watermark,
  });

  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final Widget? watermark;

  BoxDecoration get _decoration => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.45),
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
            decoration: _decoration,
            child: SizedBox(
              height: Dimensions.itemHeight88,
              child: Stack(
                clipBehavior: Clip.hardEdge,
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
              color: AppColors.of(context).onPrimary.withValues(alpha: 0.70),
            ),
          ],
        ),
      );
}
