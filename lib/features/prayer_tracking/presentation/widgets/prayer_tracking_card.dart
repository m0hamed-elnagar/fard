import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerTrackingCard extends StatelessWidget {
  final Map<Salaah, MissedCounter> qadaStatus;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;

  const PrayerTrackingCard({
    super.key,
    required this.qadaStatus,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';
    final totalQada = qadaStatus.values.fold(
      0,
      (sum, counter) => sum + counter.value,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: isAr ? null : -20,
              left: isAr ? -20 : null,
              bottom: -20,
              child: Opacity(
                opacity: 0.03,
                child: const Icon(
                  Icons.history_rounded,
                  size: 180,
                  color: Colors.white,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isShort = constraints.maxHeight < 280;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalQada,
                        style: GoogleFonts.amiri(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            isAr
                                ? totalQada.toArabicIndic()
                                : totalQada.toString(),
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: isShort ? 36 : 42,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.localeName == 'ar' ? 'صلاة' : 'Prayers',
                            style: GoogleFonts.amiri(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                      Row(
                        children: [
                          _ActionButton(
                            icon: Icons.add_circle_outline_rounded,
                            label: l10n.add,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              onAddPressed();
                            },
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.edit_note_rounded,
                            label: l10n.edit,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onEditPressed();
                            },
                          ),
                        ],
                      ),
                      const Spacer(flex: 1),
                      const Divider(height: 1, color: AppTheme.cardBorder),
                      const Spacer(flex: 1),
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final itemWidth = gridConstraints.maxWidth / 5;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: Salaah.values.map((salaah) {
                              final count = qadaStatus[salaah]?.value ?? 0;
                              return SizedBox(
                                width: itemWidth,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      salaah.localizedName(l10n),
                                      style: GoogleFonts.amiri(
                                        color: AppTheme.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      isAr
                                          ? count.toArabicIndic()
                                          : count.toString(),
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppTheme.cardBorder.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.cardBorder.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: AppTheme.textPrimary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
