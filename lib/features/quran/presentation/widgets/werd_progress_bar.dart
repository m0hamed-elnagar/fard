import 'package:fard/features/werd/presentation/widgets/set_werd_goal_dialog.dart';
import 'package:fard/features/werd/presentation/pages/werd_history_page.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;

class WerdProgressBar extends StatelessWidget {
  const WerdProgressBar({super.key});

  void _showSetGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<WerdBloc>(),
        child: const SetWerdGoalDialog(),
      ),
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

  String _formatValue(double value, bool isAr) {
    if ((value - value.round()).abs() < 0.05) {
      final intVal = value.round();
      return isAr ? intVal.toArabicIndic() : intVal.toString();
    }
    final formatted = value.toStringAsFixed(1);
    if (isAr) {
      return formatted.replaceAll('.', '٫').toArabicIndic();
    }
    return formatted;
  }

  String _getProgressText(
    int current,
    int total,
    WerdGoal goal,
    dynamic progress,
    bool isAr,
  ) {
    if (goal.category != WerdCategory.quran) {
      return isAr
          ? 'تم إكمال ${current.toArabicIndic()} من ${total.toArabicIndic()}'
          : 'Completed ${current.toString()} of ${total.toString()}';
    }

    if (goal.type == WerdGoalType.finishInDays) {
      return isAr
          ? 'تم إكمال ${current.toArabicIndic()} من ${total.toArabicIndic()} آية لختم المصحف'
          : 'Completed ${current.toString()} of ${total.toString()} ayahs to finish';
    }

    // Fixed amount with specific unit
    String unitName = '';
    double currentInUnit = current.toDouble();
    double totalInUnit = goal.value.toDouble();

    final readItems = progress?.readItemsToday as Set<int>? ?? {};
    currentInUnit = QuranHizbProvider.calculateFractionalProgress(
      readItems,
      goal.unit,
    );

    switch (goal.unit) {
      case WerdUnit.ayah:
        unitName = isAr ? 'آية' : 'ayah';
        break;
      case WerdUnit.page:
        unitName = isAr ? 'صفحة' : 'page';
        break;
      case WerdUnit.juz:
        unitName = isAr ? 'جزء' : 'juz';
        break;
      case WerdUnit.hizb:
        unitName = isAr ? 'حزب' : 'hizb';
        break;
      case WerdUnit.quarter:
        unitName = isAr ? 'ربع' : 'quarter';
        break;
      default:
        unitName = isAr ? 'آية' : 'ayah';
    }

    final curStr = _formatValue(currentInUnit, isAr);
    final totStr = _formatValue(totalInUnit, isAr);

    if (isAr) {
      return 'تم إكمال $curStr من $totStr $unitName';
    } else {
      return 'Completed $curStr of $totStr $unitName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<WerdBloc, WerdState>(
      builder: (context, state) {
        if (state.goal == null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'حدد وردك اليومي' : 'Set Daily Werd',
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAr
                            ? 'تابع تقدمك في قراءة القرآن'
                            : 'Track your Quran progress',
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showSetGoalDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isAr ? 'بدء' : 'Start'),
                ),
              ],
            ),
          );
        }

        final progress = state.progress;
        final goal = state.goal!;

        int current = progress?.totalAmountReadToday ?? 0;
        int total = goal.valueInAyahs;

        final percent = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
        final isCompleted = current >= total;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
            onTap: () => _showSetGoalDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.stars_rounded
                                : Icons.menu_book_rounded,
                            color: isCompleted
                                ? Colors.amber
                                : AppTheme.primaryLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (progress?.totalAmountReadToday ?? 0) == 0
                                ? (isAr ? 'بداية الورد' : 'Werd Start')
                                : (isAr ? 'ورد اليوم' : 'Daily Werd'),
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if ((progress?.totalAmountReadToday ?? 0) == 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                _getAyahInfo(
                                  progress?.sessionStartAbsolute ?? 1,
                                  isAr,
                                ),
                                style: GoogleFonts.amiri(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WerdHistoryPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.history_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                            tooltip: isAr ? 'السجل' : 'History',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                          IconButton(
                            onPressed: () => _showSetGoalDialog(context),
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                            tooltip: isAr ? 'تعديل الهدف' : 'Edit Goal',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                          if (progress?.lastReadAbsolute != null ||
                              progress?.sessionStartAbsolute != null)
                            const SizedBox(width: 4),
                          if (progress?.lastReadAbsolute != null ||
                              progress?.sessionStartAbsolute != null)
                            TextButton.icon(
                              onPressed: () {
                                int targetAbs =
                                    progress?.sessionStartAbsolute ?? 1;
                                if ((progress?.totalAmountReadToday ?? 0) > 0 &&
                                    progress?.lastReadAbsolute != null) {
                                  targetAbs = progress!.lastReadAbsolute!;
                                }
                                final pos =
                                    QuranHizbProvider.getSurahAndAyahFromAbsolute(
                                      targetAbs,
                                    );

                                Navigator.push(
                                  context,
                                  QuranReaderPage.route(
                                    surahNumber: pos[0],
                                    ayahNumber: pos[1],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              label: Text(isAr ? 'متابعة' : 'Continue'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppTheme.primaryLight,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.amber : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getProgressText(current, total, goal, progress, isAr),
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if ((progress?.streak ?? 0) > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? progress!.streak.toArabicIndic()
                                  : progress!.streak.toString(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isAr ? 'يوم' : 'd',
                              style: GoogleFonts.amiri(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
