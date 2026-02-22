import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ===== AUTH =====

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  // ===== PROFILE =====

  static Future<UserModel?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response =
        await _client.from('profiles').select().eq('id', userId).single();

    return UserModel.fromMap(response);
  }

  // ===== QUIZ SCORES =====

  static Future<void> saveScore({
    required String quizTitle,
    required double score,
    required int totalQuestions,
    required int correctAnswers,
    required int durationSeconds,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await _client.from('quiz_scores').insert({
      'user_id': userId,
      'quiz_title': quizTitle,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'duration_seconds': durationSeconds,
    });
  }

  static Future<List<Map<String, dynamic>>> getScores() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('quiz_scores')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getUserStats() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }
}
