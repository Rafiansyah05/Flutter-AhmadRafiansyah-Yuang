import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/question_model.dart';
import '../constants/app_strings.dart';

class GeminiService {
  static final _dio = Dio();
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static Future<List<QuestionModel>> generateQuestions({
    required String documentText,
    required int questionCount,
    required String difficulty,
    required String quizType,
    required String quizTitle,
  }) async {
    final typeInstruction = quizType == 'Pilihan Ganda'
        ? '''Buat soal pilihan ganda dengan 4 opsi jawaban (A, B, C, D).
Format JSON untuk setiap soal:
{
  "question": "pertanyaan",
  "type": "multiple_choice",
  "options": ["A. opsi1", "B. opsi2", "C. opsi3", "D. opsi4"],
  "correct_answer": "A. opsi1",
  "explanation": "penjelasan mengapa jawaban ini benar"
}'''
        : '''Buat soal isian singkat.
Format JSON untuk setiap soal:
{
  "question": "pertanyaan",
  "type": "short_answer",
  "options": [],
  "correct_answer": "jawaban singkat yang benar",
  "explanation": "penjelasan jawaban"
}''';

    final prompt = '''
Kamu adalah guru yang ahli membuat soal ujian. 
Berdasarkan dokumen berikut, buatlah $questionCount soal dengan tingkat kesulitan "$difficulty" dalam Bahasa Indonesia.

$typeInstruction

PENTING:
- Kembalikan HANYA array JSON tanpa teks lain
- Soal harus berdasarkan konten dokumen
- Penjelasan harus jelas dan informatif

Dokumen:
$documentText

Kembalikan array JSON dengan $questionCount soal:
''';

    try {
      final response = await _dio.post(
        '$_baseUrl?key=${AppStrings.geminiApiKey}',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 8192,
          }
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final text = response.data['candidates'][0]['content']['parts'][0]['text']
          as String;

      // Clean up response - remove markdown code blocks if present
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final List<dynamic> jsonList = jsonDecode(cleanedText);
      return jsonList
          .map((json) => QuestionModel.fromMap(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw Exception('Format soal dari AI tidak valid, coba generate ulang');
    }
  }

  static Future<String> getAnswerExplanation(
      String question, String correctAnswer) async {
    final prompt =
        'Jelaskan secara singkat mengapa "$correctAnswer" adalah jawaban yang benar untuk pertanyaan: "$question". Gunakan bahasa Indonesia yang mudah dipahami.';

    try {
      final response = await _dio.post(
        '$_baseUrl?key=${AppStrings.geminiApiKey}',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return response.data['candidates'][0]['content']['parts'][0]['text']
          as String;
    } catch (e) {
      return 'Tidak dapat memuat penjelasan.';
    }
  }
}
