import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SalaahTile extends StatelessWidget {
  final Salaah salaah;
  final int qadaCount;
  final bool isMissedToday;
  final DateTime? time;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onToggleMissed;

  const SalaahTile({
    super.key,
    required this.salaah,
    required this.qadaCount,
    required this.isMissedToday,
    this.time,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleMissed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isMissedToday
            ? AppTheme.missed.withValues(alpha: 0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isMissedToday
              ? AppTheme.missed.withValues(alpha: 0.30)
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
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: isMissedToday
                    ? AppTheme.missed.withValues(alpha: 0.20)
                    : AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMissedToday
                      ? AppTheme.missed
                      : AppTheme.neutral,
                  width: 2.0,
                ),
              ),
              child: isMissedToday
                  ? const Icon(Icons.close_rounded,
                      color: AppTheme.missed, size: 18.0)
                  : const Icon(Icons.check_rounded,
                      color: AppTheme.neutral, size: 18.0),
            ),
          ),
          const SizedBox(width: 12.0),
          // Salaah name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      salaah.localizedName(l10n),
                      style: GoogleFonts.amiri(
                        color: AppTheme.textPrimary,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (time != null) ...[
                      const SizedBox(width: 8.0),
                      Text(
                        '(${timeFormat.format(time!)})',
                        style: GoogleFonts.outfit(
                          color: AppTheme.accent,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (qadaCount > 0)
                  Text(
                    '${l10n.remaining}: $qadaCount',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
              ],
            ),
          ),
          // Counter with +/- buttons
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12.0),
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
                  constraints: const BoxConstraints(minWidth: 40.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: Text(
                    '$qadaCount',
                    style: GoogleFonts.outfit(
                      color: qadaCount > 0
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontSize: 18.0,
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
        borderRadius: BorderRadius.circular(10.0),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: onPressed != null
                ? AppTheme.textPrimary
                : AppTheme.neutral,
            size: 20.0,
          ),
        ),
      ),
    );
  }
}
