import 'package:bloc/bloc.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppCubit extends Cubit<AppState> {
  // Default to AzDe (123)
  AppCubit() : super(const AppState(dictionaryType: 123));


  void setDictionaryType(int newType) {
    emit(state.copyWith(dictionaryType: newType));
  }

  // Get the dictionary name based on the integer value
  String getDictionaryName() {
    switch (state.dictionaryType) {
      case 123:
        return "AzDe";
      case 321:
        return "DeAz";
      default:
        return "Unknown";
    }
  }
}