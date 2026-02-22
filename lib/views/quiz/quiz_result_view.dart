import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/quiz_controller.dart';
import '../../controllers/home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/grade_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_badge.dart';
import '../home/home_view.dart';

class QuizResultView extends StatefulWidget {
  const QuizResultView({super.key});

  @override
  State<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends State<QuizResultView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  final GlobalKey _screenshotKey = GlobalKey();
  bool _showReview = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _shareResult(QuizController ctrl) async {
    try {
      final RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/thequis_result.png');
      await file.writeAsBytes(bytes);

      final score = ctrl.result.value?.score ?? 0;
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '🎯 Aku baru saja menyelesaikan kuis "${ctrl.activeQuiz.value?.title}" di TheQuis!\n'
            'Nilainya: ${score.toStringAsFixed(0)}/100 (${GradeHelper.getGrade(score)})\n'
            '${GradeHelper.getEmoji(score)} #TheQuis #BelajarCerdas',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal membagikan hasil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizController>();
    final result = ctrl.result.value;
    if (result == null) return const SizedBox.shrink();

    final score = result.score;
    final grade = GradeHelper.getGrade(score);
    final message = GradeHelper.getMessage(score);
    final emoji = GradeHelper.getEmoji(score);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== RESULT CARD (screenshotable) =====
              RepaintBoundary(
                key: _screenshotKey,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.quiz_rounded,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'TheQuis',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.quizTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Score
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Column(
                            children: [
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 52),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${score.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'dari 100',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Grade
                        GradeBadge(score: score, size: 64),
                        const SizedBox(height: 20),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _resultStat(
                                '✅', '${result.correctAnswers}', 'Benar'),
                            _divider(),
                            _resultStat(
                                '❌',
                                '${result.totalQuestions - result.correctAnswers}',
                                'Salah'),
                            _divider(),
                            _resultStat(
                                '⏱️',
                                '${(result.durationSeconds ~/ 60)}m ${result.durationSeconds % 60}s',
                                'Waktu'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== BUTTONS =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Bagikan',
                            isOutlined: true,
                            icon: Icons.share_rounded,
                            onPressed: () => _shareResult(ctrl),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => CustomButton(
                                text: ctrl.isSaved.value
                                    ? 'Tersimpan ✓'
                                    : 'Simpan',
                                icon: ctrl.isSaved.value
                                    ? Icons.check_rounded
                                    : Icons.save_rounded,
                                color: ctrl.isSaved.value
                                    ? AppColors.success
                                    : null,
                                onPressed: ctrl.isSaved.value
                                    ? null
                                    : () async {
                                        await ctrl.saveQuiz();
                                        try {
                                          Get.find<HomeController>().refresh();
                                        } catch (_) {}
                                      },
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: _showReview
                          ? 'Sembunyikan Pembahasan'
                          : 'Lihat Pembahasan',
                      isOutlined: true,
                      icon: Icons.article_outlined,
                      onPressed: () =>
                          setState(() => _showReview = !_showReview),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Kembali ke Beranda',
                      icon: Icons.home_rounded,
                      onPressed: () {
                        ctrl.resetQuiz();
                        Get.offAll(() => const HomeView());
                      },
                    ),
                  ],
                ),
              ),

              // ===== REVIEW SECTION =====
              if (_showReview) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Pembahasan Soal',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...ctrl.activeQuiz.value!.questions
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final isCorrect = question.isCorrect;

                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.error.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCorrect
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Soal ${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          question.question,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (question.userAnswer != null &&
                            question.userAnswer!.isNotEmpty) ...[
                          _answerRow('Jawabanmu', question.userAnswer!,
                              isCorrect ? AppColors.success : AppColors.error),
                          const SizedBox(height: 4),
                        ],
                        if (!isCorrect)
                          _answerRow('Jawaban Benar', question.correctAnswer,
                              AppColors.success),
                        const Divider(height: 20),
                        Text(
                          '💡 ${question.explanation}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 30),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white30);
  }

  Widget _answerRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
