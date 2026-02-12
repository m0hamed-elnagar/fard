import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          childrenPadding: EdgeInsets.zero,
          iconColor: AppTheme.accent,
          collapsedIconColor: AppTheme.textSecondary,
          title: Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: AppTheme.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                'سجل الشهر',
                style: GoogleFonts.amiri(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  '${records.length}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1, color: AppTheme.cardBorder),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppTheme.cardBorder),
              itemBuilder: (context, index) {
                final record = records[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onLongPress: () => _confirmDelete(context, record),
                    child: _buildRecordItem(record),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(DailyRecord record) {
    var totalQada = record.qada.values.fold(0, (sum, c) => sum + c.value);
    final today = DateTime.now();
    final isToday = record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryLight.withValues(alpha: 0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4))
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  '${record.date.day}',
                  style: GoogleFonts.outfit(
                    color: isToday ? AppTheme.primaryLight : AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${record.date.month}/${record.date.year % 100}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.missed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'فاتت ${record.missedToday.length}',
                          style: GoogleFonts.amiri(
                            color: AppTheme.missed,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    const Spacer(),
                    Text(
                      'المتبقي: $totalQada',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Per-salaah mini row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: Salaah.values.map((s) {
                    final count = record.qada[s]?.value ?? 0;
                    final wasMissed = record.missedToday.contains(s);
                    // Only show if count > 0 or was missed
                    if (count == 0 && !wasMissed) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: wasMissed
                            ? AppTheme.missed.withValues(alpha: 0.08)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: wasMissed
                              ? AppTheme.missed.withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.label,
                            style: GoogleFonts.amiri(
                              color: wasMissed
                                  ? AppTheme.missed
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: GoogleFonts.outfit(
                              color: wasMissed
                                  ? AppTheme.missed
                                  : AppTheme.textPrimary,
                              fontSize: 11,
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
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            'حذف السجل',
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف سجل يوم ${record.date.day}/${record.date.month}؟',
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.amiri(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete(record.date);
              },
              child: Text(
                'حذف',
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 20),
          const SizedBox(width: 8),
          Text(
            'لا يوجد سجل لهذا الشهر',
            style: GoogleFonts.amiri(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
