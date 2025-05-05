import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  final int dictionaryType;

  const AppState({required this.dictionaryType});

  @override
  List<Object> get props => <Object>[dictionaryType];

  AppState copyWith({
    int? dictionaryType,
  }) => AppState(
      dictionaryType: dictionaryType ?? this.dictionaryType,
    );
}
