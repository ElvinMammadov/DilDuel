import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

/// A full-width segmented control that syncs with a [DefaultTabController].
///
/// Must be placed inside a widget tree that contains a [DefaultTabController].
class AppSegmentedControl extends StatefulWidget {
  final List<String> labels;

  const AppSegmentedControl({super.key, required this.labels});

  @override
  State<AppSegmentedControl> createState() => _AppSegmentedControlState();
}

class _AppSegmentedControlState extends State<AppSegmentedControl> {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController?.removeListener(_onTabChanged);
    _tabController = DefaultTabController.of(context);
    _tabController?.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final int selected = _tabController?.index ?? 0;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color trackBg =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color thumb = isDark ? AppTheme.borderDark : AppTheme.chipBgLight;
    final Color activeText =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    const double inset = Dimensions.padding4;
    const Duration dur = Duration(milliseconds: 200);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding16,
        vertical: Dimensions.padding8,
      ),
      child: Container(
        padding: const EdgeInsets.all(inset),
        decoration: BoxDecoration(
          color: trackBg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          border: Border.all(color: border),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double thumbW =
                constraints.maxWidth / widget.labels.length;
            return SizedBox(
              height: Dimensions.itemHeight40,
              child: Stack(
                children: <Widget>[
                  // Sliding thumb — only this element animates.
                  AnimatedPositioned(
                    duration: dur,
                    curve: Curves.easeInOut,
                    left: selected * thumbW,
                    top: 0,
                    bottom: 0,
                    width: thumbW,
                    child: Container(
                      decoration: BoxDecoration(
                        color: thumb,
                        borderRadius: BorderRadius.circular(
                          Dimensions.borderRadius - 2,
                        ),
                        boxShadow: isDark
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : <BoxShadow>[
                                const BoxShadow(
                                  color: Color(0x28000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                                const BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                      ),
                    ),
                  ),
                  // Labels — static, no animation.
                  Row(
                    children: List<Widget>.generate(
                      widget.labels.length,
                      (int i) => Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController?.animateTo(i),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              widget.labels[i],
                              style: AppTextStyles.titleSmall(
                                i == selected ? activeText : textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

