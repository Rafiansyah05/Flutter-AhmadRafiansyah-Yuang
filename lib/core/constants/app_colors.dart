import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4FC3F7); // Light Blue
  static const Color primaryDark = Color(0xFF0288D1); // Blue Dark
  static const Color primaryLight = Color(0xFFE1F5FE); // Very Light Blue
  static const Color accent = Color(0xFF0077B6); // Deep Blue Accent
  static const Color background = Color(0xFFF8FBFF); // Almost White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color divider = Color(0xFFE5E7EB);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFE1F5FE), Color(0xFFF8FBFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
