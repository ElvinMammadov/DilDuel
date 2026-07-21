import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class DilDuelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool showProfileButton;

  const DilDuelAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.showBackButton = true,
    this.showProfileButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppCubit>().state;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAzDe = appState.dictionaryType == DictionaryType.azDe;
    final Color primary =
        isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textPrimary),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(
            left: showBackButton ? 0 : Dimensions.padding20),
        child: Text(
          showBackButton ? (title ?? '') : 'Dil Duel',
          style: AppTextStyles.titleLarge(textPrimary),
        ),
      ),
      actions: showProfileButton
          ? <Widget>[
              // Direction switcher pill
              GestureDetector(
                onTap: () =>
                    context.read<AppCubit>().toggleDictionaryType(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.padding12,
                      vertical: Dimensions.padding8),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(
                        Dimensions.borderRadiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Az',
                        style: AppTextStyles.labelMedium(
                          isAzDe ? textPrimary : textSecondary,
                        ),
                      ),
                      const SizedBox(width: Dimensions.itemWidth6),
                      Icon(Icons.compare_arrows,
                          size: Dimensions.itemWidth16, color: primary),
                      const SizedBox(width: Dimensions.itemWidth6),
                      Text(
                        'De',
                        style: AppTextStyles.labelMedium(
                          isAzDe ? textSecondary : textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth8),
              // Settings icon button
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/settings'),
                child: Container(
                  width: Dimensions.itemWidth34,
                  height: Dimensions.itemHeight34,
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.settings_outlined,
                      size: Dimensions.itemWidth16,
                      color: textSecondary),
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth20),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
