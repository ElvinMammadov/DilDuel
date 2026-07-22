import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppCubit extends Cubit<AppState> {
  // Default to DeAz (German → Azerbaijani)
  AppCubit() : super(const AppState(dictionaryType: DictionaryType.deAz));

  void setDictionaryType(DictionaryType newType) {
    emit(
      state.copyWith(dictionaryType: newType),
    );
  }

  void toggleDictionaryType() {
    final DictionaryType newType = state.dictionaryType == DictionaryType.azDe
        ? DictionaryType.deAz
        : DictionaryType.azDe;
    emit(
      state.copyWith(dictionaryType: newType),
    );
  }

  // Get the dictionary name
  String getDictionaryName() => state.dictionaryType.name;

  // Get the dictionary value for database operations
  int getDictionaryValue() => state.dictionaryType.value;
}
