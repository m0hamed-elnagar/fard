import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MissedDaysDialog extends StatelessWidget {
  final List<DateTime> missedDates;
  final void Function(bool addAsMissed) onResponse;

  const MissedDaysDialog({
    super.key,
    required this.missedDates,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.accent, size: 32),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'أيام فائتة',
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم تسجل ${missedDates.length} ${missedDates.length == 1 ? 'يوم' : 'أيام'}',
              style: GoogleFonts.amiri(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Date range
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_formatDate(missedDates.first)} — ${_formatDate(missedDates.last)}',
                style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onResponse(false);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('تخطي',
                        style: GoogleFonts.amiri(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onResponse(true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.missed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('إضافة الكل',
                        style: GoogleFonts.amiri(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
