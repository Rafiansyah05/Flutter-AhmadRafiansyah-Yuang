import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/services/gemini_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/supabase_service.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../models/question_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class QuizController extends GetxController {
  // Config
  final RxInt questionCount = 10.obs;
  final RxString difficulty = 'Sedang'.obs;
  final RxInt durationMinutes = 30.obs;
  final RxString quizType = 'Pilihan Ganda'.obs;
  final RxString quizTitle = ''.obs;

  // PDF
  final Rx<File?> pdfFile = Rx<File?>(null);
  final RxString pdfFileName = ''.obs;

  // Generation
  final RxBool isGenerating = false.obs;
  final RxString generatingMessage = 'Menganalisis dokumen...'.obs;

  // Playing
  final Rx<QuizModel?> activeQuiz = Rx<QuizModel?>(null);
  final RxInt currentQuestion = 0.obs;
  final RxMap<int, String> answers = <int, String>{}.obs;
  final RxInt timeRemaining = 0.obs;
  Timer? _timer;

  // Result
  final Rx<QuizResultModel?> result = Rx<QuizResultModel?>(null);
  final RxBool isSaved = false.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      pdfFile.value = File(result.files.single.path!);
      pdfFileName.value = result.files.single.name;
    }
  }

  Future<void> generateQuiz(String title) async {
    if (pdfFile.value == null) {
      Get.snackbar('Error', 'Silakan unggah dokumen PDF terlebih dahulu');
      return;
    }

    quizTitle.value = title.isEmpty
        ? 'Kuis ${DateTime.now().day}/${DateTime.now().month}'
        : title;
    isGenerating.value = true;

    try {
      generatingMessage.value = 'Membaca dokumen PDF...';
      // Read PDF as bytes and convert to text (basic extraction)
      // For production use a proper PDF parser like syncfusion_flutter_pdf
      final bytes = await pdfFile.value!.readAsBytes();
      String documentText = 'Dokumen PDF: ${pdfFileName.value}\n';
      // Basic text extraction - in production use a PDF library
      // For now we'll use the raw bytes as base64 and send to Gemini
      documentText = await _extractTextFromPdf(bytes);

      generatingMessage.value = 'AI sedang membuat soal...';
      final questions = await GeminiService.generateQuestions(
        documentText: documentText,
        questionCount: questionCount.value,
        difficulty: difficulty.value,
        quizType: quizType.value,
        quizTitle: quizTitle.value,
      );

      generatingMessage.value = 'Menyusun kuis...';
      final quiz = QuizModel(
        id: const Uuid().v4(),
        title: quizTitle.value,
        questionCount: questions.length,
        difficulty: difficulty.value,
        durationMinutes: durationMinutes.value,
        quizType: quizType.value,
        questions: questions,
        createdAt: DateTime.now(),
      );

      activeQuiz.value = quiz;
      isGenerating.value = false;
    } catch (e) {
      isGenerating.value = false;
      Get.snackbar('Error', 'Gagal membuat soal: $e',
          backgroundColor: Colors.red.shade100);
    }
  }

  Future<String> _extractTextFromPdf(List<int> bytes) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();
    document.dispose();

    // Batasi panjang teks agar tidak melebihi limit Gemini
    if (text.length > 15000) {
      text = text.substring(0, 15000);
    }
    return text;
  }

  void startQuiz() {
    currentQuestion.value = 0;
    answers.clear();
    isSaved.value = false;
    result.value = null;
    timeRemaining.value = durationMinutes.value * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value <= 0) {
        timer.cancel();
        submitQuiz();
      } else {
        timeRemaining.value--;
      }
    });
  }

  void answerQuestion(int index, String answer) {
    answers[index] = answer;
  }

  void nextQuestion() {
    if (currentQuestion.value < (activeQuiz.value?.questions.length ?? 1) - 1) {
      currentQuestion.value++;
    }
  }

  void prevQuestion() {
    if (currentQuestion.value > 0) {
      currentQuestion.value--;
    }
  }

  void goToQuestion(int index) {
    currentQuestion.value = index;
  }

  Future<void> submitQuiz() async {
    _timer?.cancel();
    final quiz = activeQuiz.value;
    if (quiz == null) return;

    int correct = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      quiz.questions[i].userAnswer = answers[i];
      if (quiz.questions[i].isCorrect) correct++;
    }

    final score = (correct / quiz.questions.length) * 100;
    final timeTaken = (quiz.durationMinutes * 60) - timeRemaining.value;

    final quizResult = QuizResultModel(
      id: const Uuid().v4(),
      quizId: quiz.id,
      quizTitle: quiz.title,
      score: score,
      totalQuestions: quiz.questions.length,
      correctAnswers: correct,
      durationSeconds: timeTaken,
      completedAt: DateTime.now(),
    );

    result.value = quizResult;

    // Save score to Supabase
    try {
      await SupabaseService.saveScore(
        quizTitle: quiz.title,
        score: score,
        totalQuestions: quiz.questions.length,
        correctAnswers: correct,
        durationSeconds: timeTaken,
      );
    } catch (_) {}
  }

  Future<void> saveQuiz() async {
    final quiz = activeQuiz.value;
    if (quiz == null) return;

    await LocalStorageService.saveQuiz(quiz);
    if (result.value != null) {
      await LocalStorageService.saveResult(result.value!);
    }
    isSaved.value = true;
    Get.snackbar('Berhasil', 'Kuis berhasil disimpan! ✅',
        backgroundColor: Colors.green.shade100);
  }

  void resetQuiz() {
    activeQuiz.value = null;
    currentQuestion.value = 0;
    answers.clear();
    result.value = null;
    isSaved.value = false;
    pdfFile.value = null;
    pdfFileName.value = '';
    _timer?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  String get formattedTime {
    final minutes = timeRemaining.value ~/ 60;
    final seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
