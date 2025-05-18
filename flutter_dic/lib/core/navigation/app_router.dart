import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_dic/features/home/home.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:flutter_dic/features/search/search.dart';
import 'package:flutter_dic/features/settings/settings.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:go_router/go_router.dart';

/// Application routing configuration
class AppRouter {
  AppRouter._();

  /// Route names
  static const String home = '/';
  static const String quiz = '/quiz';
  static const String settings = '/settings';
  static const String dictionary = '/dictionary';
  static const String training = '/training';

  /// Router configuration
  static final GoRouter router = GoRouter(
    initialLocation: dictionary,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            BlocProvider<QuizBloc>(
              create: (BuildContext context) => sl<QuizBloc>(),
              child: HomeShell(child: child),
            ),
        routes: <RouteBase>[
          GoRoute(
            path: dictionary,
            builder: (BuildContext context, GoRouterState state) =>
                const SearchScreen(),
          ),
          GoRoute(
            path: quiz,
            builder: (BuildContext context, GoRouterState state) =>
                const QuizScreen(),
          ),
          GoRoute(
            path: training,
            builder: (BuildContext context, GoRouterState state) =>
                const TrainingScreen(),
          ),
        ],
      ),
      GoRoute(
        path: settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
} 