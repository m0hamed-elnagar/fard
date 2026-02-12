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
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.accent, size: 32.0),
            ),
            const SizedBox(height: 16.0),
            // Title
            Text(
              'أيام فائتة',
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'لم تسجل ${missedDates.length} ${missedDates.length == 1 ? 'يوم' : 'أيام'}',
              style: GoogleFonts.amiri(
                color: AppTheme.textSecondary,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            // Date range
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                '${_formatDate(missedDates.first)} — ${_formatDate(missedDates.last)}',
                style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 13.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
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
                      side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('تخطي',
                        style: GoogleFonts.amiri(fontSize: 15.0)),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onResponse(true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.missed,
                      foregroundColor: Colors.white,
                      elevation: 0.0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('إضافة الكل',
                        style: GoogleFonts.amiri(
                            fontSize: 15.0, fontWeight: FontWeight.w700)),
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
