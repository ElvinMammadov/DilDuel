part of '../settings.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          final ThemeCubit themeCubit = context.read<ThemeCubit>();

          return Padding(
            padding: const EdgeInsets.all(Dimensions.padding16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.brightness_5,
                    color: AppTheme.mainColor,
                  ),
                  title: const Text('Light'),
                  trailing: state.themeType == ThemeType.light
                      ? const Icon(Icons.check, color: AppTheme.mainColor)
                      : null,
                  onTap: () {
                    themeCubit.setTheme(ThemeType.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.brightness_2,
                    color: AppTheme.mainColor,
                  ),
                  title: const Text('Dark'),
                  trailing: state.themeType == ThemeType.dark
                      ? const Icon(Icons.check, color: AppTheme.mainColor)
                      : null,
                  onTap: () {
                    themeCubit.setTheme(ThemeType.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.brightness_auto,
                    color: AppTheme.mainColor,
                  ),
                  title: const Text('System'),
                  trailing: state.themeType == ThemeType.system
                      ? const Icon(Icons.check, color: AppTheme.mainColor)
                      : null,
                  onTap: () {
                    themeCubit.setTheme(ThemeType.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
}
