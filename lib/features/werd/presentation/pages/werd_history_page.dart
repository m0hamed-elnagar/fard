import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/extensions/number_extension.dart';

class WerdHistoryPage extends StatelessWidget {
  const WerdHistoryPage({super.key});

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
          if (progress == null || progress.history.isEmpty) {
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

          // Calculate monthly summary (current month)
          final now = DateTime.now();
          final currentMonthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
          int monthTotal = 0;
          int monthDays = 0;
          
          for (final entry in historyList) {
            if (entry.key.startsWith(currentMonthKey)) {
              monthTotal += entry.value;
              monthDays++;
            }
          }
          
          // Add today's progress to summary if it's not in history yet
          monthTotal += progress.totalAmountReadToday;
          monthDays++;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(context, isAr, monthTotal, monthDays),
              const SizedBox(height: 24),
              Text(
                isAr ? 'التفاصيل اليومية' : 'Daily Details',
                style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Today Item
              _buildHistoryItem(
                context, 
                isAr, 
                DateTime.now(), 
                progress.totalAmountReadToday, 
                isToday: true,
                goal: state.goal?.valueInAyahs ?? 0,
              ),
              ...historyList.map((entry) {
                final date = DateTime.parse(entry.key);
                return _buildHistoryItem(
                  context, 
                  isAr, 
                  date, 
                  entry.value,
                  goal: state.goal?.valueInAyahs ?? 0,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isAr, int total, int days) {
    final avg = days > 0 ? (total / days).round() : 0;
    
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
              isAr ? 'ملخص الشهر الحالي' : 'Current Month Summary',
              style: GoogleFonts.amiri(fontSize: 16, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  isAr ? 'إجمالي الآيات' : 'Total Ayahs',
                  total.toArabicIndic(),
                  Icons.auto_stories_rounded,
                ),
                _buildStatItem(
                  context,
                  isAr ? 'متوسط يومي' : 'Daily Avg',
                  avg.toArabicIndic(),
                  Icons.show_chart_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, bool isAr, DateTime date, int amount, {bool isToday = false, int goal = 0}) {
    final dayFormat = DateFormat('EEEE', isAr ? 'ar' : 'en');
    final dateFormat = DateFormat('d MMMM', isAr ? 'ar' : 'en');
    
    final isCompleted = goal > 0 && amount >= goal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
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
                  isToday ? (isAr ? 'اليوم' : 'Today') : dayFormat.format(date),
                  style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  dateFormat.format(date),
                  style: GoogleFonts.amiri(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount.toArabicIndic()} آية',
                style: GoogleFonts.amiri(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.amber[800] : null,
                ),
              ),
              if (goal > 0)
                Text(
                  '${(amount / goal * 100).round().toArabicIndic()}%',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
