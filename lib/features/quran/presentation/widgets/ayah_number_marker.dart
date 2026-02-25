import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/extensions/number_extension.dart';

class AyahNumberMarker extends StatelessWidget {
  final int number;
  final double size;
  final Color? color;

  const AyahNumberMarker({
    super.key,
    required this.number,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          number.toArabicIndic(),
          style: GoogleFonts.amiri(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
