import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
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
    final AppColors colors = AppColors.of(context);
    final bool isAzDe = appState.dictionaryType == DictionaryType.azDe;

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(
            left: showBackButton ? 0 : Dimensions.padding20),
        child: Text(
          showBackButton ? (title ?? '') : 'Dil Duel',
          style: AppTextStyles.titleLarge(colors.textPrimary),
        ),
      ),
      actions: showProfileButton
          ? <Widget>[
              GestureDetector(
                onTap: () => context.read<AppCubit>().toggleDictionaryType(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(
                        Dimensions.borderRadiusPill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.padding12,
                      vertical: Dimensions.padding8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          isAzDe ? 'Az' : 'De',
                          style: AppTextStyles.labelMedium(colors.primary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.itemWidth6,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: Dimensions.itemWidth14,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          isAzDe ? 'De' : 'Az',
                          style:
                              AppTextStyles.labelMedium(colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: SizedBox(
                  width: Dimensions.itemWidth34,
                  height: Dimensions.itemHeight34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      size: Dimensions.itemWidth16,
                      color: colors.textSecondary,
                    ),
                  ),
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
