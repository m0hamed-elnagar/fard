import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';

class SajdahIndicator extends StatelessWidget {
  final SajdahType type;

  const SajdahIndicator({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: type == SajdahType.obligatory
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: type == SajdahType.obligatory ? Colors.red : Colors.green,
          width: 0.5,
        ),
      ),
      child: Text(
        'سجدة',
        style: GoogleFonts.amiri(
          fontSize: 12,
          color: type == SajdahType.obligatory ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
