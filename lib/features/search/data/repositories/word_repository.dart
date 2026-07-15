import 'package:dartz/dartz.dart';

import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/core/error/failures.dart';

abstract class WordRepository {
  Future<Either<Failure, List<Word>>> search(String key, String dicType);
}