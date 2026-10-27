import 'package:flutter/material.dart';

/// A centred progress spinner that fills the space it is given.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
