class QuizResult {
  final int? id;
  final int score;
  final int totalQuestions;
  final DateTime dateTime;

  QuizResult({
    this.id,
    required this.score,
    required this.totalQuestions,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'score': score,
      'totalQuestions': totalQuestions,
      'dateTime': dateTime.toIso8601String(),
    };

  factory QuizResult.fromMap(Map<String, dynamic> map) => QuizResult(
      id: map['id'] as int?,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
} 