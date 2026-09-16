import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
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
    TrainingScreen(),
    QuizScreen(),
    BookmarksScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Refresh bookmarks when switching to the Bookmarks tab
    if (index == 3) {
      context.read<BookmarksBloc>().loadBookmarks();
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DilDuelAppBar(
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
    final AppColors colors = AppColors.of(context);
    final Color primary = colors.primary;
    final Color primaryTint = colors.primaryTint;
    final Color textSecondary = colors.textSecondary;
    final Color surface = colors.surface;
    final Color border = colors.border;

    final List<({IconData icon, String label})> items =
        <({IconData icon, String label})>[
      (icon: Icons.search, label: 'app.search'.tr()),
      (icon: Icons.draw_outlined, label: 'app.training'.tr()),
      (icon: Icons.school_outlined, label: 'app.quiz'.tr()),
      (icon: Icons.favorite_border, label: 'app.bookmarks'.tr()),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.only(
        top: Dimensions.padding8,
        bottom: Dimensions.padding20,
        left: Dimensions.padding6,
        right: Dimensions.padding6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(items.length, (int i) {
          final bool active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding14,
                vertical: Dimensions.padding6,
              ),
              decoration: BoxDecoration(
                color: active ? primaryTint : Colors.transparent,
                borderRadius: BorderRadius.circular(Dimensions.padding16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    active ? _filledIcon(items[i].icon) : items[i].icon,
                    size: Dimensions.itemHeight20,
                    color: active ? primary : textSecondary,
                  ),
                  const SizedBox(height: Dimensions.padding3),
                  Text(
                    items[i].label,
                    style: AppTextStyles.labelSmall(
                        active ? primary : textSecondary),
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
      Icons.search: Icons.search,
      Icons.favorite_border: Icons.favorite,
      Icons.school_outlined: Icons.school,
      Icons.draw_outlined: Icons.draw,
    };
    return map[outline] ?? outline;
  }
}
