import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:flutter_dic/features/settings/settings.dart';

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
    final bool isAzDe = appState.dictionaryType == 123;
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
                padding: const EdgeInsets.only(right: 8.0),
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        context.read<AppCubit>().setDictionaryType(
                              appState.dictionaryType == 123 ? 321 : 123,
                            );
                      },
                      child: Row(
                        children: <Widget>[
                          Text(fromLang),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.compare_arrows,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            toLang,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
