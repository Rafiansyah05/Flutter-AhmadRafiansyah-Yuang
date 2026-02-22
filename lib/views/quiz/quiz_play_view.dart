import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/quiz_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import 'quiz_result_view.dart';

class QuizPlayView extends StatelessWidget {
  const QuizPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizController>();

    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context, ctrl);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          final quiz = ctrl.activeQuiz.value;
          if (quiz == null) return const SizedBox.shrink();

          final question = quiz.questions[ctrl.currentQuestion.value];
          final total = quiz.questions.length;
          final current = ctrl.currentQuestion.value;
          final progress = (current + 1) / total;

          return SafeArea(
            child: Column(
              children: [
                // ===== HEADER =====
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Question counter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Soal ${current + 1}/$total',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Timer
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: ctrl.timeRemaining.value < 60
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_rounded,
                                  size: 16,
                                  color: ctrl.timeRemaining.value < 60
                                      ? AppColors.error
                                      : AppColors.primaryDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ctrl.formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ctrl.timeRemaining.value < 60
                                        ? AppColors.error
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Progress
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.primaryLight,
                          color: AppColors.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== QUESTION NAVIGATOR =====
                Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.background,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: total,
                    itemBuilder: (context, index) {
                      final isAnswered = ctrl.answers.containsKey(index);
                      final isCurrent = index == current;
                      return GestureDetector(
                        onTap: () => ctrl.goToQuestion(index),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            gradient:
                                isCurrent ? AppColors.primaryGradient : null,
                            color: isAnswered && !isCurrent
                                ? AppColors.success
                                : isCurrent
                                    ? null
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.primary
                                  : isAnswered
                                      ? AppColors.success
                                      : AppColors.divider,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCurrent || isAnswered
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ===== QUESTION CONTENT =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question.type == 'multiple_choice'
                                      ? 'Pilihan Ganda'
                                      : 'Isian Singkat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                question.question,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Answers
                        if (question.type == 'multiple_choice')
                          ...question.options.asMap().entries.map((entry) {
                            final optionText = entry.value;
                            final isSelected =
                                ctrl.answers[current] == optionText;
                            return GestureDetector(
                              onTap: () =>
                                  ctrl.answerQuestion(current, optionText),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.divider,
                                    width: isSelected ? 0 : 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                        else
                          _ShortAnswerField(
                            currentIndex: current,
                            initialValue: ctrl.answers[current] ?? '',
                            onChanged: (val) =>
                                ctrl.answerQuestion(current, val),
                          ),
                      ],
                    ),
                  ),
                ),

                // ===== NAVIGATION =====
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      if (current > 0)
                        Expanded(
                          child: CustomButton(
                            text: 'Sebelumnya',
                            isOutlined: true,
                            onPressed: ctrl.prevQuestion,
                          ),
                        ),
                      if (current > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: current < total - 1
                            ? CustomButton(
                                text: 'Berikutnya',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: ctrl.nextQuestion,
                              )
                            : CustomButton(
                                text: 'Selesai & Lihat Nilai',
                                icon: Icons.done_all_rounded,
                                color: AppColors.success,
                                onPressed: () =>
                                    _showSubmitDialog(context, ctrl),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<bool> _showExitDialog(
      BuildContext context, QuizController ctrl) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Kuis?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Kemajuanmu tidak akan tersimpan.',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Lanjut Kuis',
                style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.resetQuiz();
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child:
                Text('Keluar', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSubmitDialog(BuildContext context, QuizController ctrl) {
    final answered = ctrl.answers.length;
    final total = ctrl.activeQuiz.value?.questions.length ?? 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kumpulkan Jawaban?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kamu telah menjawab $answered dari $total soal.',
                style: GoogleFonts.poppins(fontSize: 14)),
            if (answered < total)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ ${total - answered} soal belum dijawab.',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.warning),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Periksa Lagi',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await ctrl.submitQuiz();
              Get.off(() => const QuizResultView());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Kumpulkan',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ShortAnswerField extends StatefulWidget {
  final int currentIndex;
  final String initialValue;
  final void Function(String) onChanged;

  const _ShortAnswerField({
    required this.currentIndex,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_ShortAnswerField> createState() => _ShortAnswerFieldState();
}

class _ShortAnswerFieldState extends State<_ShortAnswerField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ShortAnswerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        maxLines: 4,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ketik jawabanmu di sini...',
          hintStyle:
              GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
