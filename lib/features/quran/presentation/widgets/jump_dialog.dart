import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

/// Jump dialog shown when user taps an ayah far from their last read position
/// Offers 3 choices: Dismiss, Mark All, New Session
class JumpDialog extends StatelessWidget {
  final int lastReadAyah;
  final int targetAyah;
  final int currentTotalToday;

  const JumpDialog({
    super.key,
    required this.lastReadAyah,
    required this.targetAyah,
    required this.currentTotalToday,
  });

  int get gap => (targetAyah - lastReadAyah).abs();
  int get pages => (gap / 20).ceil(); // Approx 20 ayahs per page
  int get newTotalIfMarkAll => currentTotalToday + gap;

  /// Get surah number from absolute ayah number
  int _getSurahNumber(int absoluteAyah) {
    return QuranHizbProvider.getSurahAndAyahFromAbsolute(absoluteAyah)[0];
  }

  /// Get ayah number in surah from absolute ayah number
  int _getAyahInSurah(int absoluteAyah) {
    return QuranHizbProvider.getSurahAndAyahFromAbsolute(absoluteAyah)[1];
  }

  /// Get localized surah name
  String _getSurahName(int absoluteAyah, bool isArabic) {
    final surahNum = _getSurahNumber(absoluteAyah);
    return isArabic ? quran.getSurahNameArabic(surahNum) : quran.getSurahName(surahNum);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';

    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jump info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryLight.withValues(alpha: 0.15),
                    AppTheme.primaryLight.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.4),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: AppTheme.primaryLight,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.jumpDialogTitle,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Starting position
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: AppTheme.textSecondary.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? "من:" : "From:",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isAr
                                ? "سورة ${_getSurahName(lastReadAyah, true)} - آية ${_getAyahInSurah(lastReadAyah).toArabicIndic()}"
                                : "Surah ${_getSurahName(lastReadAyah, false)}, Ayah ${_getAyahInSurah(lastReadAyah)}",
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Target position
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: AppTheme.textSecondary.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? "إلى:" : "To:",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isAr
                                ? "سورة ${_getSurahName(targetAyah, true)} - آية ${_getAyahInSurah(targetAyah).toArabicIndic()}"
                                : "Surah ${_getSurahName(targetAyah, false)}, Ayah ${_getAyahInSurah(targetAyah)}",
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.jumpGapInfo(
                      isAr ? gap.toArabicIndic() : gap.toString(),
                      isAr ? pages.toArabicIndic() : pages.toString(),
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Mark all (GREEN - highlighted, prioritized)
            _buildOption(
              context,
              icon: Icons.check_circle_rounded,
              label: l10n.jumpOptionMarkAll,
              description: l10n.jumpMarkAllDesc(
                isAr ? gap.toArabicIndic() : gap.toString(),
                isAr ? pages.toArabicIndic() : pages.toString(),
              ),
              color: AppTheme.primaryLight, // GREEN
              highlighted: true,
              onTap: () => Navigator.of(context).pop(1), // Mark all = 1
            ),
            const SizedBox(height: 10),

            // Option 2: Dismiss
            _buildOption(
              context,
              icon: Icons.close_rounded,
              label: l10n.jumpOptionDismiss,
              description: l10n.jumpDismissDesc,
              color: AppTheme.neutral,
              onTap: () => Navigator.of(context).pop(0), // Dismiss = 0
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlighted
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: highlighted
                  ? color.withValues(alpha: 0.4)
                  : AppTheme.cardBorder.withValues(alpha: 0.4),
              width: highlighted ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<int?> show(
    BuildContext context, {
    required int lastReadAyah,
    required int targetAyah,
    required int currentTotalToday,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => JumpDialog(
        lastReadAyah: lastReadAyah,
        targetAyah: targetAyah,
        currentTotalToday: currentTotalToday,
      ),
    );
  }
}
