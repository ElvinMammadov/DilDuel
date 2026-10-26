import 'package:flutter_dic/features/search/domain/entities/word.dart';

final RegExp _leadingArticle = RegExp(r'^(der|die|das) ');

/// Returns [word]'s key without its leading article ("das Haus" → "Haus").
///
/// Words loaded from bookmarks have no `article` field, so a German key
/// falls back to stripping a leading der/die/das.
String bareWord(Word word) {
  final String key = word.key;
  final String? article = word.article;
  if (article != null && article.isNotEmpty) {
    final String prefix = '$article ';
    return key.startsWith(prefix) ? key.substring(prefix.length) : key;
  }
  return word.dicType == 'DeAz' ? key.replaceFirst(_leadingArticle, '') : key;
}
