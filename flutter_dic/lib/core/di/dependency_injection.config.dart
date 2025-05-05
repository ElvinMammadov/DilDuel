// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart'
    as _i868;
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart'
    as _i550;
import 'package:flutter_dic/features/search/data/repositories/word_repository.dart'
    as _i706;
import 'package:flutter_dic/features/search/data/repositories/word_repository_impl.dart'
    as _i894;
import 'package:flutter_dic/features/search/domain/usecases/search_word.dart'
    as _i327;
import 'package:flutter_dic/features/search/search.dart' as _i53;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i868.WordLocalDataSource>(() => _i550.DBHelper());
    gh.lazySingleton<_i706.WordRepository>(() => _i894.WordRepositoryImpl(
        localDataSource: gh<_i868.WordLocalDataSource>()));
    gh.factory<_i327.SearchWord>(
        () => _i327.SearchWord(gh<_i706.WordRepository>()));
    gh.factory<_i53.SearchBloc>(
        () => _i53.SearchBloc(searchWord: gh<_i327.SearchWord>()));
    return this;
  }
}
