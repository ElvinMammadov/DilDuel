import 'package:flutter/material.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A fully rounded label background that wraps [child] with [padding].
///
/// Used for badges, chips and counters. Set [borderColor] for an outlined
/// pill.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.child,
    required this.color,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Dimensions.padding10,
      vertical: Dimensions.padding4,
    ),
  });

  final Widget child;
  final Color color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
      border: borderColor == null ? null : Border.all(color: borderColor!),
    ),
    child: Padding(padding: padding, child: child),
  );
}
