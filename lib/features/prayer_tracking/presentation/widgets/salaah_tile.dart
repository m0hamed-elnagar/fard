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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: isMissedToday
            ? AppTheme.missed.withValues(alpha: 0.12)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isMissedToday
              ? AppTheme.missed.withValues(alpha: 0.4)
              : AppTheme.cardBorder,
          width: 1.5,
        ),
        boxShadow: [
          if (isMissedToday)
            BoxShadow(
              color: AppTheme.missed.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onToggleMissed,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Today Missed Status
                _StatusIndicator(
                  isMissed: isMissedToday,
                  onTap: onToggleMissed,
                ),
                const SizedBox(width: 12.0),
                
                // Stacked Counter Buttons
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CounterButton(
                        icon: Icons.add_rounded,
                        onPressed: onAdd,
                        color: AppTheme.primaryLight,
                      ),
                      Container(
                        width: 20,
                        height: 1,
                        color: AppTheme.cardBorder,
                      ),
                      _CounterButton(
                        icon: Icons.remove_rounded,
                        onPressed: qadaCount > 0 ? onRemove : null,
                        color: AppTheme.missed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                
                // Salaah Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        salaah.localizedName(l10n),
                        style: GoogleFonts.amiri(
                          color: AppTheme.textPrimary,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (time != null)
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: AppTheme.accent),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(time!),
                              style: GoogleFonts.outfit(
                                color: AppTheme.accent,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Qada Count Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: qadaCount > 0 
                      ? AppTheme.accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: qadaCount > 0 
                        ? AppTheme.accent.withValues(alpha: 0.3)
                        : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$qadaCount',
                        style: GoogleFonts.outfit(
                          color: qadaCount > 0
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${l10n.remaining}: $qadaCount',
                        style: GoogleFonts.outfit(
                          color: Colors.transparent,
                          fontSize: 0.01,
                        ),
                      ),
                      Text(
                        l10n.remaining.toLowerCase(),
                        style: GoogleFonts.outfit(
                          color: qadaCount > 0
                              ? AppTheme.accent.withValues(alpha: 0.7)
                              : AppTheme.neutral,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _StatusIndicator extends StatelessWidget {
  final bool isMissed;
  final VoidCallback onTap;

  const _StatusIndicator({required this.isMissed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 42.0,
      height: 42.0,
      decoration: BoxDecoration(
        color: isMissed
            ? AppTheme.missed
            : AppTheme.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isMissed ? AppTheme.missed : AppTheme.neutral,
          width: 2.0,
        ),
        boxShadow: [
          if (isMissed)
            BoxShadow(
              color: AppTheme.missed.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(
        isMissed ? Icons.close_rounded : Icons.check_rounded,
        color: isMissed ? Colors.white : AppTheme.neutral,
        size: 24.0,
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _CounterButton({
    required this.icon, 
    this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Icon(
          icon,
          color: onPressed != null
              ? color
              : AppTheme.neutral.withValues(alpha: 0.5),
          size: 22.0,
        ),
      ),
    );
  }
}
