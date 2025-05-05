import 'package:dartz/dartz.dart';

import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/features/search/data/repositories/word_repository.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchWord {
  final WordRepository repository;

  SearchWord(this.repository);

  Future<Either<Failure, List<Word>>> call(
    String query,
    String dicType,
  ) async =>
      await repository.search(query, dicType);
}
