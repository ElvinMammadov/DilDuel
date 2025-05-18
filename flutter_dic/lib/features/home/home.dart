import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_dic/features/widgets/app_bar.dart';
import 'package:flutter_dic/features/search/search.dart';
import 'package:flutter_dic/features/quiz/quiz.dart';
import 'package:flutter_dic/features/training/training.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  
  // Pre-instantiate all pages
  final List<Widget> _pages = const <Widget>[
    SearchScreen(),
    QuizScreen(),
    TrainingScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) => BlocProvider<QuizBloc>(
    create: (BuildContext context) => sl<QuizBloc>(),
    child: Scaffold(
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
    ),
  );
} 