import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradeHelper {
  static String getGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    if (score >= 50) return 'E';
    return 'F';
  }

  static Color getGradeColor(double score) {
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 80) return const Color(0xFF3B82F6);
    if (score >= 70) return const Color(0xFF8B5CF6);
    if (score >= 60) return const Color(0xFFF59E0B);
    if (score >= 50) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  static String getMessage(double score) {
    if (score > 85) {
      return '🎉 Luar Biasa! Kamu sangat menguasai materi ini. Pertahankan semangat belajarmu dan terus raih prestasi yang lebih tinggi!';
    } else if (score > 60) {
      return '👏 Kerja bagus! Kamu hampir di puncak. Sedikit lagi dan kamu akan menguasainya sepenuhnya. Jangan berhenti belajar!';
    } else {
      return '💪 Jangan menyerah! Setiap ahli pernah menjadi pemula. Pelajari kembali materinya dan kamu pasti bisa lebih baik lagi!';
    }
  }

  static String getEmoji(double score) {
    if (score > 85) return '🏆';
    if (score > 60) return '⭐';
    return '📚';
  }
}
