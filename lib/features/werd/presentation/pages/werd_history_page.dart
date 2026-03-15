import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

enum HistoryPeriod { month }

class WerdHistoryPage extends StatefulWidget {
  const WerdHistoryPage({super.key});

  @override
  State<WerdHistoryPage> createState() => _WerdHistoryPageState();
}

class _WerdHistoryPageState extends State<WerdHistoryPage> {
  WerdUnit _displayUnit = WerdUnit.page;
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'سجل الورد' : 'Werd History',
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<WerdBloc, WerdState>(
        builder: (context, state) {
          final progress = state.progress;
          if (progress == null || (progress.history.isEmpty && progress.totalAmountReadToday == 0)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا يوجد سجل حتى الآن' : 'No history yet',
                    style: GoogleFonts.amiri(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final historyList = progress.history.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          // Calculate summary based on focused month
          int periodTotalAyahs = 0;
          double periodTotalPages = 0;
          double periodTotalJuz = 0;
          int periodDays = 0;
          
          final filteredHistory = <MapEntry<String, WerdHistoryEntry>>[];

          for (final entry in historyList) {
            final date = DateTime.parse(entry.key);
            
            // Only Month filtering now
            bool include = date.year == _focusedDate.year && date.month == _focusedDate.month;

            if (include) {
              periodTotalAyahs += entry.value.totalAyahsRead;
              periodTotalPages += entry.value.pagesRead;
              periodTotalJuz += entry.value.juzRead;
              if (entry.value.totalAyahsRead > 0) {
                periodDays++;
                filteredHistory.add(entry);
              }
            }
          }
          
          // Add today's progress to summary if it matches period
          final today = DateTime.now();
          final todayEntry = _calculateTodayEntry(progress);
          bool todayMatches = today.year == _focusedDate.year && today.month == _focusedDate.month;

          if (todayMatches) {
            periodTotalAyahs += progress.totalAmountReadToday;
            periodTotalPages += todayEntry.pagesRead;
            periodTotalJuz += todayEntry.juzRead;
            if (progress.totalAmountReadToday > 0) periodDays++;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMonthNavigator(isAr),
              const SizedBox(height: 16),
              _buildSummaryCard(context, isAr, periodTotalAyahs, periodTotalPages, periodTotalJuz, periodDays),
              const SizedBox(height: 24),
              Text(
                isAr ? 'التفاصيل' : 'Details',
                style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Today Item
              if (todayMatches && progress.totalAmountReadToday > 0)
                _buildHistoryItem(
                  context, 
                  isAr, 
                  today, 
                  todayEntry, 
                  isToday: true,
                  goal: state.goal,
                ),
              ..._buildListWithBreaks(context, isAr, filteredHistory, state.goal, 
                  (todayMatches && progress.totalAmountReadToday > 0) ? today : null),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildListWithBreaks(BuildContext context, bool isAr, List<MapEntry<String, WerdHistoryEntry>> items, WerdGoal? goal, DateTime? lastItemDate) {
    final widgets = <Widget>[];
    DateTime? prevDate = lastItemDate;

    for (int i = 0; i < items.length; i++) {
      final entry = items[i];
      final currentDate = DateTime.parse(entry.key);

      if (prevDate != null) {
        final diff = prevDate.difference(DateTime(currentDate.year, currentDate.month, currentDate.day)).inDays;
        if (diff > 1) {
          widgets.add(_buildStreakBreak(isAr));
        }
      }

      widgets.add(_buildHistoryItem(
        context, 
        isAr, 
        currentDate, 
        entry.value,
        goal: goal,
      ));
      
      prevDate = currentDate;
    }
    return widgets;
  }

  Widget _buildStreakBreak(bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(indent: 20, endIndent: 10)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_off_rounded, size: 14, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  isAr ? 'انقطاع' : 'Streak Break',
                  style: GoogleFonts.amiri(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(indent: 10, endIndent: 20)),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _navigateMonth(-1),
          icon: Icon(isAr ? Icons.chevron_left : Icons.chevron_right),
        ),
        const SizedBox(width: 16),
        Text(
          DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_focusedDate),
          style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _canNavigateNext() ? () => _navigateMonth(1) : null,
          icon: Icon(isAr ? Icons.chevron_right : Icons.chevron_left),
        ),
      ],
    );
  }

  bool _canNavigateNext() {
    final now = DateTime.now();
    return _focusedDate.year < now.year || (_focusedDate.year == now.year && _focusedDate.month < now.month);
  }

  void _navigateMonth(int delta) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + delta);
    });
  }

  WerdHistoryEntry _calculateTodayEntry(WerdProgress progress) {
    final startAbs = progress.sessionStartAbsolute ?? 1;
    final endAbs = progress.lastReadAbsolute ?? (startAbs - 1).clamp(1, 6236);
    final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
    final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(endAbs);
    
    final pagesRead = QuranHizbProvider.calculateFractionalProgress(progress.readItemsToday, WerdUnit.page);
    final juzRead = QuranHizbProvider.calculateFractionalProgress(progress.readItemsToday, WerdUnit.juz);
    
    final startSurahName = quran.getSurahName(startPos[0]);
    final endSurahName = quran.getSurahName(endPos[0]);
    
    return WerdHistoryEntry(
      totalAyahsRead: progress.totalAmountReadToday,
      startAbsolute: startAbs,
      endAbsolute: endAbs,
      pagesRead: pagesRead,
      juzRead: juzRead,
      startSurahName: startSurahName,
      startAyahNumber: startPos[1],
      endSurahName: endSurahName,
      endAyahNumber: endPos[1],
      summary: "Read today ${progress.totalAmountReadToday} ayahs",
    );
  }

  String _formatDecimal(double value, bool isAr, int decimalPlaces) {
    final formatted = value.toStringAsFixed(decimalPlaces);
    if (isAr) {
      return formatted.replaceAll('.', '٫').toArabicIndic();
    }
    return formatted;
  }

  String _getLocalizedSurahName(String rawName, int absoluteAyah, bool isAr) {
    final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(absoluteAyah);
    return isAr ? quran.getSurahNameArabic(pos[0]) : quran.getSurahName(pos[0]);
  }

  Widget _buildSummaryCard(BuildContext context, bool isAr, int totalAyahs, double totalPages, double totalJuz, int days) {
    String unitLabel;
    double avgValue;

    switch (_displayUnit) {
      case WerdUnit.page:
        unitLabel = isAr ? 'صفحة' : 'Page';
        avgValue = days > 0 ? totalPages / days : 0;
        break;
      case WerdUnit.juz:
        unitLabel = isAr ? 'جزء' : 'Juz';
        avgValue = days > 0 ? totalJuz / days : 0;
        break;
      case WerdUnit.ayah:
      default:
        unitLabel = isAr ? 'آية' : 'Ayah';
        avgValue = days > 0 ? totalAyahs / days : 0;
        break;
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              isAr ? 'ملخص الشهر' : 'Monthly Summary',
              style: GoogleFonts.amiri(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    isAr ? 'الآيات' : 'Ayahs',
                    totalAyahs.toArabicIndic(),
                    Icons.auto_stories_rounded,
                    isHighlighted: _displayUnit == WerdUnit.ayah,
                    onTap: () => setState(() => _displayUnit = WerdUnit.ayah),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    isAr ? 'الصفحات' : 'Pages',
                    _formatDecimal(totalPages, isAr, 1),
                    Icons.pages_rounded,
                    isHighlighted: _displayUnit == WerdUnit.page,
                    onTap: () => setState(() => _displayUnit = WerdUnit.page),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    isAr ? 'الأجزاء' : 'Juz',
                    _formatDecimal(totalJuz, isAr, 2),
                    Icons.grid_view_rounded,
                    isHighlighted: _displayUnit == WerdUnit.juz,
                    onTap: () => setState(() => _displayUnit = WerdUnit.juz),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  isAr 
                    ? "المتوسط اليومي: ${_formatDecimal(avgValue, isAr, _displayUnit == WerdUnit.ayah ? 0 : 2)} $unitLabel"
                    : "Daily Average: ${_displayUnit == WerdUnit.ayah ? avgValue.round() : avgValue.toStringAsFixed(2)} $unitLabel",
                  style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, {bool isHighlighted = false, VoidCallback? onTap}) {
    final color = isHighlighted ? Theme.of(context).colorScheme.primary : Colors.grey[600];
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: isHighlighted ? 24 : 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: isHighlighted ? 26 : 22, 
                fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.bold,
                color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.amiri(
                fontSize: 14, 
                color: color,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, bool isAr, DateTime date, WerdHistoryEntry entry, {bool isToday = false, WerdGoal? goal}) {
    double amount;
    String unitLabel;
    int decimals;
    double goalValue = 0;

    switch (_displayUnit) {
      case WerdUnit.page:
        amount = entry.pagesRead;
        unitLabel = isAr ? 'صفحة' : 'Page';
        decimals = 1;
        if (goal != null) {
           goalValue = QuranHizbProvider.calculateFractionalProgress(
             Set.from(List.generate(goal.valueInAyahs, (i) => i + 1)), 
             WerdUnit.page
           );
        }
        break;
      case WerdUnit.juz:
        amount = entry.juzRead;
        unitLabel = isAr ? 'جزء' : 'Juz';
        decimals = 2;
        if (goal != null) {
           goalValue = QuranHizbProvider.calculateFractionalProgress(
             Set.from(List.generate(goal.valueInAyahs, (i) => i + 1)), 
             WerdUnit.juz
           );
        }
        break;
      case WerdUnit.ayah:
      default:
        amount = entry.totalAyahsRead.toDouble();
        unitLabel = isAr ? 'آية' : 'Ayah';
        decimals = 0;
        goalValue = goal?.valueInAyahs.toDouble() ?? 0;
        break;
    }

    final isCompleted = goalValue > 0 && amount >= (goalValue - 0.01);
    final startSurah = _getLocalizedSurahName(entry.startSurahName, entry.startAbsolute, isAr);
    final endSurah = _getLocalizedSurahName(entry.endSurahName, entry.endAbsolute, isAr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCompleted ? Colors.amber : AppTheme.primaryLight).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded, 
              color: isCompleted ? Colors.amber : AppTheme.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? (isAr ? 'اليوم' : 'Today') : DateFormat('EEEE', isAr ? 'ar' : 'en').format(date),
                  style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('d MMMM', isAr ? 'ar' : 'en').format(date),
                  style: GoogleFonts.amiri(fontSize: 13, color: Colors.grey),
                ),
                if (entry.totalAyahsRead > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    isAr 
                      ? "من $startSurah ${entry.startAyahNumber.toArabicIndic()} إلى $endSurah ${entry.endAyahNumber.toArabicIndic()}"
                      : "From $startSurah ${entry.startAyahNumber} to $endSurah ${entry.endAyahNumber}",
                    style: GoogleFonts.amiri(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       if (_displayUnit != WerdUnit.page) ...[
                          Icon(Icons.pages_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            isAr 
                              ? "${_formatDecimal(entry.pagesRead, isAr, 1)} صفحات"
                              : "${entry.pagesRead.toStringAsFixed(1)} pages",
                            style: GoogleFonts.amiri(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                       ],
                       if (_displayUnit != WerdUnit.juz) ...[
                          Icon(Icons.grid_view_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            isAr
                              ? "${_formatDecimal(entry.juzRead, isAr, 2)} جزء"
                              : "${entry.juzRead.toStringAsFixed(2)} juz",
                            style: GoogleFonts.amiri(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                       ],
                       if (_displayUnit != WerdUnit.ayah) ...[
                          Icon(Icons.auto_stories_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            isAr
                              ? "${entry.totalAyahsRead.toArabicIndic()} آية"
                              : "${entry.totalAyahsRead} ayahs",
                            style: GoogleFonts.amiri(fontSize: 11, color: Colors.grey),
                          ),
                       ],
                    ],
                  ),
                ],
                if (entry.summary.isNotEmpty && !isToday) ...[
                   const SizedBox(height: 4),
                   Text(
                     entry.summary,
                     style: GoogleFonts.amiri(fontSize: 10, color: Colors.grey[400], fontStyle: FontStyle.italic),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                ]
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatDecimal(amount, isAr, decimals)} $unitLabel',
                style: GoogleFonts.amiri(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.amber[800] : null,
                ),
              ),
              if (goalValue > 0)
                Text(
                  '${(amount / goalValue * 100).round().toArabicIndic()}%',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
