import 'package:get/get.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/supabase_service.dart';
import '../models/quiz_model.dart';

class HomeController extends GetxController {
  final RxList<QuizModel> quizzes = <QuizModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxDouble averageScore = 0.0.obs;
  final RxInt totalQuizzes = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuizzes();
    loadStats();
  }

  void loadQuizzes() {
    final all = LocalStorageService.getAllQuizzes();
    quizzes.value = all;
  }

  Future<void> loadStats() async {
    try {
      final stats = await SupabaseService.getUserStats();
      if (stats != null) {
        averageScore.value =
            (stats['average_score'] as num?)?.toDouble() ?? 0.0;
        totalQuizzes.value = stats['total_quizzes'] ?? 0;
      }
    } catch (_) {}
  }

  List<QuizModel> get filteredQuizzes {
    if (searchQuery.value.isEmpty) return quizzes;
    return quizzes
        .where((q) =>
            q.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void onSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> deleteQuiz(String id) async {
    await LocalStorageService.deleteQuiz(id);
    loadQuizzes();
  }

  void refresh() {
    loadQuizzes();
    loadStats();
  }
}
