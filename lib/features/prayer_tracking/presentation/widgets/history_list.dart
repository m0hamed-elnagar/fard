import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: ExpansionTile(
        key: const PageStorageKey('history_list_expansion'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
        childrenPadding: EdgeInsets.zero,
        iconColor: AppTheme.accent,
        collapsedIconColor: AppTheme.textSecondary,
        title: Row(
          children: [
            const Icon(Icons.history_rounded,
                color: AppTheme.accent, size: 20.0),
            const SizedBox(width: 12.0),
            Text(
              l10n.history,
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Text(
                '${records.length}',
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
          // Using a Column instead of ListView to avoid ScrollPosition restoration 
          // issues (bool vs double? cast errors) on Windows.
          Column(
            children: [
              for (int i = 0; i < records.length; i++) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onLongPress: () => _confirmDelete(context, records[i]),
                    child: _buildRecordItem(context, records[i]),
                  ),
                ),
                if (i < records.length - 1)
                  const Divider(height: 1.0, color: AppTheme.cardBorder),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, DailyRecord record) {
    final l10n = AppLocalizations.of(context)!;
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
                  ? AppTheme.primaryLight.withOpacity(0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10.0),
              border: isToday
                  ? Border.all(color: AppTheme.primaryLight.withOpacity(0.40))
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
                    if (record.missedToday.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppTheme.missed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          l10n.missedCount(record.missedToday.length),
                          style: GoogleFonts.amiri(
                            color: AppTheme.missed,
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6.0),
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
                const SizedBox(height: 6.0),
                // Per-salaah mini row
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: Salaah.values.map((s) {
                    final count = record.qada[s]?.value ?? 0;
                    final wasMissed = record.missedToday.contains(s);
                    // Only show if count > 0 or was missed
                    if (count == 0 && !wasMissed) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: wasMissed
                            ? AppTheme.missed.withOpacity(0.08)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: wasMissed
                              ? AppTheme.missed.withOpacity(0.20)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.localizedName(l10n),
                            style: GoogleFonts.amiri(
                              color: wasMissed
                                  ? AppTheme.missed
                                  : AppTheme.textSecondary,
                              fontSize: 10.0,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '$count',
                            style: GoogleFonts.outfit(
                              color: wasMissed
                                  ? AppTheme.missed
                                  : AppTheme.textPrimary,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
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
            ? TextDirection.rtl 
            : TextDirection.ltr,
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
              color: AppTheme.textSecondary.withOpacity(0.40), size: 20.0),
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
