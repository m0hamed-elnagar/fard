import 'package:fard/domain/models/salaah.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SalaahTile extends StatelessWidget {
  final Salaah salaah;
  final int qadaCount;
  final bool isMissedToday;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onToggleMissed;

  const SalaahTile({
    super.key,
    required this.salaah,
    required this.qadaCount,
    required this.isMissedToday,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleMissed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMissedToday
            ? AppTheme.missed.withValues(alpha: 0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMissedToday
              ? AppTheme.missed.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Missed today toggle
          GestureDetector(
            onTap: onToggleMissed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isMissedToday
                    ? AppTheme.missed.withValues(alpha: 0.2)
                    : AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMissedToday
                      ? AppTheme.missed
                      : AppTheme.neutral,
                  width: 2,
                ),
              ),
              child: isMissedToday
                  ? const Icon(Icons.close_rounded,
                      color: AppTheme.missed, size: 18)
                  : const Icon(Icons.check_rounded,
                      color: AppTheme.neutral, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // Salaah name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salaah.label,
                  style: GoogleFonts.amiri(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (qadaCount > 0)
                  Text(
                    'متبقي: $qadaCount',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Counter with +/- buttons
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CounterButton(
                  icon: Icons.add_rounded,
                  onPressed: onAdd,
                ),
               
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  child: Text(
                    '$qadaCount',
                    style: GoogleFonts.outfit(
                      color: qadaCount > 0
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.remove_rounded,
                  onPressed: qadaCount > 0 ? onRemove : null,
                ), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: onPressed != null
                ? AppTheme.textPrimary
                : AppTheme.neutral,
            size: 20,
          ),
        ),
      ),
    );
  }
}
