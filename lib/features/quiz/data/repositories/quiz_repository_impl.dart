import 'package:dartz/dartz.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/features/quiz/domain/entities/quiz_word.dart';
import 'package:flutter_dic/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';
import 'dart:math';

/// Implementation of [QuizRepository] that fetches words from local database
/// and transforms them into quiz questions.
@LazySingleton(as: QuizRepository)
class QuizRepositoryImpl implements QuizRepository {
  /// Data source for accessing word database
  final WordLocalDataSource localDataSource;

  /// Random number generator for shuffling words and answers
  final Random _random = Random();

  /// Creates a new instance of [QuizRepositoryImpl].
  ///
  /// Requires [localDataSource] for accessing the word database.
  QuizRepositoryImpl({required this.localDataSource});

  /// Checks if a string is valid (not null, not empty after trimming)
  bool _isValidString(String? str) => str != null && str.trim().isNotEmpty;

  /// Checks if a word is valid (both key and value are valid strings)
  bool _isValidWord(Word word) =>
      _isValidString(word.key) && _isValidString(word.value);

  @override
  Future<Either<Failure, List<QuizWord>>> getQuizWords(String dicType) async {
    try {
      // Fetch all words for the given dictionary type
      final List<Word> allWords =
          await localDataSource.searchWords('', dicType);

      // Filter out invalid words (empty or whitespace-only questions/answers)
      final List<Word> validWords = allWords.where(_isValidWord).toList();

      // Check if we have enough valid words for the quiz
      if (validWords.length < 4) {
        return Left<Failure, List<QuizWord>>(CacheFailure());
      }

      // Shuffle the valid words and take first 10 for the quiz
      validWords.shuffle(_random);
      final List<QuizWord> quizWords = <QuizWord>[];
      final List<Word> wordsForQuiz = validWords.take(10).toList();

      for (final Word word in wordsForQuiz) {
        // Get potential wrong answers (excluding the correct answer)
        final List<String> potentialWrongAnswers = validWords
            .where((Word w) =>
                    w.value != word.value && // Different from correct answer
                    _isValidString(w.value) // Ensure answer is valid
                )
            .map((Word w) => w.value)
            .toList();

        // If we can't get enough wrong answers, skip this word
        if (potentialWrongAnswers.length < 3) {
          continue;
        }

        // Shuffle and take 3 wrong answers
        potentialWrongAnswers.shuffle(_random);
        final List<String> wrongAnswers =
            potentialWrongAnswers.take(3).toList();

        // Combine correct answer with wrong answers and shuffle
        final List<String> options = <String>[word.value, ...wrongAnswers]
          ..shuffle(_random);

        quizWords.add(QuizWord(
          question: word.key,
          correctAnswer: word.value,
          options: options,
          dicType: dicType,
        ));
      }

      // Check if we have enough valid quiz words
      if (quizWords.length < 4) {
        return Left<Failure, List<QuizWord>>(CacheFailure());
      }

      return Right<Failure, List<QuizWord>>(quizWords);
    } catch (e) {
      return Left<Failure, List<QuizWord>>(CacheFailure());
    }
  }
}
