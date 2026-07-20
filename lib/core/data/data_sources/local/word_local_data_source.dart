import 'package:flutter_dic/features/search/domain/entities/word.dart';

abstract class WordLocalDataSource {
  Future<List<Word>> searchWords(String key, String dicType);
}
