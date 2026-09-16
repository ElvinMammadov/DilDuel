part of '../settings.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          final ThemeCubit themeCubit = context.read<ThemeCubit>();
          final Color primary = AppColors.of(context).primary;

          return Padding(
            padding: const EdgeInsets.all(Dimensions.padding16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.brightness_5, color: primary),
                  title: const Text('Light'),
                  trailing: state.themeType == ThemeType.light
                      ? Icon(Icons.check, color: primary)
                      : null,
                  onTap: () {
                    themeCubit.setTheme(ThemeType.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.brightness_2, color: primary),
                  title: const Text('Dark'),
                  trailing: state.themeType == ThemeType.dark
                      ? Icon(Icons.check, color: primary)
                      : null,
                  onTap: () {
                    themeCubit.setTheme(ThemeType.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.brightness_auto, color: primary),
                  title: const Text('System'),
                  trailing: state.themeType == ThemeType.system
                      ? Icon(Icons.check, color: primary)
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
