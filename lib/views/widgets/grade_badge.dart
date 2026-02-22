import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/grade_helper.dart';

class GradeBadge extends StatelessWidget {
  final double score;
  final double size;

  const GradeBadge({super.key, required this.score, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final grade = GradeHelper.getGrade(score);
    final color = GradeHelper.getGradeColor(score);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 2.5),
      ),
      child: Center(
        child: Text(
          grade,
          style: GoogleFonts.poppins(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
