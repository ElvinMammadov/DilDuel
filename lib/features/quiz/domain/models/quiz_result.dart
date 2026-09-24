import 'package:flutter_dic/core/data/models/answer_record.dart';

class QuizResult {
  final int? id;
  final int score;
  final int totalQuestions;
  final DateTime dateTime;
  final List<AnswerRecord> answers;

  QuizResult({
    this.id,
    required this.score,
    required this.totalQuestions,
    required this.dateTime,
    List<AnswerRecord>? answers,
  }) : answers = answers ?? const <AnswerRecord>[];

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'score': score,
        'totalQuestions': totalQuestions,
        'dateTime': dateTime.toIso8601String(),
      };

  factory QuizResult.fromMap(
    Map<String, dynamic> map, {
    List<AnswerRecord> answers = const <AnswerRecord>[],
  }) =>
      QuizResult(
        id: map['id'] as int?,
        score: map['score'] as int,
        totalQuestions: map['totalQuestions'] as int,
        dateTime: DateTime.parse(map['dateTime'] as String),
        answers: answers,
      );
}
