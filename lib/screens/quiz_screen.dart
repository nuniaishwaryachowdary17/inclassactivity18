import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);

    try {
      final q = await ApiService.fetchQuestions();
      setState(() {
        _questions = q;
        _loading = false;
        _currentIndex = 0;
        _score = 0;
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
      });
    } catch (e) {
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Unable to load questions.\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  void _submitAnswer(String option) {
    if (_answered) return;

    final correct = _questions[_currentIndex].correctAnswer;

    setState(() {
      _answered = true;
      _selectedAnswer = option;
      _feedbackText =
          option == correct ? "Correct!" : "Wrong! Correct answer: $correct";

      if (option == correct) _score += 1;
    });
  }

  void _next() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Quiz Completed"),
          content: Text("Your Score: $_score / ${_questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadQuestions();
              },
              child: const Text("Restart"),
            )
          ],
        ),
      );
    }
  }

  Widget _optionButton(String option) {
    final correct = _questions[_currentIndex].correctAnswer;

    Color? color;
    if (_answered) {
      if (option == _selectedAnswer) {
        color = option == correct ? Colors.green : Colors.red;
      } else if (option == correct) {
        color = Colors.green;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(14),
        ),
        child: Text(option),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentIndex + 1} / ${_questions.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(q.question, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...q.options.map((opt) => _optionButton(opt)),
            const SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _feedbackText.contains("Correct")
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _next,
                child: const Text("Next"),
              ),
            const SizedBox(height: 10),
            Text("Score: $_score",
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 18))
          ],
        ),
      ),
    );
  }
}
