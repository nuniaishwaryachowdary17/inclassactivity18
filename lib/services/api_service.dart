import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    int category = 9,
    String difficulty = 'easy',
    String type = 'multiple',
  }) async {
    final url =
        "https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      final results = decoded['results'] as List;

      return results.map((e) => Question.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch questions");
    }
  }
}
