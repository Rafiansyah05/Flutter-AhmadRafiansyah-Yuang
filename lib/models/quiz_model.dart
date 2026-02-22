import 'question_model.dart';

class QuizModel {
  final String id;
  final String title;
  final int questionCount;
  final String difficulty;
  final int durationMinutes;
  final String quizType;
  final List<QuestionModel> questions;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.difficulty,
    required this.durationMinutes,
    required this.quizType,
    required this.questions,
    required this.createdAt,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      questionCount: map['question_count'] ?? 0,
      difficulty: map['difficulty'] ?? '',
      durationMinutes: map['duration_minutes'] ?? 0,
      quizType: map['quiz_type'] ?? '',
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q)))
          .toList(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'question_count': questionCount,
      'difficulty': difficulty,
      'duration_minutes': durationMinutes,
      'quiz_type': quizType,
      'questions': questions.map((q) => q.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
