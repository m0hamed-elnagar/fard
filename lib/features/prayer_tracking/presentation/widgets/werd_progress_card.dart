import 'package:fard/features/werd/presentation/pages/werd_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

class WerdProgressCard extends StatelessWidget {
  final VoidCallback onSetGoalPressed;

  const WerdProgressCard({
    super.key,
    required this.onSetGoalPressed,
  });

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
        
        int current = progress?.totalAmountReadToday ?? 0;
        int total = goal.valueInAyahs;
        final percent = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
        final isCompleted = current >= total;

        final now = DateTime.now();
        final currentMonthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
        int monthTotal = progress?.history.entries
            .where((e) => e.key.startsWith(currentMonthKey))
            .fold(0, (sum, e) => sum! + e.value) ?? 0;
        monthTotal += current; // Add today's progress

        // Last 7 days history
        final last7Days = List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          return MapEntry(date, progress?.history[key] ?? (i == 6 ? current : 0));
        });

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
                  right: isAr ? null : -20,
                  left: isAr ? -20 : null,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.03,
                    child: const Icon(Icons.menu_book_rounded, size: 180, color: Colors.white),
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
                              Row(
                                children: [
                                  Text(
                                    isAr ? 'الورد اليومي' : 'Daily Werd',
                                    style: GoogleFonts.amiri(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WerdHistoryPage()));
                                    },
                                    icon: const Icon(Icons.history_rounded, size: 16, color: Colors.grey),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    tooltip: isAr ? 'السجل' : 'History',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: onSetGoalPressed,
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    tooltip: isAr ? 'تعديل' : 'Edit',
                                  ),
                                ],
                              ),
                              if ((progress?.streak ?? 0) > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAr ? '${progress!.streak.toArabicIndic()} يوم' : '${progress!.streak} Days',
                                        style: GoogleFonts.outfit(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(flex: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          isAr ? current.toArabicIndic() : current.toString(),
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: isShort ? 28 : 32,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          ' / ${isAr ? total.toArabicIndic() : total}',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 6,
                                        backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.3),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isCompleted ? Colors.amber : AppTheme.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isAr ? 'هذا الشهر' : 'This Month',
                                    style: GoogleFonts.amiri(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    isAr ? monthTotal.toArabicIndic() : monthTotal.toString(),
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(flex: 2),
                          // Small History Chart - Only show if enough space
                          if (!isShort) ...[
                            SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: last7Days.map((e) {
                                  final val = e.value;
                                  final height = (val / total * 24).clamp(4.0, 24.0);
                                  final isToday = e.key.day == now.day;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: isToday ? Colors.amber : AppTheme.textSecondary.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('E', isAr ? 'ar' : 'en').format(e.key).substring(0, 1),
                                        style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 9),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const Spacer(flex: 1),
                          ],
                          const Divider(height: 1, color: AppTheme.cardBorder),
                          const Spacer(flex: 1),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAr ? 'المكان الحالي' : 'Current Position',
                                      style: GoogleFonts.amiri(
                                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      _getAyahInfo(
                                        (progress?.totalAmountReadToday ?? 0) == 0
                                            ? (progress?.sessionStartAbsolute ?? 1)
                                            : (progress?.lastReadAbsolute ?? progress?.sessionStartAbsolute ?? 1),
                                        isAr
                                      ),
                                      style: GoogleFonts.amiri(
                                        color: AppTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final targetAbs = (progress?.totalAmountReadToday ?? 0) == 0
                                        ? (progress?.sessionStartAbsolute ?? 1)
                                        : (progress?.lastReadAbsolute ?? progress?.sessionStartAbsolute ?? 1);
                                    final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(targetAbs);
                                    Navigator.push(
                                      context,
                                      QuranReaderPage.route(
                                        surahNumber: pos[0],
                                        ayahNumber: pos[1],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accent,
                                    foregroundColor: AppTheme.onAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    elevation: 0,
                                  ),
                                  child: Text(isAr ? 'متابعة' : 'Continue', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
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
      },
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.track_changes_rounded, color: AppTheme.accent, size: 40),
            const SizedBox(height: 12),
            Text(
              isAr ? 'حدد وردك اليومي' : 'Set Daily Werd',
              style: GoogleFonts.amiri(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onSetGoalPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.onAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(isAr ? 'بدء الآن' : 'Start Now', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
