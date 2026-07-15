import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final String key;
  final String value;
  final String dicType;

  const Word({
    this.key = '',
    this.value = '',
    this.dicType = '',
  });

  @override
  List<Object?> get props => <Object?>[key, value, dicType];
}