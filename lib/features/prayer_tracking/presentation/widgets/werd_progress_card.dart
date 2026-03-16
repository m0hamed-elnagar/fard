import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/presentation/pages/werd_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quran/quran.dart' as quran;

class WerdProgressCard extends StatefulWidget {
  final VoidCallback onSetGoalPressed;

  const WerdProgressCard({
    super.key,
    required this.onSetGoalPressed,
  });

  @override
  State<WerdProgressCard> createState() => _WerdProgressCardState();
}

class _WerdProgressCardState extends State<WerdProgressCard> {
  WerdUnit _displayUnit = WerdUnit.ayah;

  double _convertValue(int ayahCount, WerdUnit unit, WerdGoal goal, bool isCurrent, WerdProgress? progress) {
    if (unit == WerdUnit.ayah) return ayahCount.toDouble();

    // If display unit matches goal unit and we are calculating the total part, use goal value exactly
    if (!isCurrent && unit == goal.unit && goal.type == WerdGoalType.fixedAmount) {
      return goal.value.toDouble();
    }

    if (isCurrent) {
      final readItems = progress?.readItemsToday ?? {};
      return QuranHizbProvider.calculateFractionalProgress(readItems, unit);
    } else {
      // For total value, we calculate how many fractional units are in the REQUIRED range
      final startAbs = progress?.sessionStartAbsolute ?? 1;
      final requiredCount = goal.valueInAyahs;
      final targetItems = Set<int>.from(List.generate(requiredCount, (i) => startAbs + i));
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
        final percent = totalAyahs > 0 ? (currentAyahs / totalAyahs).clamp(0.0, 1.0) : 0.0;
        final isCompleted = currentAyahs >= totalAyahs;

        final now = DateTime.now();
        final currentMonthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
        
        // Accurate month totals by summing history and today's granular progress
        double monthTotalPages = progress?.history.entries
            .where((e) => e.key.startsWith(currentMonthKey))
            .fold(0.0, (sum, e) => sum! + e.value.pagesRead) ?? 0.0;
        monthTotalPages += QuranHizbProvider.calculateFractionalProgress(progress?.readItemsToday ?? {}, WerdUnit.page);

        double monthTotalJuz = progress?.history.entries
            .where((e) => e.key.startsWith(currentMonthKey))
            .fold(0.0, (sum, e) => sum! + e.value.juzRead) ?? 0.0;
        monthTotalJuz += QuranHizbProvider.calculateFractionalProgress(progress?.readItemsToday ?? {}, WerdUnit.juz);

        int monthTotalAyahs = progress?.history.entries
            .where((e) => e.key.startsWith(currentMonthKey))
            .fold(0, (sum, e) => sum! + e.value.totalAyahsRead) ?? 0;
        monthTotalAyahs += currentAyahs;

        // Fractional Calculations for Daily
        final displayCurrentVal = _convertValue(currentAyahs, _displayUnit, goal, true, progress);
        final displayTotalVal = _convertValue(totalAyahs, _displayUnit, goal, false, progress);
        
        // Month total based on display unit
        double displayMonthTotalVal;
        switch (_displayUnit) {
          case WerdUnit.page: displayMonthTotalVal = monthTotalPages; break;
          case WerdUnit.juz: displayMonthTotalVal = monthTotalJuz; break;
          case WerdUnit.ayah: default: displayMonthTotalVal = monthTotalAyahs.toDouble(); break;
        }

        final displayCurrent = _formatValue(displayCurrentVal, _displayUnit, isAr);
        final displayTotal = _formatValue(displayTotalVal, _displayUnit, isAr);
        final displayMonthTotal = _formatValue(displayMonthTotalVal, _displayUnit, isAr);

        final unitLabel = {
          WerdUnit.ayah: isAr ? 'آية' : 'Ayah',
          WerdUnit.page: isAr ? 'صفحة' : 'Page',
          WerdUnit.juz: isAr ? 'جزء' : 'Juz',
        }[_displayUnit] ?? (isAr ? 'آية' : 'Ayah');

        final last7Days = List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final historyEntry = progress?.history[key];
          final amount = historyEntry?.totalAyahsRead ?? (i == 6 ? currentAyahs : 0);
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
                    child: Icon(Icons.menu_book_rounded, size: 200, color: AppTheme.accent),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isShort = constraints.maxHeight < 280;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isAr, progress, remainingDaysText),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          _buildMainProgress(displayCurrent, displayTotal, unitLabel, targetLocation, isAr, isShort),
                          const Flexible(flex: 1, child: SizedBox(height: 4)),
                          _buildProgressBar(percent, isCompleted, isShort),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildMonthStats(isAr, displayMonthTotal, displayTotal, unitLabel, isShort),
                              ),
                              const SizedBox(width: 8),
                              _buildSmallChart(last7Days, totalAyahs, now, isAr, isShort),
                            ],
                          ),
                          const Flexible(flex: 2, child: SizedBox(height: 8)),
                          const Divider(height: 1, color: AppTheme.cardBorder),
                          const Flexible(flex: 1, child: SizedBox(height: 4)),
                          _buildFooter(context, progress, isAr, isShort),
                        ],
                      ),
                    );
                  }
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
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((progress?.streak ?? 0) > 0) _buildStreakBadge(isAr, progress!.streak),
            const SizedBox(width: 8),
            _buildIconButton(Icons.history_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WerdHistoryPage()));
            }, isAr ? 'السجل' : 'History'),
            _buildIconButton(Icons.settings_outlined, widget.onSetGoalPressed, isAr ? 'تعديل' : 'Edit'),
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
        padding: EdgeInsets.symmetric(horizontal: isShort ? 6 : 10, vertical: isShort ? 2 : 4),
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

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, String tooltip) {
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
          const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14),
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

  Widget _buildMainProgress(String current, String total, String label, String targetLocation, bool isAr, bool isShort) {
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
          isAr ? 'الهدف اليوم: $targetLocation' : 'Target today: $targetLocation',
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
            child: Icon(Icons.check_circle, size: isShort ? 6 : 8, color: Colors.white.withValues(alpha: 0.8)),
          ),
      ],
    );
  }

  Widget _buildMonthStats(bool isAr, String total, String dailyTarget, String label, bool isShort) {
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

  Widget _buildSmallChart(List<MapEntry<DateTime, int>> data, int total, DateTime now, bool isAr, bool isShort) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isShort ? 8 : 12, vertical: isShort ? 4 : 8),
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
                              : [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isToday ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                      ),
                    ],
                  ),
                  if (!isShort) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 12,
                      child: Text(
                        DateFormat('E', isAr ? 'ar' : 'en').format(e.key).substring(0, 1),
                        style: GoogleFonts.outfit(
                          color: isToday ? AppTheme.textPrimary : AppTheme.textSecondary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildFooter(BuildContext context, dynamic progress, bool isAr, bool isShort) {
    // Correct Continue Logic:
    // If we have not read anything today, start from the sessionStartAbsolute.
    // If we have read something today, continue from the lastReadAbsolute.
    int targetAbs = progress?.sessionStartAbsolute ?? 1;
    if ((progress?.totalAmountReadToday ?? 0) > 0 && progress?.lastReadAbsolute != null) {
      targetAbs = progress!.lastReadAbsolute!;
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
              final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(targetAbs);
              Navigator.push(
                context,
                QuranReaderPage.route(
                  surahNumber: pos[0],
                  ayahNumber: pos[1],
                ),
              );
            },
            icon: Icon(Icons.play_arrow_rounded, size: isShort ? 18 : 20),
            label: Text(isAr ? 'متابعة' : 'Continue', style: TextStyle(fontSize: isShort ? 12 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.onAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final surahName = isAr ? quran.getSurahNameArabic(pos[0]) : quran.getSurahName(pos[0]);
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
      padding: const EdgeInsets.all(32),
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
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            isAr ? 'ابدأ رحلتك مع القرآن' : 'Start Your Quran Journey',
            style: GoogleFonts.amiri(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isAr ? 'حدد وردك اليومي وتابع تقدمك بسهولة' : 'Set your daily werd and track your progress easily',
            style: GoogleFonts.amiri(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onSetGoalPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.onAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 4,
            ),
            child: Text(
              isAr ? 'تحديد ورد الآن' : 'Set Goal Now',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }
}
