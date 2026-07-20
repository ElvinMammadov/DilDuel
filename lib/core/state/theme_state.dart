import 'package:equatable/equatable.dart';

enum ThemeType { light, dark, system }

class ThemeState extends Equatable {
  final ThemeType themeType;

  const ThemeState({
    required this.themeType,
  });

  ThemeState copyWith({
    ThemeType? themeType,
  }) =>
      ThemeState(
        themeType: themeType ?? this.themeType,
      );

  @override
  List<Object?> get props => <Object?>[themeType];
}
