import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/features/widgets/app_bar.dart';
import 'package:flutter_dic/features/search/search.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:flutter_dic/features/bookmarks/bookmarks.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const <Widget>[
    SearchScreen(),
    BookmarksScreen(),
    QuizScreen(),
    TrainingScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Refresh bookmarks when switching to the Bookmarks tab
    if (index == 1) {
      context.read<BookmarksBloc>().loadBookmarks();
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const DilDuelAppBar(
      title: 'Dil Duel',
      showBackButton: false,
    ),
    body: IndexedStack(
      index: _currentIndex,
      children: _pages,
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Dictionary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Bookmarks',
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