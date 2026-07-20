import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/theme_cubit.dart';
import 'package:flutter_dic/core/state/theme_state.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/features/home/home.dart';
import 'package:flutter_dic/features/settings/settings.dart';
import 'package:flutter_dic/features/bookmarks/bookmarks.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:injectable/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  await configureDependencies(env: Environment.prod);
  await DBHelper.initDB();
  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[
        Locale('az'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('az'),
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AppCubit>(
            create: (BuildContext context) => sl<AppCubit>(),
          ),
          BlocProvider<ThemeCubit>(
            create: (BuildContext context) => sl<ThemeCubit>(),
          ),
          BlocProvider<BookmarksBloc>(
            create: (BuildContext context) => sl<BookmarksBloc>(),
          ),
          BlocProvider<QuizBloc>(
            create: (BuildContext context) => sl<QuizBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeCubit themeCubit = context.watch<ThemeCubit>();

    return MaterialApp(
      title: 'app.title'.tr(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeCubit.currentTheme),
      home: const HomeShell(),
      routes: <String, WidgetBuilder>{
        '/settings': (BuildContext context) => const SettingsScreen(),
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }

  ThemeMode _getThemeMode(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }
}
