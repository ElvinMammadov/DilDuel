import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
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
    bottomNavigationBar: _DesignedNavBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
    ),
  );
}

class _DesignedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DesignedNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint = isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    final List<({IconData icon, String label})> items = <({IconData icon, String label})>[
      (icon: Icons.menu_book_outlined, label: 'app.search'.tr()),
      (icon: Icons.bookmark_outline, label: 'app.bookmarks'.tr()),
      (icon: Icons.quiz_outlined, label: 'app.quiz'.tr()),
      (icon: Icons.fitness_center_outlined, label: 'app.training'.tr()),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 6,
        right: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final bool active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? primaryTint : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    active ? _filledIcon(items[i].icon) : items[i].icon,
                    size: 20,
                    color: active ? primary : textSecondary,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].label,
                    style: AppTheme.labelSmall(active ? primary : textSecondary)
                        .copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _filledIcon(IconData outline) {
    final Map<IconData, IconData> map = <IconData, IconData>{
      Icons.menu_book_outlined: Icons.menu_book,
      Icons.bookmark_outline: Icons.bookmark,
      Icons.quiz_outlined: Icons.quiz,
      Icons.fitness_center_outlined: Icons.fitness_center,
    };
    return map[outline] ?? outline;
  }
}