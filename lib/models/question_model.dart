class QuestionModel {
  final String question;
  final String type; // 'multiple_choice' or 'short_answer'
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  String? userAnswer;

  QuestionModel({
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.userAnswer,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      type: map['type'] ?? 'multiple_choice',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correct_answer'] ?? '',
      explanation: map['explanation'] ?? '',
      userAnswer: map['user_answer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'type': type,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'user_answer': userAnswer,
    };
  }

  bool get isCorrect {
    if (userAnswer == null) return false;
    if (type == 'multiple_choice') {
      return userAnswer!.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    } else {
      // For short answer, check if user answer contains key words
      final userWords = userAnswer!.toLowerCase().split(' ');
      final correctWords = correctAnswer.toLowerCase().split(' ');
      int matches = correctWords
          .where((w) => userWords.contains(w) && w.length > 3)
          .length;
      return matches >= (correctWords.where((w) => w.length > 3).length * 0.6);
    }
  }
}
