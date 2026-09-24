part of listening;

class ListeningInitialView extends StatelessWidget {
  final VoidCallback onStart;

  const ListeningInitialView({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) => Center(
        child: AppElevatedButton(
          text: 'listening.start'.tr(),
          onPressed: onStart,
        ),
      );
}
