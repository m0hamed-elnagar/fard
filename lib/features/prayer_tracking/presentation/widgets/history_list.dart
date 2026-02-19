import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class HistoryList extends StatelessWidget {
  final List<DailyRecord> records;
  final Function(DateTime) onDelete;

  const HistoryList({
    super.key,
    required this.records,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group records by month/year
    final Map<String, List<DailyRecord>> grouped = {};
    for (final r in records) {
      final key = DateFormat('MMMM yyyy', l10n.localeName).format(r.date);
      grouped.putIfAbsent(key, () => []).add(r);
    }

    final sortedKeys = grouped.keys.toList();

    return Column(
      children: sortedKeys.map((monthKey) {
        final monthRecords = grouped[monthKey]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: ExpansionTile(
            key: PageStorageKey('history_$monthKey'),
            initiallyExpanded: monthKey == sortedKeys.first,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            tilePadding: const EdgeInsets.fromLTRB(16.0, 8.0, 12.0, 8.0),
            title: Row(
              children: [
                const Icon(Icons.history_rounded, color: AppTheme.accent, size: 20.0),
                const SizedBox(width: 12.0),
                Text(
                  monthKey,
                  style: GoogleFonts.amiri(
                    color: AppTheme.textPrimary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Text(
                    '${monthRecords.length}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1.0, color: AppTheme.cardBorder),
              Column(
                children: [
                  for (int i = 0; i < monthRecords.length; i++) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onLongPress: () => _confirmDelete(context, monthRecords[i]),
                        child: _buildRecordItem(context, monthRecords[i]),
                      ),
                    ),
                    if (i < monthRecords.length - 1)
                      const Divider(height: 1.0, color: AppTheme.cardBorder),
                  ],
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordItem(BuildContext context, DailyRecord record) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTimeService = getIt<PrayerTimeService>();
    final settings = context.read<SettingsCubit>().state;
    
    // Get prayer times for this specific record date to accurately determine if passed
    final prayerTimes = (settings.latitude != null && settings.longitude != null)
        ? prayerTimeService.getPrayerTimes(
            latitude: settings.latitude!,
            longitude: settings.longitude!,
            method: settings.calculationMethod,
            madhab: settings.madhab,
            date: record.date,
          )
        : null;

    // A prayer is "missed" ONLY if it has passed and is NOT completed.
    // However, the record already stores missedToday and completedToday.
    // We should only show prayers that have PASSED their time.
    final passedPrayers = Salaah.values.where((s) => 
      prayerTimeService.isPassed(s, prayerTimes: prayerTimes, date: record.date)
    ).toList();

    // Actual missed count for the record based on what passed
    final actualMissedCount = record.missedToday.where((s) => passedPrayers.contains(s)).length;
    final performedToday = record.completedToday.where((s) => passedPrayers.contains(s)).length;

    var totalQada = record.qada.values.fold(0, (sum, c) => sum + c.value);
    final today = DateTime.now();
    final isToday = record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 44.0,
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryLight.withValues(alpha: 0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10.0),
              border: isToday
                  ? Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.40))
                  : Border.all(color: Colors.transparent, width: 0.0),
            ),
            child: Column(
              children: [
                Text(
                  '${record.date.day}',
                  style: GoogleFonts.outfit(
                    color: isToday ? AppTheme.primaryLight : AppTheme.textPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${record.date.month}/${record.date.year % 100}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Performed Count (Finished)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: AppTheme.saved.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '${l10n.localeName == 'ar' ? 'تم' : 'Done'} $performedToday',
                        style: GoogleFonts.amiri(
                          color: AppTheme.saved,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    if (actualMissedCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppTheme.missed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          l10n.missedCount(actualMissedCount),
                          style: GoogleFonts.amiri(
                            color: AppTheme.missed,
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${l10n.remaining}: $totalQada',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Per-salaah mini row
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: passedPrayers.map((s) {
                    final wasMissed = record.missedToday.contains(s);
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: wasMissed
                            ? AppTheme.missed.withValues(alpha: 0.08)
                            : AppTheme.saved.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: wasMissed
                              ? AppTheme.missed.withValues(alpha: 0.20)
                              : AppTheme.saved.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            wasMissed ? Icons.close_rounded : Icons.check_circle_rounded,
                            color: wasMissed ? AppTheme.missed : AppTheme.saved,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            s.localizedName(l10n),
                            style: GoogleFonts.amiri(
                              color: wasMissed ? AppTheme.missed : AppTheme.saved,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DailyRecord record) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar' 
            ? ui.TextDirection.rtl 
            : ui.TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            l10n.deleteRecord,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            l10n.deleteConfirm('${record.date.day}/${record.date.month}'),
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.amiri(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete(record.date);
              },
              child: Text(
                l10n.delete,
                style: GoogleFonts.amiri(
                  color: AppTheme.missed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.40), size: 20.0),
          const SizedBox(width: 8.0),
          Text(
            l10n.noHistory,
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
