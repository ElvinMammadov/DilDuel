/// A record of a single answered question in a quiz or listening test.
class AnswerRecord {
  final String question;
  final String correctAnswer;
  final String givenAnswer;
  final bool isCorrect;

  const AnswerRecord({
    required this.question,
    required this.correctAnswer,
    required this.givenAnswer,
    required this.isCorrect,
  });

  factory AnswerRecord.fromMap(Map<String, dynamic> map) => AnswerRecord(
        question: map['question'] as String,
        correctAnswer: map['correct_answer'] as String,
        givenAnswer: map['given_answer'] as String,
        isCorrect: (map['is_correct'] as int) == 1,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'question': question,
        'correctAnswer': correctAnswer,
        'givenAnswer': givenAnswer,
        'isCorrect': isCorrect,
      };

  factory AnswerRecord.fromJson(Map<String, dynamic> json) => AnswerRecord(
        question: json['question'] as String,
        correctAnswer: json['correctAnswer'] as String,
        givenAnswer: json['givenAnswer'] as String,
        isCorrect: json['isCorrect'] as bool,
      );
}
