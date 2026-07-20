import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';

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
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

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
        padding: EdgeInsets.only(left: showBackButton ? 0 : 20),
        child: Text(
          showBackButton ? (title ?? '') : 'Dil Duel',
          style: AppTheme.titleLarge(textPrimary),
        ),
      ),
      actions: showProfileButton
          ? <Widget>[
              // Direction switcher pill
              GestureDetector(
                onTap: () => context.read<AppCubit>().toggleDictionaryType(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Az',
                        style: AppTheme.bodyMedium(
                          isAzDe ? textPrimary : textSecondary,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.compare_arrows, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        'De',
                        style: AppTheme.bodyMedium(
                          isAzDe ? textSecondary : textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Settings icon button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: border),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.settings_outlined,
                      size: 16, color: textSecondary),
                ),
              ),
              const SizedBox(width: 20),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
