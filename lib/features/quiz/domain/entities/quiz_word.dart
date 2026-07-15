import 'package:equatable/equatable.dart';

/// Represents a single quiz question with multiple choice options.
class QuizWord extends Equatable {
  /// The word or phrase to be translated (the question)
  final String question;

  /// The correct translation of the word
  final String correctAnswer;

  /// List of possible answers including the correct one
  final List<String> options;

  /// The dictionary type this word belongs to (e.g., 'AzDe' or 'DeAz')
  final String dicType;

  /// Creates a new [QuizWord] instance.
  ///
  /// All parameters are required:
  /// - [question]: The word to be translated
  /// - [correctAnswer]: The correct translation
  /// - [options]: List of 4 options including the correct answer
  /// - [dicType]: The dictionary type identifier
  const QuizWord({
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.dicType,
  });

  @override
  List<Object?> get props => <Object?>[
        question,
        correctAnswer,
        options,
        dicType,
      ];
}
