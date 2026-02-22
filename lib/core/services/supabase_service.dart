import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ===========================
  // AUTH
  // ===========================

  /// SIGNUP
  /// Password di-hash otomatis oleh Supabase menggunakan bcrypt
  /// Kita tidak perlu dan tidak boleh hash manual
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
      );

      if (response.user == null) {
        throw Exception('Gagal membuat akun. Coba lagi.');
      }

      // Jika trigger tidak berjalan otomatis, buat profile manual
      await _ensureProfileExists(
        userId: response.user!.id,
        email: email.trim().toLowerCase(),
        fullName: fullName.trim(),
      );

      return response;
    } on AuthException catch (e) {
      throw _parseAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// SIGN IN
  /// Supabase otomatis memverifikasi password yang sudah di-hash
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Email atau password salah.');
      }

      // Pastikan profile ada (kadang trigger lambat)
      await _ensureProfileExists(
        userId: response.user!.id,
        email: response.user!.email ?? '',
        fullName: response.user!.userMetadata?['full_name'] ?? '',
      );

      return response;
    } on AuthException catch (e) {
      throw _parseAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// SIGN OUT
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Cek apakah user sedang login
  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => _client.auth.currentUser != null;

  // ===========================
  // PROFILE
  // ===========================

  /// Ambil profil user yang sedang login
  static Future<UserModel?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Profile belum ada, buat dulu
        await _ensureProfileExists(
          userId: userId,
          email: currentUser?.email ?? '',
          fullName: currentUser?.userMetadata?['full_name'] ?? '',
        );
        // Coba ambil lagi
        final retry = await _client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (retry == null) return null;
        return UserModel.fromMap(retry);
      }

      return UserModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Update profil user
  static Future<void> updateProfile({String? fullName}) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;

    await _client.from('profiles').update(updates).eq('id', userId);
  }

  // ===========================
  // QUIZ SCORES
  // ===========================

  /// Simpan nilai kuis ke Supabase
  static Future<void> saveScore({
    required String quizTitle,
    required double score,
    required int totalQuestions,
    required int correctAnswers,
    required int durationSeconds,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('quiz_scores').insert({
        'user_id': userId,
        'quiz_title': quizTitle,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'duration_seconds': durationSeconds,
      });
    } catch (e) {
      // Jangan crash app jika save score gagal
      print('Warning: Gagal menyimpan score ke Supabase: $e');
    }
  }

  /// Ambil semua nilai kuis user
  static Future<List<Map<String, dynamic>>> getScores() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('quiz_scores')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Ambil statistik user (rata-rata nilai, total kuis, dll)
  static Future<Map<String, dynamic>?> getUserStats() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ===========================
  // PRIVATE HELPERS
  // ===========================

  /// Pastikan profile ada di tabel profiles
  /// Dipanggil setelah signup/signin sebagai fallback jika trigger lambat
  static Future<void> _ensureProfileExists({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _client.from('profiles').upsert(
        {
          'id': userId,
          'email': email,
          'full_name': fullName,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } catch (e) {
      print('Info: _ensureProfileExists: $e');
    }
  }

  /// Ubah pesan error Supabase Auth menjadi bahasa Indonesia
  static Exception _parseAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return Exception('Email atau password salah. Periksa kembali.');
    }
    if (message.contains('email already registered') ||
        message.contains('already registered')) {
      return Exception('Email sudah terdaftar. Silakan login.');
    }
    if (message.contains('password should be at least')) {
      return Exception('Password minimal 6 karakter.');
    }
    if (message.contains('unable to validate email address')) {
      return Exception('Format email tidak valid.');
    }
    if (message.contains('email not confirmed')) {
      return Exception(
          'Email belum dikonfirmasi. Matikan Email Confirmation di Supabase Dashboard.');
    }
    if (message.contains('too many requests')) {
      return Exception('Terlalu banyak percobaan. Tunggu beberapa menit.');
    }
    if (message.contains('network') || message.contains('connection')) {
      return Exception('Tidak ada koneksi internet. Periksa jaringan kamu.');
    }

    return Exception('Terjadi kesalahan: ${e.message}');
  }
}
