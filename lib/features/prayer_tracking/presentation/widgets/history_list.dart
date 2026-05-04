import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class HistoryList extends StatelessWidget {
  final List<DailyRecord> records;
  final Function(DateTime) onDelete;
  final Function(DateTime)? onTap;

  const HistoryList({
    super.key,
    required this.records,
    required this.onDelete,
    this.onTap,
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
        return _MonthGroupSection(
          monthKey: monthKey,
          records: monthRecords,
          onTap: onTap,
          onDelete: (record) => _confirmDelete(context, record),
        );
      }).toList(),
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
          backgroundColor: context.surfaceContainerColor,
          title: Text(
            l10n.deleteRecord,
            style: GoogleFonts.amiri(
              color: context.onSurfaceColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            l10n.deleteConfirm('${record.date.day}/${record.date.month}'),
            style: GoogleFonts.amiri(color: context.onSurfaceVariantColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.amiri(color: context.onSurfaceVariantColor),
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
                  color: context.errorColor,
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
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.outlineColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            color: context.onSurfaceVariantColor.withValues(alpha: 0.40),
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            l10n.noHistory,
            style: GoogleFonts.amiri(
              color: context.onSurfaceVariantColor,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGroupSection extends StatelessWidget {
  final String monthKey;
  final List<DailyRecord> records;
  final Function(DateTime)? onTap;
  final Function(DailyRecord) onDelete;

  const _MonthGroupSection({
    required this.monthKey,
    required this.records,
    this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: context.backgroundColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey('history_$monthKey'),
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        tilePadding: const EdgeInsets.fromLTRB(16.0, 8.0, 12.0, 8.0),
        title: Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: context.secondaryColor,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Text(
              monthKey,
              style: GoogleFonts.amiri(
                color: context.onSurfaceColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: context.surfaceContainerHighestColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: context.outlineColor),
              ),
              child: Text(
                '${records.length}',
                style: GoogleFonts.outfit(
                  color: context.onSurfaceVariantColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1.0),
          for (int i = 0; i < records.length; i++) ...[
            _HistoryRecordTile(
              record: records[i],
              onTap: () => onTap?.call(records[i].date),
              onLongPress: () => onDelete(records[i]),
            ),
            if (i < records.length - 1) const Divider(height: 1.0),
          ],
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class _HistoryRecordTile extends StatelessWidget {
  final DailyRecord record;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryRecordTile({
    required this.record,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTimeService = getIt<PrayerTimeService>();

    return BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
      builder: (context, locationState) {
        return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
          builder: (context, remindersState) {
            var totalQada = record.qada.values.fold(0, (sum, c) => sum + c.value);
            final today = DateTime.now();
            final isToday =
                record.date.year == today.year &&
                record.date.month == today.month &&
                record.date.day == today.day;

            final prayerTimes = (isToday &&
                    locationState.latitude != null &&
                    locationState.longitude != null)
                ? prayerTimeService.getPrayerTimes(
                    latitude: locationState.latitude!,
                    longitude: locationState.longitude!,
                    method: locationState.calculationMethod,
                    madhab: locationState.madhab,
                    date: record.date,
                  )
                : null;

            final passedPrayers = Salaah.values
                .where(
                  (s) => prayerTimeService.isPassed(
                    s,
                    prayerTimes: prayerTimes,
                    date: record.date,
                  ),
                )
                .toList();

            final actualMissedCount = passedPrayers
                .where((s) => !record.completedToday.contains(s))
                .length;
            final performedToday = record.completedToday
                .where((s) => passedPrayers.contains(s))
                .length;
            final qadaCompletedToday = record.completedQada.values.fold(
              0,
              (sum, val) => sum + val,
            );

            return InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge
                    Container(
                      width: 44.0,
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isToday
                            ? context.primaryContainerColor
                                .withValues(alpha: 0.15)
                            : context.surfaceContainerHighestColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: isToday
                            ? Border.all(
                                color: context.primaryContainerColor.withValues(
                                  alpha: 0.40,
                                ),
                              )
                            : Border.all(color: Colors.transparent, width: 0.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${record.date.day}',
                            style: GoogleFonts.outfit(
                              color: isToday
                                  ? context.primaryContainerColor
                                  : context.onSurfaceColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${record.date.month}/${record.date.year % 100}',
                            style: GoogleFonts.outfit(
                              color: context.onSurfaceVariantColor,
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
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 8.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Performed Count (Finished)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  '${l10n.localeName == 'ar' ? 'تم' : 'Done'} $performedToday',
                                  style: GoogleFonts.amiri(
                                    color: context.primaryColor,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (remindersState.isQadaEnabled &&
                                  qadaCompletedToday > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.primaryContainerColor
                                        .withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    '${l10n.localeName == 'ar' ? 'قضاء' : 'Qada'} $qadaCompletedToday',
                                    style: GoogleFonts.amiri(
                                      color: context.primaryContainerColor,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (actualMissedCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.errorColor
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    l10n.missedCount(actualMissedCount),
                                    style: GoogleFonts.amiri(
                                      color: context.errorColor,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ),
                              if (remindersState.isQadaEnabled)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    '${l10n.remaining}: $totalQada',
                                    style: GoogleFonts.outfit(
                                      color: context.onSurfaceVariantColor,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          // Per-salaah mini row
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            children: passedPrayers.map((s) {
                              final wasCompleted =
                                  record.completedToday.contains(s);
                              final wasMissed = !wasCompleted;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: wasMissed
                                      ? context.errorColor
                                          .withValues(alpha: 0.08)
                                      : context.primaryColor
                                          .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: wasMissed
                                        ? context.errorColor
                                            .withValues(alpha: 0.20)
                                        : context.primaryColor
                                            .withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      wasMissed
                                          ? Icons.close_rounded
                                          : Icons.check_circle_rounded,
                                      color: wasMissed
                                          ? context.errorColor
                                          : context.primaryColor,
                                      size: 14.0,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      s.localizedName(l10n),
                                      style: GoogleFonts.amiri(
                                        color: wasMissed
                                            ? context.errorColor
                                            : context.primaryColor,
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
              ),
            );
          },
        );
      },
    );
  }
}
