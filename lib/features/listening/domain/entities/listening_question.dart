part of listening;

class ListeningQuestion {
  final Word word;
  final String correctAnswer;
  final List<String> options;

  const ListeningQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
  });
}
