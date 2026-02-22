import 'package:hive_flutter/hive_flutter.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import '../../models/quiz_result_model.dart';

class LocalStorageService {
  static const String _quizBox = 'quizzes';
  static const String _resultBox = 'results';

  static Future<void> init() async {
    await Hive.openBox(_quizBox);
    await Hive.openBox(_resultBox);
  }

  // ===== QUIZ =====

  static Future<void> saveQuiz(QuizModel quiz) async {
    final box = Hive.box(_quizBox);
    await box.put(quiz.id, quiz.toMap());
  }

  static List<QuizModel> getAllQuizzes() {
    final box = Hive.box(_quizBox);
    return box.values
        .map((map) => QuizModel.fromMap(Map<String, dynamic>.from(map)))
        .toList()
        .reversed
        .toList();
  }

  static QuizModel? getQuiz(String id) {
    final box = Hive.box(_quizBox);
    final map = box.get(id);
    if (map == null) return null;
    return QuizModel.fromMap(Map<String, dynamic>.from(map));
  }

  static Future<void> deleteQuiz(String id) async {
    final box = Hive.box(_quizBox);
    await box.delete(id);
  }

  // ===== RESULT =====

  static Future<void> saveResult(QuizResultModel result) async {
    final box = Hive.box<Map>(_resultBox);
    await box.put(result.id, result.toMap());
  }

  static List<QuizResultModel> getAllResults() {
    final box = Hive.box<Map>(_resultBox);
    return box.values
        .map((map) => QuizResultModel.fromMap(Map<String, dynamic>.from(map)))
        .toList()
        .reversed
        .toList();
  }

  static QuizResultModel? getResultByQuizId(String quizId) {
    final box = Hive.box<Map>(_resultBox);
    final maps = box.values.where((map) => map['quiz_id'] == quizId).toList();
    if (maps.isEmpty) return null;
    return QuizResultModel.fromMap(Map<String, dynamic>.from(maps.first));
  }
}
