import 'package:flutter/material.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A scrollable vertical list of [AppFilledCard]s with the shared screen
/// padding and card spacing.
class AppFilledCardList extends StatelessWidget {
  const AppFilledCardList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.padding16,
          Dimensions.padding8,
          Dimensions.padding16,
          Dimensions.padding16,
        ),
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: Dimensions.padding12),
            children[i],
          ],
        ],
      );
}
