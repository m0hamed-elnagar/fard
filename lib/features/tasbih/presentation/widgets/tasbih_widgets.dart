import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CounterCircle extends StatelessWidget {
  final int count;
  final int targetCount;
  final Color color;
  final double size;

  const CounterCircle({
    super.key,
    required this.count,
    required this.targetCount,
    this.color = AppTheme.primaryLight,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: targetCount > 0 ? count / targetCount : 0,
            strokeWidth: size * 0.05, // Dynamic stroke width
            backgroundColor: AppTheme.surfaceLight,
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: size * 0.3, // Dynamic font size
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (targetCount > 0)
              Text(
                '/ $targetCount',
                style: GoogleFonts.outfit(
                  fontSize: size * 0.075,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class DhikrDisplayCard extends StatelessWidget {
  final String arabic;
  final String transliteration;
  final String translation;
  final bool showTransliteration;
  final bool showTranslation;

  const DhikrDisplayCard({
    super.key,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.showTransliteration = true,
    this.showTranslation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              arabic,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 28, // Reduced slightly for better fit
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                height: 1.5,
              ),
            ),
            if (showTransliteration) ...[
              const SizedBox(height: 8),
              Text(
                transliteration,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
            if (showTranslation) ...[
              const SizedBox(height: 4),
              Text(
                translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TasbihButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final double size;

  const TasbihButton({
    super.key,
    required this.onTap,
    this.color = AppTheme.primaryLight,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _vibrate(context),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: size * 0.15,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
        child: Icon(
          Icons.touch_app_rounded,
          size: size * 0.5,
          color: AppTheme.onPrimary,
        ),
      ),
    );
  }

  void _vibrate(BuildContext context) {
    // Immediate feedback on touch down
  }
}

class CycleProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCycles;

  const CycleProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCycles,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: List.generate(totalCycles, (index) {
        final isActive = index == currentIndex;
        final isCompleted = index < currentIndex;
        return Container(
          width: 32,
          height: 6,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppTheme.primaryLight 
                : (isActive ? AppTheme.accent : AppTheme.surfaceLight),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
