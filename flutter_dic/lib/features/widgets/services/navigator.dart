import 'package:flutter_dic/features/home/home_page.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:flutter_dic/features/search/search.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter router = GoRouter(
  initialLocation: '/dictionary',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          HomeShell(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/dictionary',
          name: 'dictionary',
          builder: (BuildContext context, GoRouterState state) =>
              const SearchScreen(),
        ),
        GoRoute(
          path: '/quiz',
          name: 'quiz',
          builder: (BuildContext context, GoRouterState state) =>
              const QuizScreen(),
        ),
        GoRoute(
          path: '/training',
          name: 'training',
          builder: (BuildContext context, GoRouterState state) =>
              const TrainingScreen(),
        ),
      ],
    ),
  ],
);
