import 'package:dartz/dartz.dart';
import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/features/quiz/domain/entities/quiz_word.dart';

/// Repository interface for quiz-related operations.
abstract class QuizRepository {
  /// Fetches a list of quiz words for the given dictionary type.
  ///
  /// [dicType] specifies the dictionary type (e.g., 'AzDe' or 'DeAz').
  ///
  /// Returns:
  /// - A [Right] containing a list of [QuizWord]s if successful
  /// - A [Left] containing a [Failure] if an error occurs
  ///
  /// The returned list typically contains 10 quiz words, each with:
  /// - One correct answer
  /// - Three wrong answers
  /// - All answers shuffled randomly
  Future<Either<Failure, List<QuizWord>>> getQuizWords(String dicType);
}
