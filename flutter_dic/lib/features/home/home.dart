library home;

import 'package:flutter/material.dart';
import 'package:flutter_dic/features/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  static const List<String> tabs = <String>[
    '/dictionary',
    '/quiz',
    '/training',
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex =
        tabs.indexWhere((String tab) => location.startsWith(tab));

    return Scaffold(
      appBar: const DilDuelAppBar(
        title: 'Dil Duel',
        showBackButton: false,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (int index) => context.go(tabs[index]),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Training',
          ),
        ],
      ),
    );
  }
} 