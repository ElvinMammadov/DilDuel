import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
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
    final bool isAzDe = appState.dictionaryType == DictionaryType.azDe;
    final String fromLang = isAzDe ? 'Az' : 'De';
    final String toLang = isAzDe ? 'De' : 'Az';
    return AppBar(
      title: Text(title ?? ''),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.pop(context);
                }
              },
            )
          : null,
      actions: <Widget>[
        if (showProfileButton)
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: Dimensions.padding8),
                child: Card(
                  elevation: Dimensions.itemHeight1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.itemHeight8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.padding8,
                      vertical: Dimensions.padding4,
                    ),
                    child: InkWell(
                      onTap: () {
                        context.read<AppCubit>().toggleDictionaryType();
                      },
                      child: Row(
                        children: <Widget>[
                          Text(fromLang),
                          const SizedBox(width: Dimensions.itemWidth4),
                          Icon(
                            Icons.compare_arrows,
                            size: Dimensions.itemHeight24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: Dimensions.itemWidth4),
                          Text(toLang),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
