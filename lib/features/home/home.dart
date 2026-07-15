import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/features/widgets/app_bar.dart';
import 'package:flutter_dic/features/search/search.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:flutter_dic/features/bookmarks/bookmarks.dart';
import 'package:easy_localization/easy_localization.dart';

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
    appBar:  DilDuelAppBar(
      title: 'app.title'.tr(),
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
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: 'app.search'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bookmark),
          label: 'app.bookmarks'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz),
          label: 'app.quiz'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.fitness_center),
          label: 'app.training'.tr(),
        ),
      ],
    ),
  );
} 