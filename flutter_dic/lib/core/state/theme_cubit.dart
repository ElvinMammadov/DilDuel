import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dic/core/state/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
      : super(
          ThemeState(
            themeType: _loadInitialTheme(_prefs),
          ),
        );

  static ThemeType _loadInitialTheme(SharedPreferences prefs) {
    final String? savedTheme = prefs.getString(_themeKey);
    return ThemeType.values.firstWhere(
      (ThemeType type) => type.name == savedTheme,
      orElse: () => ThemeType.system,
    );
  }

  Future<void> setTheme(ThemeType themeType) async {
    await _prefs.setString(_themeKey, themeType.name);
    emit(state.copyWith(themeType: themeType));
  }

  ThemeType get currentTheme => state.themeType;
}
