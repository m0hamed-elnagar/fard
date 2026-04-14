import 'package:fard/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CounterCircle extends StatefulWidget {
  final int count;
  final int targetCount;
  final Color? color;
  final double size;

  const CounterCircle({
    super.key,
    required this.count,
    required this.targetCount,
    this.color,
    this.size = 240,
  });

  @override
  State<CounterCircle> createState() => _CounterCircleState();
}

class _CounterCircleState extends State<CounterCircle> {
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.primaryContainerColor;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: widget.targetCount > 0 ? widget.count / widget.targetCount : 0,
            strokeWidth: widget.size * 0.05,
            backgroundColor: context.surfaceContainerHighestColor,
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.count}',
              style: GoogleFonts.outfit(
                fontSize: widget.size * 0.3,
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
              ),
            ),
            if (widget.targetCount > 0)
              Text(
                '/ ${widget.targetCount}',
                style: GoogleFonts.outfit(
                  fontSize: widget.size * 0.075,
                  color: context.onSurfaceVariantColor,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              arabic,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.secondaryColor,
                height: 1.6,
              ),
            ),
            if (showTransliteration) ...[
              const SizedBox(height: 16),
              Text(
                transliteration,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: context.onSurfaceColor,
                  height: 1.4,
                ),
              ),
            ],
            if (showTranslation) ...[
              const SizedBox(height: 12),
              Text(
                translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: context.onSurfaceVariantColor,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TasbihButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color? color;
  final double size;

  const TasbihButton({
    super.key,
    required this.onTap,
    this.color,
    this.size = 100,
  });

  @override
  State<TasbihButton> createState() => _TasbihButtonState();
}

class _TasbihButtonState extends State<TasbihButton> {
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.primaryContainerColor;
    return GestureDetector(
      onTapDown: (_) => _vibrate(context),
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: widget.size * 0.15,
              spreadRadius: widget.size * 0.05,
            ),
          ],
        ),
        child: Icon(
          Icons.touch_app_rounded,
          size: widget.size * 0.5,
          color: context.theme.colorScheme.onPrimary,
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
                ? context.primaryContainerColor
                : (isActive ? context.secondaryColor : context.surfaceContainerHighestColor),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
