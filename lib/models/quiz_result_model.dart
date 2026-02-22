class QuizResultModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int durationSeconds;
  final DateTime completedAt;

  QuizResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.durationSeconds,
    required this.completedAt,
  });

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'] ?? '',
      quizId: map['quiz_id'] ?? '',
      quizTitle: map['quiz_title'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: map['total_questions'] ?? 0,
      correctAnswers: map['correct_answers'] ?? 0,
      durationSeconds: map['duration_seconds'] ?? 0,
      completedAt:
          DateTime.tryParse(map['completed_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'duration_seconds': durationSeconds,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
