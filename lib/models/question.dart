import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    final questionText = unescape.convert(json['question']);
    final correct = unescape.convert(json['correct_answer']);
    final incorrect = (json['incorrect_answers'] as List<dynamic>)
        .map((e) => unescape.convert(e))
        .toList();

    final options = List<String>.from(incorrect)..add(correct);
    options.shuffle();

    return Question(
      question: questionText,
      options: options,
      correctAnswer: correct,
    );
  }
}
