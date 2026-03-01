import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SalaahTile extends StatefulWidget {
  final Salaah salaah;
  final int qadaCount;
  final int completedQadaCount;
  final bool isMissedToday;
  final bool isCompletedToday;
  final bool isUpcoming;
  final DateTime? time;
  final bool isQadaEnabled;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onToggleMissed;

  const SalaahTile({
    super.key,
    required this.salaah,
    required this.qadaCount,
    required this.completedQadaCount,
    required this.isMissedToday,
    required this.isCompletedToday,
    this.isUpcoming = false,
    this.time,
    this.isQadaEnabled = true,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleMissed,
  });

  @override
  State<SalaahTile> createState() => _SalaahTileState();
}

class _SalaahTileState extends State<SalaahTile> {
  int _removedInSession = 0;

  IconData _getSalaahIcon(Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr:
        return Icons.wb_twilight_rounded;
      case Salaah.dhuhr:
        return Icons.wb_sunny_rounded;
      case Salaah.asr:
        return Icons.wb_sunny_outlined;
      case Salaah.maghrib:
        return Icons.nightlight_round;
      case Salaah.isha:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isUpcoming
              ? [AppTheme.surface, AppTheme.surface]
              : widget.isCompletedToday
                  ? [
                      AppTheme.primaryLight.withValues(alpha: 0.15),
                      AppTheme.primaryLight.withValues(alpha: 0.05),
                    ]
                  : [
                      AppTheme.missed.withValues(alpha: 0.15),
                      AppTheme.missed.withValues(alpha: 0.05),
                    ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: widget.isUpcoming
              ? AppTheme.cardBorder.withValues(alpha: 0.5)
              : widget.isCompletedToday
                  ? AppTheme.primaryLight.withValues(alpha: 0.4)
                  : AppTheme.missed.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: !widget.isUpcoming 
                ? (widget.isCompletedToday ? AppTheme.primaryLight : AppTheme.missed).withValues(alpha: 0.1)
                : Colors.transparent,
            blurRadius: !widget.isUpcoming ? 10 : 0,
            offset: !widget.isUpcoming ? const Offset(0, 4) : Offset.zero,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: widget.isUpcoming ? null : () {
            HapticFeedback.lightImpact();
            if (widget.isCompletedToday && _removedInSession > 0) {
              setState(() {
                _removedInSession--;
              });
            }
            widget.onToggleMissed();
          },
          child: Opacity(
            opacity: widget.isUpcoming ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  // Today Missed Status
                  _StatusIndicator(
                    icon: _getSalaahIcon(widget.salaah),
                    isMissed: !widget.isUpcoming && !widget.isCompletedToday,
                    isCompleted: widget.isCompletedToday,
                    isUpcoming: widget.isUpcoming,
                    onTap: widget.isUpcoming ? () {} : () {
                      HapticFeedback.mediumImpact();
                      if (widget.isCompletedToday && _removedInSession > 0) {
                        setState(() {
                          _removedInSession--;
                        });
                      }
                      widget.onToggleMissed();
                    },
                  ),
                  const SizedBox(width: 16.0),

                  // Stacked Counter Buttons
                  if (widget.isQadaEnabled)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CounterButton(
                            icon: Icons.add_rounded,
                            onPressed: widget.isUpcoming ? null : () {
                              HapticFeedback.lightImpact();
                              if (_removedInSession > 0 || widget.completedQadaCount > 0) {
                                widget.onAdd();
                                if (_removedInSession > 0) {
                                  setState(() {
                                    _removedInSession--;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.useAddQadaToNewPrayers,
                                      style: GoogleFonts.outfit(color: Colors.white),
                                    ),
                                    backgroundColor: AppTheme.surfaceLight,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            color: (_removedInSession > 0 && !widget.isUpcoming)
                                ? AppTheme.primaryLight 
                                : AppTheme.neutral.withValues(alpha: 0.5),
                          ),
                          Container(
                            width: 20,
                            height: 1,
                            color: AppTheme.cardBorder,
                          ),
                          _CounterButton(
                            icon: Icons.remove_rounded,
                            onPressed: (widget.qadaCount > 0 && !widget.isUpcoming) ? () {
                              HapticFeedback.lightImpact();
                              widget.onRemove();
                              setState(() {
                                _removedInSession++;
                              });
                            } : null,
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
                          widget.salaah.localizedName(l10n),
                          style: GoogleFonts.amiri(
                            color: AppTheme.textPrimary,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (widget.time != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: AppTheme.accent),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormat.format(widget.time!),
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.accent,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Qada Count Display
                  if (widget.isQadaEnabled)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.completedQadaCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.completedQadaCount}',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryLight,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  l10n.done,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.7),
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: widget.qadaCount > 0 
                              ? AppTheme.accent.withValues(alpha: 0.1)
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: widget.qadaCount > 0 
                                ? AppTheme.accent.withValues(alpha: 0.3)
                                : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.qadaCount}',
                                style: GoogleFonts.outfit(
                                  color: widget.qadaCount > 0
                                      ? AppTheme.accent
                                      : AppTheme.textSecondary,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n.remaining.toLowerCase(),
                                style: GoogleFonts.outfit(
                                  color: widget.qadaCount > 0
                                      ? AppTheme.accent.withValues(alpha: 0.7)
                                      : AppTheme.neutral,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final bool isMissed;
  final bool isCompleted;
  final bool isUpcoming;
  final VoidCallback onTap;

  const _StatusIndicator({
    required this.icon,
    required this.isMissed,
    this.isCompleted = false,
    this.isUpcoming = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          color: isUpcoming
              ? Colors.transparent
              : isCompleted
                  ? AppTheme.primaryLight
                  : isMissed
                      ? AppTheme.missed
                      : AppTheme.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isUpcoming
                ? AppTheme.neutral.withValues(alpha: 0.3)
                : isCompleted
                    ? AppTheme.primaryLight
                    : isMissed
                        ? AppTheme.missed
                        : AppTheme.neutral.withValues(alpha: 0.5),
            width: 2.0,
          ),
        boxShadow: [
          BoxShadow(
            color: ((isMissed || isCompleted) && !isUpcoming)
                ? (isCompleted ? AppTheme.primaryLight : AppTheme.missed).withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: ((isMissed || isCompleted) && !isUpcoming) ? 10 : 0,
            spreadRadius: ((isMissed || isCompleted) && !isUpcoming) ? 1 : 0,
          ),
        ],
        ),
        child: Icon(
          isUpcoming ? icon : (isCompleted ? Icons.check_rounded : Icons.close_rounded),
          color: isUpcoming
              ? AppTheme.neutral.withValues(alpha: 0.5)
              : Colors.white,
          size: isUpcoming ? 22.0 : 26.0,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Icon(
          icon,
          color: onPressed != null
              ? color
              : AppTheme.neutral.withValues(alpha: 0.5),
          size: 24.0,
        ),
      ),
    );
  }
}
