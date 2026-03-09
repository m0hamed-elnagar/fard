import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PrayerTimesCard extends StatefulWidget {
  final PrayerTimes? prayerTimes;
  final DateTime selectedDate;
  final String? cityName;

  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
    required this.selectedDate,
    this.cityName,
  });

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  Timer? _timer;
  String _countdown = '';
  Salaah? _nextSalaah;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (widget.prayerTimes == null) return;

    final now = DateTime.now();
    DateTime? nextTime;
    Salaah? nextSalaah;

    for (final salaah in Salaah.values) {
      DateTime? time;
      switch (salaah) {
        case Salaah.fajr: time = widget.prayerTimes!.fajr; break;
        case Salaah.dhuhr: time = widget.prayerTimes!.dhuhr; break;
        case Salaah.asr: time = widget.prayerTimes!.asr; break;
        case Salaah.maghrib: time = widget.prayerTimes!.maghrib; break;
        case Salaah.isha: time = widget.prayerTimes!.isha; break;
      }

      if (time.isAfter(now)) {
        if (nextTime == null || time.isBefore(nextTime)) {
          nextTime = time;
          nextSalaah = salaah;
        }
      }
    }

    // If no prayer left today, check Fajr tomorrow
    if (nextTime == null) {
      // Adhan PrayerTimes usually doesn't have "tomorrow's Fajr" directly unless we recalculate
      // But for display purposes, we can just show "Fajr" as next if all today's are passed.
      nextSalaah = Salaah.fajr;
      // We don't have enough info here to calculate tomorrow's Fajr exactly without Coordinates and Params
      // However, we can approximate or just show '--:--:--' until tomorrow.
      // For now, let's just use today's Fajr + 24h as approximation or leave it.
      final todayFajr = widget.prayerTimes!.fajr;
      nextTime = todayFajr.add(const Duration(days: 1));
    }

    final diff = nextTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (mounted) {
      setState(() {
        _countdown = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        _nextSalaah = nextSalaah;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';
    final timeFormat = DateFormat('h:mm a');

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
              right: isAr ? null : -30,
              left: isAr ? -30 : null,
              top: -30,
              child: Opacity(
                opacity: 0.03,
                child: const Icon(Icons.mosque, size: 180, color: Colors.white),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.nextPrayer,
                                  style: GoogleFonts.amiri(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_nextSalaah != null)
                                  Text(
                                    _nextSalaah!.localizedName(l10n),
                                    style: GoogleFonts.amiri(
                                      color: AppTheme.accent,
                                      fontSize: isShort ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (widget.cityName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBorder.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppTheme.accent),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.cityName!,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary, 
                                        fontSize: 11, 
                                        fontWeight: FontWeight.bold
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(flex: 2),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isAr ? _countdown.toArabicIndic() : _countdown,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: isShort ? 36 : 42,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.remainingTime,
                                style: GoogleFonts.amiri(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      const Divider(height: 1, color: AppTheme.cardBorder),
                      const Spacer(flex: 1),
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          // Determine if we should use 1 or 2 rows for prayer times
                          final bool useSingleRow = gridConstraints.maxWidth > 400;
                          final bool isVeryNarrow = gridConstraints.maxWidth < 320;
                          
                          final List<MapEntry<String, DateTime?>> displayPrayers = [
                            MapEntry(l10n.fajr, widget.prayerTimes?.fajr),
                            MapEntry(l10n.sunrise, widget.prayerTimes?.sunrise),
                            MapEntry(l10n.dhuhr, widget.prayerTimes?.dhuhr),
                            MapEntry(l10n.asr, widget.prayerTimes?.asr),
                            MapEntry(l10n.maghrib, widget.prayerTimes?.maghrib),
                            MapEntry(l10n.isha, widget.prayerTimes?.isha),
                          ];

                          final itemWidth = useSingleRow 
                              ? (gridConstraints.maxWidth - 40) / 6
                              : (gridConstraints.maxWidth - 16) / 3;
                          
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: displayPrayers.map((entry) {
                              final name = entry.key;
                              final time = entry.value;
                              
                              final timeStr = time != null ? timeFormat.format(time) : null;
                              final isNext = _nextSalaah != null && name == _nextSalaah!.localizedName(l10n);
                              
                              return Container(
                                width: itemWidth,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isNext ? AppTheme.accent.withValues(alpha: 0.1) : AppTheme.cardBorder.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isNext ? AppTheme.accent.withValues(alpha: 0.4) : AppTheme.cardBorder.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        name,
                                        style: GoogleFonts.amiri(
                                          color: isNext ? AppTheme.accent : AppTheme.textSecondary,
                                          fontSize: isVeryNarrow ? 10 : 12,
                                          fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        timeStr != null ? (isAr ? timeStr.toArabicIndic() : timeStr) : '--:--',
                                        style: GoogleFonts.outfit(
                                          color: isNext ? AppTheme.textPrimary : AppTheme.textPrimary.withValues(alpha: 0.9),
                                          fontSize: isVeryNarrow ? 11 : 13,
                                          fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
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
