import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';

class SajdahIndicator extends StatelessWidget {
  final SajdahType type;
  final double scale;

  const SajdahIndicator({
    super.key,
    required this.type,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '۩',
            style: GoogleFonts.amiri(
              fontSize: 20 * scale,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'سجدة',
            style: GoogleFonts.amiri(
              fontSize: 14 * scale,
              color: color,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
