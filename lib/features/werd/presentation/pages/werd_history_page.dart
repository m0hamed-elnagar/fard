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
  final Set<int> _expandedItems = {};

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
          if (progress == null ||
              (progress.history.isEmpty &&
                  progress.totalAmountReadToday == 0)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
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
            bool include =
                date.year == _focusedDate.year &&
                date.month == _focusedDate.month;

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
          bool todayMatches =
              today.year == _focusedDate.year &&
              today.month == _focusedDate.month;

          if (todayMatches) {
            periodTotalAyahs += progress.totalAmountReadToday;
            periodTotalPages += todayEntry.pagesRead;
            periodTotalJuz += todayEntry.juzRead;
            if (progress.totalAmountReadToday > 0) periodDays++;
          }

          // Check if we have any data to show
          final hasData = (todayMatches && progress.totalAmountReadToday > 0) ||
              filteredHistory.isNotEmpty;

          // Check if focused month is the current month
          final now = DateTime.now();
          final isCurrentMonth =
              _focusedDate.year == now.year && _focusedDate.month == now.month;

          if (!hasData) {
            return Column(
              children: [
                _buildMonthNavigator(isAr),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isAr ? 'لا يوجد قراءة في هذا الشهر' : 'No reading this month',
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAr
                                ? 'ابدأ بقراءة القرآن لتتبع تقدمك هنا'
                                : 'Start reading Quran to track your progress here',
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Only show "Start Reading" button for the current month
                          if (isCurrentMonth) ...[
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(isAr ? 'ابدأ القراءة' : 'Start Reading'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: AppTheme.onAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMonthNavigator(isAr),
              const SizedBox(height: 16),
              _buildSummaryCard(
                context,
                isAr,
                periodTotalAyahs,
                periodTotalPages,
                periodTotalJuz,
                periodDays,
              ),
              const SizedBox(height: 24),
              // Section header with yellow accent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isAr ? 'التفاصيل' : 'Details',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (filteredHistory.isNotEmpty || (todayMatches && progress.totalAmountReadToday > 0))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.cardBorder.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        isAr
                            ? '${periodDays.toArabicIndic()} ${isAr ? 'أيام' : 'days'}'
                            : '$periodDays days',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Today Item
              if (todayMatches && progress.totalAmountReadToday > 0)
                _buildHistoryItem(
                  context,
                  isAr,
                  today,
                  todayEntry,
                  isToday: true,
                  goal: state.goal,
                  itemIndex: 0,
                  segments: progress.segmentsToday,
                ),
              ..._buildListWithBreaks(
                context,
                isAr,
                filteredHistory,
                state.goal,
                (todayMatches && progress.totalAmountReadToday > 0)
                    ? today
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildListWithBreaks(
    BuildContext context,
    bool isAr,
    List<MapEntry<String, WerdHistoryEntry>> items,
    WerdGoal? goal,
    DateTime? lastItemDate,
  ) {
    final widgets = <Widget>[];
    DateTime? prevDate = lastItemDate;
    int itemIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final entry = items[i];
      final currentDate = DateTime.parse(entry.key);

      if (prevDate != null) {
        final diff = prevDate
            .difference(
              DateTime(currentDate.year, currentDate.month, currentDate.day),
            )
            .inDays;
        if (diff > 1) {
          widgets.add(_buildStreakBreak(isAr));
        }
      }

      widgets.add(
        _buildHistoryItem(
          context,
          isAr,
          currentDate,
          entry.value,
          goal: goal,
          itemIndex: itemIndex,
        ),
      );
      itemIndex++;

      prevDate = currentDate;
    }
    return widgets;
  }

  Widget _buildStreakBreak(bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.missed.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.missed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.missed.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_off_rounded,
                  size: 14,
                  color: AppTheme.missed,
                ),
                const SizedBox(width: 6),
                Text(
                  isAr ? 'انقطاع' : 'Missed',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.missed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.missed.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMonthNavigator(bool isAr) {
    final now = DateTime.now();
    final isCurrentMonth = _focusedDate.year == now.year &&
        _focusedDate.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous month button
          _buildMonthButton(
            icon: isAr ? Icons.chevron_left : Icons.chevron_right,
            onPressed: () => _navigateMonth(-1),
            isEnabled: true,
          ),
          const SizedBox(width: 16),
          // Month label
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_focusedDate),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          // Next month button
          _buildMonthButton(
            icon: isAr ? Icons.chevron_right : Icons.chevron_left,
            onPressed: _canNavigateNext() ? () => _navigateMonth(1) : null,
            isEnabled: _canNavigateNext(),
          ),
          // Current month indicator
          if (isCurrentMonth) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isAr ? 'الحالي' : 'Current',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled ? AppTheme.surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? AppTheme.cardBorder.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppTheme.textPrimary : AppTheme.neutral.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  bool _canNavigateNext() {
    final now = DateTime.now();
    return _focusedDate.year < now.year ||
        (_focusedDate.year == now.year && _focusedDate.month < now.month);
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

    final pagesRead = QuranHizbProvider.calculateFractionalProgress(
      progress.readItemsToday,
      WerdUnit.page,
    );
    final juzRead = QuranHizbProvider.calculateFractionalProgress(
      progress.readItemsToday,
      WerdUnit.juz,
    );

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
      segmentCount: progress.segmentsToday.length,
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

  Widget _buildSummaryCard(
    BuildContext context,
    bool isAr,
    int totalAyahs,
    double totalPages,
    double totalJuz,
    int days,
  ) {
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

    // Hero card with subtle yellow/green accent based on completion
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AppTheme.accent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isAr ? 'ملخص الشهر' : 'Monthly Summary',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stat items with responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 300;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 3,
                    child: _buildHeroStatItem(
                      context,
                      isAr ? 'الآيات' : 'Ayahs',
                      totalAyahs.toArabicIndic(),
                      Icons.auto_stories_rounded,
                      isSelected: _displayUnit == WerdUnit.ayah,
                      onTap: () => setState(() => _displayUnit = WerdUnit.ayah),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 3,
                    child: _buildHeroStatItem(
                      context,
                      isAr ? 'الصفحات' : 'Pages',
                      _formatDecimal(totalPages, isAr, 1),
                      Icons.pages_rounded,
                      isSelected: _displayUnit == WerdUnit.page,
                      onTap: () => setState(() => _displayUnit = WerdUnit.page),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 3,
                    child: _buildHeroStatItem(
                      context,
                      isAr ? 'الأجزاء' : 'Juz',
                      _formatDecimal(totalJuz, isAr, 2),
                      Icons.grid_view_rounded,
                      isSelected: _displayUnit == WerdUnit.juz,
                      onTap: () => setState(() => _displayUnit = WerdUnit.juz),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Average daily progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.cardBorder.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: AppTheme.neutral,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isAr
                        ? "المتوسط اليومي: ${_displayUnit == WerdUnit.ayah ? avgValue.round().toArabicIndic() : _formatDecimal(avgValue, isAr, 2)} $unitLabel"
                        : "Daily Avg: ${_displayUnit == WerdUnit.ayah ? avgValue.round() : _formatDecimal(avgValue, isAr, 2)} $unitLabel",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.neutral,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accent : AppTheme.neutral,
              size: isSelected ? 26 : 22,
            ),
            const SizedBox(height: 8),
            // Big number in yellow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Label in gray
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppTheme.neutral,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    bool isAr,
    DateTime date,
    WerdHistoryEntry entry, {
    bool isToday = false,
    WerdGoal? goal,
    int itemIndex = 0,
    List<dynamic>? segments,
  }) {
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
            WerdUnit.page,
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
            WerdUnit.juz,
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
    final progressPercent = goalValue > 0 ? (amount / goalValue).clamp(0.0, 1.0) : 0.0;
    final startSurah = _getLocalizedSurahName(
      entry.startSurahName,
      entry.startAbsolute,
      isAr,
    );
    final endSurah = _getLocalizedSurahName(
      entry.endSurahName,
      entry.endAbsolute,
      isAr,
    );

    // SWAPPED: Green = completed, Yellow = in-progress
    Color accentColor;
    Color backgroundColor;
    Color borderColor;
    
    if (isCompleted) {
      // Completed: GREEN (success)
      accentColor = const Color(0xFF4CAF50);
      backgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.08);
      borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.4);
    } else if (progressPercent > 0) {
      // In-progress: YELLOW (encouraging)
      accentColor = AppTheme.accent;
      backgroundColor = AppTheme.accent.withValues(alpha: 0.06);
      borderColor = AppTheme.accent.withValues(alpha: 0.25);
    } else {
      // No progress: Gray
      accentColor = AppTheme.neutral;
      backgroundColor = Colors.transparent;
      borderColor = AppTheme.cardBorder.withValues(alpha: 0.2);
    }

    final isExpanded = _expandedItems.contains(itemIndex);
    final canExpand = entry.segmentCount > 1 && (isToday || segments != null);

    return GestureDetector(
      onTap: canExpand ? () {
        setState(() {
          if (isExpanded) {
            _expandedItems.remove(itemIndex);
          } else {
            _expandedItems.add(itemIndex);
          }
        });
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isCompleted ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.menu_book_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isToday
                                      ? (isAr ? 'اليوم' : 'Today')
                                      : DateFormat('EEEE', isAr ? 'ar' : 'en').format(date),
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('d MMMM', isAr ? 'ar' : 'en').format(date),
                                  style: GoogleFonts.amiri(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (entry.totalAyahsRead > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          isAr
                              ? "من $startSurah ${entry.startAyahNumber.toArabicIndic()} إلى $endSurah ${entry.endAyahNumber.toArabicIndic()}"
                              : "From $startSurah ${entry.startAyahNumber} to $endSurah ${entry.endAyahNumber}",
                          style: GoogleFonts.amiri(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatDecimal(amount, isAr, decimals)} $unitLabel',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    if (goalValue > 0)
                      Text(
                        '${(progressPercent * 100).round().toArabicIndic()}%',
                        style: GoogleFonts.outfit(fontSize: 12, color: accentColor.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
              ],
            ),
            // Progress bar for goal completion
            if (goalValue > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 6,
                  backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
            // Additional stats badges - using Wrap to prevent overflow
            if (entry.totalAyahsRead > 0) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (entry.segmentCount > 1)
                    _buildCompactBadge(
                      icon: Icons.timeline_rounded,
                      label: isAr
                          ? '${entry.segmentCount.toArabicIndic()} جلسات'
                          : '${entry.segmentCount} sessions',
                      color: accentColor,
                    ),
                  if (_displayUnit != WerdUnit.page)
                    _buildCompactBadge(
                      icon: Icons.pages_rounded,
                      label: isAr
                          ? "${_formatDecimal(entry.pagesRead, isAr, 1)} صفحات"
                          : "${entry.pagesRead.toStringAsFixed(1)} pages",
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                  if (_displayUnit != WerdUnit.juz)
                    _buildCompactBadge(
                      icon: Icons.grid_view_rounded,
                      label: isAr
                          ? "${_formatDecimal(entry.juzRead, isAr, 2)} جزء"
                          : "${entry.juzRead.toStringAsFixed(2)} juz",
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                  if (_displayUnit != WerdUnit.ayah)
                    _buildCompactBadge(
                      icon: Icons.auto_stories_rounded,
                      label: isAr
                          ? "${entry.totalAyahsRead.toArabicIndic()} آية"
                          : "${entry.totalAyahsRead} ayahs",
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ],
            // Expandable session details
            if (isExpanded && entry.segmentCount > 1) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                isAr ? 'تفاصيل الجلسات' : 'Session Details',
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              // Show real session details for today
              if (isToday && segments != null && segments.isNotEmpty)
                ...segments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final segment = entry.value;
                  
                  // Assuming segment has startAyah, endAyah, startTime, endTime
                  final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.startAyah);
                  final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.endAyah);
                  
                  final startName = isAr
                      ? quran.getSurahNameArabic(startPos[0])
                      : quran.getSurahName(startPos[0]);
                  final endName = isAr
                      ? quran.getSurahNameArabic(endPos[0])
                      : quran.getSurahName(endPos[0]);
                  
                  final isSingleAyah = segment.startAyah == segment.endAyah;
                  final fromText = isAr
                      ? '$startName، ${startPos[1].toArabicIndic()}'
                      : '$startName ${startPos[1]}';
                  final toText = isSingleAyah
                      ? (isAr ? 'نفس الآية' : 'Same ayah')
                      : (isAr
                          ? '$endName، ${endPos[1].toArabicIndic()}'
                          : '$endName ${endPos[1]}');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Session header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAr ? 'جلسة ${index + 1}' : 'Session ${index + 1}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              isAr
                                  ? '${(segment.endAyah - segment.startAyah + 1).toString().toArabicIndic()} آية'
                                  : '${segment.endAyah - segment.startAyah + 1} ayahs',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Time info
                        if (segment.startTime != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${segment.formattedStartTime} - ${segment.formattedEndTime}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                ),
                              ),
                              if (segment.durationMinutes != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${segment.durationMinutes} min)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        // From/To
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.back_hand_rounded, size: 14, color: accentColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fromText,
                                style: GoogleFonts.amiri(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (!isSingleAyah) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.arrow_forward_rounded, size: 12, color: accentColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  toText,
                                  style: GoogleFonts.amiri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              // Message for past days
              if (!isToday || segments == null || segments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'تتوفر تفاصيل الجلسة للجلسات الحالية فقط'
                              : 'Detailed session history available for current day only',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.amiri(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
