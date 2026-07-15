import 'package:equatable/equatable.dart';

enum DictionaryType {
  azDe(123, 'AzDe'),
  deAz(321, 'DeAz');

  final int value;
  final String name;

  const DictionaryType(this.value, this.name);

  static DictionaryType fromValue(int value) =>
      DictionaryType.values.firstWhere(
        (DictionaryType type) => type.value == value,
        orElse: () => DictionaryType.azDe,
      );
}

class AppState extends Equatable {
  final DictionaryType dictionaryType;

  const AppState({required this.dictionaryType});

  @override
  List<Object> get props => <Object>[dictionaryType];

  AppState copyWith({
    DictionaryType? dictionaryType,
  }) =>
      AppState(
        dictionaryType: dictionaryType ?? this.dictionaryType,
      );
}
