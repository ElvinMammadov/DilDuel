// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/quiz/data/repositories/quiz_repository_impl.dart'
    as _i656;
import '../../features/quiz/domain/repositories/quiz_repository.dart' as _i613;
import '../../features/quiz/quiz.dart' as _i381;
import '../../features/search/data/repositories/word_repository.dart' as _i6;
import '../../features/search/data/repositories/word_repository_impl.dart'
    as _i11;
import '../../features/search/domain/usecases/search_word.dart' as _i1023;
import '../../features/search/search.dart' as _i725;
import '../data/data_sources/local/word_local_data_source.dart' as _i94;
import '../data/data_sources/local/word_local_data_source_impl.dart' as _i816;
import '../state/app_cubit.dart' as _i901;
import '../state/theme_cubit.dart' as _i655;
import 'shared_preferences_module.dart' as _i110;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final sharedPreferencesModule = _$SharedPreferencesModule();
    gh.factory<_i901.AppCubit>(() => _i901.AppCubit());
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i655.ThemeCubit>(
        () => _i655.ThemeCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i94.WordLocalDataSource>(() => _i816.DBHelper());
    gh.lazySingleton<_i613.QuizRepository>(() => _i656.QuizRepositoryImpl(
        localDataSource: gh<_i94.WordLocalDataSource>()));
    gh.lazySingleton<_i6.WordRepository>(() => _i11.WordRepositoryImpl(
        localDataSource: gh<_i94.WordLocalDataSource>()));
    gh.factory<_i1023.SearchWord>(
        () => _i1023.SearchWord(gh<_i6.WordRepository>()));
    gh.factory<_i381.QuizBloc>(
        () => _i381.QuizBloc(repository: gh<_i613.QuizRepository>()));
    gh.factory<_i725.SearchBloc>(
        () => _i725.SearchBloc(searchWord: gh<_i1023.SearchWord>()));
    return this;
  }
}

class _$SharedPreferencesModule extends _i110.SharedPreferencesModule {}
