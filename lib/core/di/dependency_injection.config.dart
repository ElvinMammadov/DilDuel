// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/auth.dart' as _i430;
import '../../features/bookmarks/bookmarks.dart' as _i1027;
import '../../features/quiz/data/repositories/quiz_repository_impl.dart'
    as _i656;
import '../../features/quiz/domain/repositories/quiz_repository.dart' as _i613;
import '../../features/quiz/quiz.dart' as _i381;
import '../../features/search/data/repositories/word_repository.dart' as _i6;
import '../../features/search/data/repositories/word_repository_impl.dart'
    as _i11;
import '../../features/search/domain/usecases/search_word.dart' as _i1023;
import '../../features/search/search.dart' as _i725;
import '../../features/training/training.dart' as _i406;
import '../data/data_sources/local/word_local_data_source.dart' as _i94;
import '../data/data_sources/local/word_local_data_source_impl.dart' as _i816;
import '../data/repositories/bookmark_repository.dart' as _i807;
import '../data/repositories/local/local_bookmark_repository.dart' as _i817;
import '../data/repositories/local/local_quiz_result_repository.dart' as _i36;
import '../data/repositories/local/local_training_progress_repository.dart'
    as _i45;
import '../data/repositories/quiz_result_repository.dart' as _i662;
import '../data/repositories/remote/firestore_bookmark_repository.dart'
    as _i957;
import '../data/repositories/remote/firestore_quiz_result_repository.dart'
    as _i843;
import '../data/repositories/remote/firestore_training_progress_repository.dart'
    as _i63;
import '../data/repositories/sync_bookmark_repository.dart' as _i709;
import '../data/repositories/sync_quiz_result_repository.dart' as _i551;
import '../data/repositories/sync_training_progress_repository.dart' as _i311;
import '../data/repositories/training_progress_repository.dart' as _i871;
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
    gh.lazySingleton<_i817.LocalBookmarkRepository>(
        () => _i817.LocalBookmarkRepository());
    gh.lazySingleton<_i36.LocalQuizResultRepository>(
        () => _i36.LocalQuizResultRepository());
    gh.lazySingleton<_i45.LocalTrainingProgressRepository>(
        () => _i45.LocalTrainingProgressRepository());
    gh.lazySingleton<_i430.AuthRepository>(
        () => _i430.FirebaseAuthRepository());
    gh.lazySingleton<_i94.WordLocalDataSource>(() => _i816.DBHelper());
    gh.lazySingleton<_i613.QuizRepository>(() => _i656.QuizRepositoryImpl(
        localDataSource: gh<_i94.WordLocalDataSource>()));
    gh.singleton<_i655.ThemeCubit>(
        () => _i655.ThemeCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i957.FirestoreBookmarkRepository>(
        () => _i957.FirestoreBookmarkRepository(gh<_i430.AuthRepository>()));
    gh.lazySingleton<_i843.FirestoreQuizResultRepository>(
        () => _i843.FirestoreQuizResultRepository(gh<_i430.AuthRepository>()));
    gh.lazySingleton<_i63.FirestoreTrainingProgressRepository>(() =>
        _i63.FirestoreTrainingProgressRepository(gh<_i430.AuthRepository>()));
    gh.lazySingleton<_i430.AuthCubit>(
        () => _i430.AuthCubit(gh<_i430.AuthRepository>()));
    gh.lazySingleton<_i871.TrainingProgressRepository>(
        () => _i311.SyncTrainingProgressRepository(
              gh<_i45.LocalTrainingProgressRepository>(),
              gh<_i63.FirestoreTrainingProgressRepository>(),
              gh<_i430.AuthRepository>(),
            ));
    gh.factory<_i406.TrainingCubit>(
        () => _i406.TrainingCubit(gh<_i871.TrainingProgressRepository>()));
    gh.lazySingleton<_i662.QuizResultRepository>(
        () => _i551.SyncQuizResultRepository(
              gh<_i36.LocalQuizResultRepository>(),
              gh<_i843.FirestoreQuizResultRepository>(),
              gh<_i430.AuthRepository>(),
            ));
    gh.factory<_i381.QuizBloc>(() => _i381.QuizBloc(
          repository: gh<_i613.QuizRepository>(),
          quizResultRepository: gh<_i662.QuizResultRepository>(),
        ));
    gh.lazySingleton<_i6.WordRepository>(() => _i11.WordRepositoryImpl(
        localDataSource: gh<_i94.WordLocalDataSource>()));
    gh.factory<_i1023.SearchWord>(
        () => _i1023.SearchWord(gh<_i6.WordRepository>()));
    gh.factory<_i725.SearchBloc>(
        () => _i725.SearchBloc(searchWord: gh<_i1023.SearchWord>()));
    gh.lazySingleton<_i807.BookmarkRepository>(
        () => _i709.SyncBookmarkRepository(
              gh<_i817.LocalBookmarkRepository>(),
              gh<_i957.FirestoreBookmarkRepository>(),
              gh<_i430.AuthRepository>(),
            ));
    gh.factory<_i1027.BookmarksBloc>(
        () => _i1027.BookmarksBloc(gh<_i807.BookmarkRepository>()));
    return this;
  }
}

class _$SharedPreferencesModule extends _i110.SharedPreferencesModule {}
