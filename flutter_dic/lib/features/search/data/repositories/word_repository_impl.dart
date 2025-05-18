import 'package:dartz/dartz.dart';
import 'package:flutter_dic/features/search/data/repositories/word_repository.dart';

import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/core/error/exceptions.dart';
import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WordRepository)
class WordRepositoryImpl implements WordRepository {
  final WordLocalDataSource localDataSource;

  WordRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Word>>> search(
      String query, String dicType) async {
    try {
      final List<Word> word = await localDataSource.searchWords(query, dicType);
      return Right<Failure, List<Word>>(word);
    } on CacheException {
      return Left<Failure, List<Word>>(CacheFailure());
    }
  }
}
