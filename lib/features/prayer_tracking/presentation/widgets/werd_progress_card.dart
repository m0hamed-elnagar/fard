import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/presentation/pages/werd_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

class WerdProgressCard extends StatefulWidget {
  final VoidCallback onSetGoalPressed;

  const WerdProgressCard({super.key, required this.onSetGoalPressed});

  @override
  State<WerdProgressCard> createState() => _WerdProgressCardState();
}

class _WerdProgressCardState extends State<WerdProgressCard> {
  WerdUnit _displayUnit = WerdUnit.ayah;

  double _convertValue(
    int ayahCount,
    WerdUnit unit,
    WerdGoal goal,
    bool isCurrent,
    WerdProgress? progress,
  ) {
    if (unit == WerdUnit.ayah) return ayahCount.toDouble();

    // If display unit matches goal unit and we are calculating the total part, use goal value exactly
    if (!isCurrent &&
        unit == goal.unit &&
        goal.type == WerdGoalType.fixedAmount) {
      return goal.value.toDouble();
    }

    if (isCurrent) {
      final readItems = progress?.readItemsToday ?? {};
      return QuranHizbProvider.calculateFractionalProgress(readItems, unit);
    } else {
      // For total value, we calculate how many fractional units are in the REQUIRED range
      final startAbs = progress?.sessionStartAbsolute ?? 1;
      final requiredCount = goal.valueInAyahs;
      final targetItems = Set<int>.from(
        List.generate(requiredCount, (i) => startAbs + i),
      );
      return QuranHizbProvider.calculateFractionalProgress(targetItems, unit);
    }
  }

  String _formatValue(double value, WerdUnit unit, bool isAr) {
    if (unit == WerdUnit.ayah) {
      final intVal = value.round();
      return isAr ? intVal.toArabicIndic() : intVal.toString();
    }
    // Check if it's almost an integer (to handle floating point precision issues)
    if ((value - value.round()).abs() < 0.05) {
      final intVal = value.round();
      return isAr ? intVal.toArabicIndic() : intVal.toString();
    }
    final formatted = value.toStringAsFixed(1);
    if (isAr) {
      // Replacing the decimal point with a more distinct Arabic comma or ensuring spacing
      return formatted.replaceAll('.', '٫').toArabicIndic();
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WerdBloc, WerdState>(
      builder: (context, state) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';

        if (state.goal == null) {
          return _buildNoGoalCard(context, isAr);
        }

        final progress = state.progress;
        final goal = state.goal!;

        int currentAyahs = progress?.totalAmountReadToday ?? 0;
        int totalAyahs = goal.valueInAyahs;
        final percent = totalAyahs > 0
            ? (currentAyahs / totalAyahs).clamp(0.0, 1.0)
            : 0.0;
        final isCompleted = currentAyahs >= totalAyahs;

        // Cumulative total including completed cycles
        // (These values are displayed via progress object in _buildHeader)
        final _cumulativeTotal = progress?.cumulativeTotalAyahs ?? currentAyahs;
        final _completedCycles = progress?.completedCycles ?? 0;

        final now = DateTime.now();
        final currentMonthKey =
            "${now.year}-${now.month.toString().padLeft(2, '0')}";

        // Accurate month totals by summing history and today's granular progress
        double monthTotalPages =
            progress?.history.entries
                .where((e) => e.key.startsWith(currentMonthKey))
                .fold(0.0, (sum, e) => sum! + e.value.pagesRead) ??
            0.0;
        monthTotalPages += QuranHizbProvider.calculateFractionalProgress(
          progress?.readItemsToday ?? {},
          WerdUnit.page,
        );

        double monthTotalJuz =
            progress?.history.entries
                .where((e) => e.key.startsWith(currentMonthKey))
                .fold(0.0, (sum, e) => sum! + e.value.juzRead) ??
            0.0;
        monthTotalJuz += QuranHizbProvider.calculateFractionalProgress(
          progress?.readItemsToday ?? {},
          WerdUnit.juz,
        );

        int monthTotalAyahs =
            progress?.history.entries
                .where((e) => e.key.startsWith(currentMonthKey))
                .fold(0, (sum, e) => sum! + e.value.totalAyahsRead) ??
            0;
        monthTotalAyahs += currentAyahs;

        // Fractional Calculations for Daily
        final displayCurrentVal = _convertValue(
          currentAyahs,
          _displayUnit,
          goal,
          true,
          progress,
        );
        final displayTotalVal = _convertValue(
          totalAyahs,
          _displayUnit,
          goal,
          false,
          progress,
        );

        // Month total based on display unit
        double displayMonthTotalVal;
        switch (_displayUnit) {
          case WerdUnit.page:
            displayMonthTotalVal = monthTotalPages;
            break;
          case WerdUnit.juz:
            displayMonthTotalVal = monthTotalJuz;
            break;
          case WerdUnit.ayah:
          default:
            displayMonthTotalVal = monthTotalAyahs.toDouble();
            break;
        }

        final displayCurrent = _formatValue(
          displayCurrentVal,
          _displayUnit,
          isAr,
        );
        final displayTotal = _formatValue(displayTotalVal, _displayUnit, isAr);
        final displayMonthTotal = _formatValue(
          displayMonthTotalVal,
          _displayUnit,
          isAr,
        );

        final unitLabel =
            {
              WerdUnit.ayah: isAr ? 'آية' : 'Ayah',
              WerdUnit.page: isAr ? 'صفحة' : 'Page',
              WerdUnit.juz: isAr ? 'جزء' : 'Juz',
            }[_displayUnit] ??
            (isAr ? 'آية' : 'Ayah');

        final last7Days = List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          final key =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final historyEntry = progress?.history[key];
          final amount =
              historyEntry?.totalAyahsRead ?? (i == 6 ? currentAyahs : 0);
          return MapEntry(date, amount);
        });

        // Calculate Target Location for today
        final startAbs = progress?.sessionStartAbsolute ?? 1;
        final targetEndAbs = (startAbs + totalAyahs - 1).clamp(1, 6236);
        final targetLocation = _getAyahInfo(targetEndAbs, isAr);

        // Days remaining if khatma
        String? remainingDaysText;
        if (goal.type == WerdGoalType.finishInDays) {
          final diff = now.difference(goal.startDate).inDays;
          final remaining = (goal.value - diff).clamp(0, goal.value);
          remainingDaysText = isAr
              ? 'متبقي ${remaining.toArabicIndic()} أيام'
              : '$remaining days left';
        }

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
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
                  bottom: -30,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 200,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isShort = constraints.maxHeight < 280;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isAr, progress, remainingDaysText),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          _buildMainProgress(
                            displayCurrent,
                            displayTotal,
                            unitLabel,
                            targetLocation,
                            isAr,
                            isShort,
                          ),
                          const Flexible(flex: 1, child: SizedBox(height: 4)),
                          _buildProgressBar(percent, isCompleted, isShort),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildMonthStats(
                                  isAr,
                                  displayMonthTotal,
                                  displayTotal,
                                  unitLabel,
                                  isShort,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildSmallChart(
                                last7Days,
                                totalAyahs,
                                now,
                                isAr,
                                isShort,
                              ),
                            ],
                          ),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          const Divider(height: 1, color: AppTheme.cardBorder),
                          const Flexible(flex: 1, child: SizedBox(height: 4)),
                          _buildFooter(context, progress, isAr, isShort),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isAr, dynamic progress, String? remainingDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAr ? 'الورد اليومي' : 'Daily Werd',
                style: GoogleFonts.amiri(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (remainingDays != null)
                Text(
                  remainingDays,
                  style: GoogleFonts.amiri(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if ((progress?.completedCycles ?? 0) > 0)
                Text(
                  isAr
                      ? '✅ أتممت القرآن ${(progress!.completedCycles ?? 0).toString().toArabicIndic()} ${progress.completedCycles == 1 ? 'مرة' : 'مرات'}'
                      : '✅ Completed Quran ${progress!.completedCycles ?? 0} ${progress.completedCycles == 1 ? 'time' : 'times'}',
                  style: GoogleFonts.amiri(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((progress?.streak ?? 0) > 0)
              _buildStreakBadge(isAr, progress!.streak),
            const SizedBox(width: 8),
            if ((progress?.segmentsToday.length ?? 0) > 0)
              _buildEditButton(context, progress!, isAr),
            const SizedBox(width: 8),
            _buildIconButton(Icons.history_rounded, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WerdHistoryPage()),
              );
            }, isAr ? 'السجل' : 'History'),
            _buildIconButton(
              Icons.settings_outlined,
              widget.onSetGoalPressed,
              isAr ? 'تعديل' : 'Edit',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitSelector(bool isAr, bool isShort) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBorder.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitChip(WerdUnit.ayah, isAr ? 'آية' : 'Ayah', isAr, isShort),
          _buildUnitChip(WerdUnit.page, isAr ? 'صفحة' : 'Page', isAr, isShort),
          _buildUnitChip(WerdUnit.juz, isAr ? 'جزء' : 'Juz', isAr, isShort),
        ],
      ),
    );
  }

  Widget _buildUnitChip(WerdUnit unit, String label, bool isAr, bool isShort) {
    final isSelected = _displayUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _displayUnit = unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isShort ? 6 : 10,
          vertical: isShort ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.amiri(
            color: isSelected ? AppTheme.onAccent : AppTheme.textSecondary,
            fontSize: isShort ? 10 : 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20, color: AppTheme.textSecondary),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(6),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildStreakBadge(bool isAr, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isAr ? streak.toArabicIndic() : streak.toString(),
            style: GoogleFonts.outfit(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, WerdProgress progress, bool isAr) {
    return Tooltip(
      message: isAr ? 'تعديل القراءة' : 'Edit Reading',
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () => _showEditDialog(context, progress, isAr),
          icon: Icon(Icons.edit_rounded, size: 20, color: AppTheme.accent),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(6),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WerdProgress progress, bool isAr) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.werdTodayReading),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress.segmentsToday.isEmpty)
                Text(l10n.werdNoSessions)
              else
                ...progress.segmentsToday.asMap().entries.map((entry) {
                  final index = entry.key;
                  final segment = entry.value;
                  
                  // DEBUG: Log segment data
                  debugPrint('📊 Segment $index: startAyah=${segment.startAyah}, endAyah=${segment.endAyah}, count=${segment.ayahsCount}');
                  
                  final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.startAyah);
                  final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.endAyah);
                  
                  // DEBUG: Log converted positions
                  debugPrint('📍 Start: Surah ${startPos[0]}, Ayah ${startPos[1]}');
                  debugPrint('📍 End: Surah ${endPos[0]}, Ayah ${endPos[1]}');
                  
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
                      ? l10n.werdSame
                      : (isAr 
                          ? '$endName، ${endPos[1].toArabicIndic()}' 
                          : '$endName ${endPos[1]}');

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Session badge with ayah count and time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 10, color: AppTheme.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.werdSession(index + 1),
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                l10n.werdAyahs(segment.ayahsCount),
                                style: GoogleFonts.outfit(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          // Session time info
                          if (segment.startTime != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: AppTheme.textSecondary.withValues(alpha: 0.6), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${segment.formattedStartTime} - ${segment.formattedEndTime}',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                                if (segment.durationMinutes != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${segment.durationMinutes} min)',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          // From row
                          Row(
                            children: [
                              Icon(Icons.back_hand_rounded, color: AppTheme.accent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                l10n.werdFrom,
                                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fromText, 
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          if (!isSingleAyah) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.arrow_forward_rounded, color: AppTheme.accent, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.werdTo,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    toText, 
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // EDIT button
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                onPressed: () {
                                  // Pop dialog first then open edit
                                  Navigator.of(dialogContext).pop();
                                  _showEditSegmentDialog(context, progress, index, segment, isAr);
                                },
                                tooltip: l10n.werdEditSegment,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              // DELETE button
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                color: Colors.red[300],
                                onPressed: () {
                                  // Perform action BEFORE popping dialog
                                  context.read<WerdBloc>().add(WerdEvent.removeSegment(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isAr ? 'تم حذف الجلسة' : 'Session removed'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  // THEN pop the dialog
                                  Navigator.of(dialogContext).pop();
                                },
                                tooltip: l10n.werdDelete,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const Divider(height: 24),

              // Add range button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Pop dialog first then open add range
                    Navigator.of(dialogContext).pop();
                    _showAddRangeDialog(context, progress, isAr);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.werdAddRange),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // DEBUG: Show raw SharedPreferences data
          TextButton.icon(
            onPressed: () async {
              debugPrint('🔍 Reading raw SharedPreferences data...');
              final prefs = await SharedPreferences.getInstance();
              final werdProgress = prefs.getString('werd_progress_default');
              final werdGoal = prefs.getString('werd_goal_default');
              
              debugPrint('╔══════════════════════════════════════════╗');
              debugPrint('📊 RAW SHARED PREFERENCES DATA');
              debugPrint('╠══════════════════════════════════════════╣');
              debugPrint('werd_progress_default:');
              debugPrint(werdProgress ?? '(not found)');
              debugPrint('');
              debugPrint('werd_goal_default:');
              debugPrint(werdGoal ?? '(not found)');
              debugPrint('╚══════════════════════════════════════════╝');
              
              if (werdProgress != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'تم عرض البيانات في السجل' : 'Raw data printed to logs'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.bug_report_rounded, size: 18),
            label: Text(isAr ? 'عرض البيانات' : 'Show Raw Data'),
          ),
          // DEBUG: Clear all today's data button
          TextButton.icon(
            onPressed: () async {
              debugPrint('🗑️ Clearing werd progress data from SharedPreferences...');
              
              // Use SharedPreferences since that's where the data is stored
              final prefs = await SharedPreferences.getInstance();
              
              // Find all werd progress keys
              final allKeys = prefs.getKeys();
              final werdKeys = allKeys.where((k) => 
                k.startsWith('werd_progress_') || k.startsWith('werd_goal_')
              ).toList();
              
              debugPrint('📋 Found ${werdKeys.length} werd keys: $werdKeys');
              
              for (final key in werdKeys) {
                await prefs.remove(key);
                debugPrint('✅ Deleted: $key');
              }
              
              debugPrint('✅ Cleared all werd progress data from SharedPreferences');
              
              // Close the dialog first
              Navigator.of(context).pop();
              
              // Force reload the BLoC with empty state
              context.read<WerdBloc>().add(const WerdEvent.load());
              
              debugPrint('🔄 Reloaded WerdBloc with empty state');
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم مسح البيانات بنجاح!' : 'Data cleared successfully!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red),
            label: Text(isAr ? 'مسح البيانات' : 'Clear All Data', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.werdClose),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSegmentDialog(
    BuildContext context,
    WerdProgress progress,
    int segmentIndex,
    ReadingSegment segment,
    bool isAr,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final startSurahs = List.generate(114, (i) => i + 1);
    final endSurahs = List.generate(114, (i) => i + 1);

    final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.startAyah);
    final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(segment.endAyah);

    int selectedStartSurah = startPos[0];
    int startAyah = startPos[1];
    int selectedEndSurah = endPos[0];
    int endAyah = endPos[1];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final startAyahCount = quran.getVerseCount(selectedStartSurah);
          final endAyahCount = quran.getVerseCount(selectedEndSurah);
          final fromAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedStartSurah, startAyah);
          final toAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedEndSurah, endAyah);
          final isReversed = fromAbs > toAbs;

          return AlertDialog(
            title: Text(l10n.werdEditSegment),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FROM section
                  Text(l10n.werdFrom, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedStartSurah,
                    decoration: InputDecoration(labelText: l10n.surah),
                    items: startSurahs.map((s) {
                      final name = isAr ? quran.getSurahNameArabic(s) : quran.getSurahName(s);
                      return DropdownMenuItem(value: s, child: Text('${s.toString().padLeft(3, '0')} | $name', overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedStartSurah = v!;
                      startAyah = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: startAyah.clamp(1, startAyahCount),
                    decoration: InputDecoration(labelText: l10n.ayah),
                    items: List.generate(startAyahCount, (i) => i + 1).map((a) {
                      return DropdownMenuItem(value: a, child: Text('$a'));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => startAyah = v!),
                  ),
                  const SizedBox(height: 16),
                  // TO section
                  Text(l10n.werdTo, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedEndSurah,
                    decoration: InputDecoration(labelText: l10n.surah),
                    items: endSurahs.map((s) {
                      final name = isAr ? quran.getSurahNameArabic(s) : quran.getSurahName(s);
                      return DropdownMenuItem(value: s, child: Text('${s.toString().padLeft(3, '0')} | $name', overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedEndSurah = v!;
                      endAyah = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: endAyah.clamp(1, endAyahCount),
                    decoration: InputDecoration(labelText: l10n.ayah),
                    items: List.generate(endAyahCount, (i) => i + 1).map((a) {
                      return DropdownMenuItem(value: a, child: Text('$a'));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => endAyah = v!),
                  ),
                  if (isReversed) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.werdRangeCorrected,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.werdCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final newFromAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedStartSurah, startAyah);
                  final newToAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedEndSurah, endAyah);

                  // Remove old segment
                  context.read<WerdBloc>().add(WerdEvent.removeSegment(segmentIndex));

                  // Add new segment (allow from > to for backward reading)
                  final start = newFromAbs < newToAbs ? newFromAbs : newToAbs;
                  final end = newFromAbs < newToAbs ? newToAbs : newFromAbs;
                  context.read<WerdBloc>().add(WerdEvent.trackRangeRead(start, end));

                  // Show SnackBar BEFORE popping dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAr ? 'تم تحديث الجلسة' : 'Segment updated'),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // THEN pop the dialog
                  Navigator.of(dialogContext).pop();
                },
                child: Text(l10n.werdUpdate),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddRangeDialog(BuildContext context, WerdProgress progress, bool isAr) async {
    final l10n = AppLocalizations.of(context)!;
    int selectedStartSurah = 1;
    int startAyah = 1;
    int selectedEndSurah = 1;
    int endAyah = 1;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final startAyahCount = quran.getVerseCount(selectedStartSurah);
          final endAyahCount = quran.getVerseCount(selectedEndSurah);
          final fromAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedStartSurah, startAyah);
          final toAbs = QuranHizbProvider.getAbsoluteAyahNumber(selectedEndSurah, endAyah);
          final isReversed = fromAbs > toAbs;
          final effectiveFrom = isReversed ? toAbs : fromAbs;
          final effectiveTo = isReversed ? fromAbs : toAbs;
          final ayahCount = (toAbs - fromAbs).abs() + 1;

          final fromSurahName = isAr
              ? quran.getSurahNameArabic(isReversed ? selectedEndSurah : selectedStartSurah)
              : quran.getSurahName(isReversed ? selectedEndSurah : selectedStartSurah);
          final toSurahName = isAr
              ? quran.getSurahNameArabic(isReversed ? selectedStartSurah : selectedEndSurah)
              : quran.getSurahName(isReversed ? selectedStartSurah : selectedEndSurah);

          return AlertDialog(
            title: Text(l10n.werdAddRange),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Range preview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.werdRangePreview(fromSurahName, startAyah, toSurahName, endAyah),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                            fontSize: 14,
                          ),
                        ),
                        if (isReversed) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.werdRangeCorrected,
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          l10n.werdWillAdd(ayahCount),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // FROM section
                  Text(l10n.werdFrom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedStartSurah,
                    decoration: InputDecoration(labelText: l10n.surah),
                    items: List.generate(114, (i) => i + 1).map((s) {
                      final name = isAr ? quran.getSurahNameArabic(s) : quran.getSurahName(s);
                      return DropdownMenuItem(value: s, child: Text('${s.toString().padLeft(3, '0')} | $name', overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedStartSurah = v!;
                      startAyah = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: startAyah,
                    decoration: InputDecoration(labelText: l10n.ayah),
                    items: List.generate(startAyahCount, (i) => i + 1).map((a) {
                      return DropdownMenuItem(value: a, child: Text('$a'));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => startAyah = v!),
                  ),
                  const SizedBox(height: 16),
                  // TO section
                  Text(l10n.werdTo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedEndSurah,
                    decoration: InputDecoration(labelText: l10n.surah),
                    items: List.generate(114, (i) => i + 1).map((s) {
                      final name = isAr ? quran.getSurahNameArabic(s) : quran.getSurahName(s);
                      return DropdownMenuItem(value: s, child: Text('${s.toString().padLeft(3, '0')} | $name', overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedEndSurah = v!;
                      endAyah = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: endAyah,
                    decoration: InputDecoration(labelText: l10n.ayah),
                    items: List.generate(endAyahCount, (i) => i + 1).map((a) {
                      return DropdownMenuItem(value: a, child: Text('$a'));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => endAyah = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.werdCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final start = effectiveFrom;
                  final end = effectiveTo;

                  // DEBUG: Log what we're about to save
                  debugPrint('💾 [Add Range Dialog] Saving:');
                  debugPrint('   effectiveFrom = $effectiveFrom');
                  debugPrint('   effectiveTo = $effectiveTo');
                  debugPrint('   start = $start');
                  debugPrint('   end = $end');
                  debugPrint('   Will call: WerdEvent.trackRangeRead($start, $end)');

                  context.read<WerdBloc>().add(WerdEvent.trackRangeRead(start, end));
                  
                  // Show SnackBar BEFORE popping dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr ? 'تمت إضافة $ayahCount آية' : 'Added $ayahCount ayahs',
                      ),
                    ),
                  );
                  
                  // THEN pop the dialog
                  Navigator.of(dialogContext).pop();
                },
                child: Text(l10n.werdAdd),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainProgress(
    String current,
    String total,
    String label,
    String targetLocation,
    bool isAr,
    bool isShort,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FittedBox(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      current,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: isShort ? 32 : 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ $total $label',
                      style: GoogleFonts.amiri(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: isShort ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildUnitSelector(isAr, isShort),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isAr
              ? 'الهدف اليوم: $targetLocation'
              : 'Target today: $targetLocation',
          style: GoogleFonts.amiri(
            color: AppTheme.accent.withValues(alpha: 0.8),
            fontSize: isShort ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percent, bool isCompleted, bool isShort) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: isShort ? 8 : 10,
            backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.amber : AppTheme.accent,
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Icon(
              Icons.check_circle,
              size: isShort ? 6 : 8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthStats(
    bool isAr,
    String total,
    String dailyTarget,
    String label,
    bool isShort,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'إحصائيات الشهر' : 'Month Stats',
          style: GoogleFonts.amiri(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
            fontSize: isShort ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total $label',
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isShort ? 14 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isAr ? '(الهدف: $dailyTarget)' : '(Goal: $dailyTarget)',
                style: GoogleFonts.amiri(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  fontSize: isShort ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallChart(
    List<MapEntry<DateTime, int>> data,
    int total,
    DateTime now,
    bool isAr,
    bool isShort,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isShort ? 8 : 12,
        vertical: isShort ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBorder.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((e) {
          final val = e.value;
          // Avoid division by zero and handle cases where total is 0
          final safeTotal = total > 0 ? total : 1;
          final maxH = isShort ? 24.0 : 36.0;
          final height = (val / safeTotal * maxH).clamp(4.0, maxH);
          final isToday = e.key.day == now.day;

          return Tooltip(
            message: isAr
                ? '${DateFormat('EEEE', 'ar').format(e.key)}: ${val.toArabicIndic()}'
                : '${DateFormat('EEEE', 'en').format(e.key)}: $val',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: isShort ? 8 : 10,
                        height: maxH,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBorder.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: isShort ? 8 : 10,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isToday
                                ? [Colors.amber, Colors.orange]
                                : [
                                    AppTheme.accent,
                                    AppTheme.accent.withValues(alpha: 0.7),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isToday
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (!isShort) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 12,
                      child: Text(
                        DateFormat(
                          'E',
                          isAr ? 'ar' : 'en',
                        ).format(e.key).substring(0, 1),
                        style: GoogleFonts.outfit(
                          color: isToday
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    WerdProgress? progress,
    bool isAr,
    bool isShort,
  ) {
    // NEW Continue Logic (per agreed plan):
    // 1. If finished Quran (completedCycles > 0 and at ayah 6236) → go to ayah 1
    // 2. If has lastReadAbsolute → go to NEXT ayah (lastReadAbs + 1)
    // 3. First time → go to ayah 1
    int targetAbs;

    final completedCycles = progress?.completedCycles ?? 0;
    final lastReadAbs = progress?.lastReadAbsolute;

    if (completedCycles > 0 && lastReadAbs == 6236) {
      // Just finished Quran, start new cycle
      targetAbs = 1;
    } else if (lastReadAbs != null) {
      // Has progress, continue from NEXT position (not the last read ayah itself)
      targetAbs = (lastReadAbs + 1 > 6236) ? 1 : lastReadAbs + 1;
    } else {
      // First time user or no progress
      targetAbs = 1;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'المكان الحالي' : 'Current Position',
                style: GoogleFonts.amiri(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: isShort ? 10 : 12,
                ),
              ),
              Text(
                _getAyahInfo(targetAbs, isAr),
                style: GoogleFonts.amiri(
                  color: AppTheme.textPrimary,
                  fontSize: isShort ? 13 : 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: isShort ? 36 : 42,
          child: ElevatedButton.icon(
            onPressed: () {
              final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
                targetAbs,
              );
              
              // Start a new session when clicking Continue
              context.read<WerdBloc>().add(WerdEvent.startSession(targetAbs));
              
              Navigator.push(
                context,
                QuranReaderPage.route(surahNumber: pos[0], ayahNumber: pos[1]),
              );
            },
            icon: Icon(Icons.play_arrow_rounded, size: isShort ? 18 : 20),
            label: Text(
              isAr ? 'متابعة' : 'Continue',
              style: TextStyle(fontSize: isShort ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(horizontal: isShort ? 12 : 20),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  String _getAyahInfo(int abs, bool isAr) {
    if (abs <= 0) return isAr ? 'الفاتحة، ١' : 'Al-Fatihah, 1';
    final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(abs);
    final surahName = isAr
        ? quran.getSurahNameArabic(pos[0])
        : quran.getSurahName(pos[0]);
    return isAr
        ? '$surahName، ${pos[1].toArabicIndic()}'
        : '$surahName, ${pos[1]}';
  }

  Widget _buildNoGoalCard(BuildContext context, bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAr ? 'ابدأ رحلتك مع القرآن' : 'Start Your Quran Journey',
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? 'حدد وردك اليومي وتابع تقدمك بسهولة'
                  : 'Set your daily werd and track your progress easily',
              style: GoogleFonts.amiri(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.onSetGoalPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                elevation: 4,
              ),
              child: Text(
                isAr ? 'تحديد ورد الآن' : 'Set Goal Now',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
