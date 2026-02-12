import 'package:fard/di/injection.dart';
import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:fard/presentation/blocs/prayer_tracker/prayer_tracker_bloc.dart';
import 'package:fard/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/presentation/widgets/calendar_widget.dart';
import 'package:fard/presentation/widgets/counter_card.dart';
import 'package:fard/presentation/widgets/history_list.dart';
import 'package:fard/presentation/widgets/missed_days_dialog.dart';
import 'package:fard/presentation/widgets/salaah_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<PrayerTrackerBloc>();
        bloc.add(const PrayerTrackerEvent.checkMissedDays());
        bloc.add(PrayerTrackerEvent.load(DateTime.now()));
        return bloc;
      },
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerTrackerBloc, PrayerTrackerState>(
      listener: (context, state) {
        state.whenOrNull(
          missedDaysPrompt: (missedDates) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => MissedDaysDialog(
                missedDates: missedDates,
                onResponse: (addAsMissed) {
                  context.read<PrayerTrackerBloc>().add(
                        PrayerTrackerEvent.acknowledgeMissedDays(
                          dates: missedDates,
                          addAsMissed: addAsMissed,
                        ),
                      );
                },
              ),
            );
          },
        );
      },
      builder: (context, state) {
        return state.when(
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryLight, strokeWidth: 4.0),
            ),
          ),
          missedDaysPrompt: (_) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 4.0),
            ),
          ),
          loaded: (selectedDate, missedToday, qadaStatus, monthRecords,
                  history) =>
              _buildLoadedScreen(
            context,
            selectedDate: selectedDate,
            missedToday: missedToday,
            qadaStatus: qadaStatus,
            monthRecords: monthRecords,
            history: history,
          ),
        );
      },
    );
  }

  Widget _buildLoadedScreen(
    BuildContext context, {
    required DateTime selectedDate,
    required Set<Salaah> missedToday,
    required Map<Salaah, MissedCounter> qadaStatus,
    required Map<DateTime, DailyRecord> monthRecords,
    required List<DailyRecord> history,
  }) {
    final bloc = context.read<PrayerTrackerBloc>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryLight,
                            AppTheme.primaryDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(Icons.mosque_rounded,
                          color: Colors.white, size: 22.0),
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'فرض',
                      style: GoogleFonts.amiri(
                        color: AppTheme.textPrimary,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Calendar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              sliver: SliverToBoxAdapter(
                child: CalendarWidget(
                  selectedDate: selectedDate,
                  monthRecords: monthRecords,
                  onDaySelected: (date) =>
                      bloc.add(PrayerTrackerEvent.load(date)),
                  onMonthChanged: (year, month) =>
                      bloc.add(PrayerTrackerEvent.loadMonth(year, month)),
                ),
              ),
            ),
            // Counter card
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              sliver: SliverToBoxAdapter(
                child: CounterCard(
                  qadaStatus: qadaStatus,
                  todayMissedCount: missedToday.length,
                  onAddPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddQadaDialog(
                        onAdd: (counts) => bloc
                            .add(PrayerTrackerEvent.bulkAddQada(counts)),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Section header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'صلوات اليوم',
                  style: GoogleFonts.amiri(
                    color: AppTheme.textPrimary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Salaah list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final salaah = Salaah.values[index];
                    return SalaahTile(
                      salaah: salaah,
                      qadaCount: qadaStatus[salaah]?.value ?? 0,
                      isMissedToday: missedToday.contains(salaah),
                      onAdd: () =>
                          bloc.add(PrayerTrackerEvent.addQada(salaah)),
                      onRemove: () =>
                          bloc.add(PrayerTrackerEvent.removeQada(salaah)),
                      onToggleMissed: () =>
                          bloc.add(PrayerTrackerEvent.togglePrayer(salaah)),
                    );
                  },
                  childCount: Salaah.values.length,
                ),
              ),
            ),
            // History section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              sliver: SliverToBoxAdapter(
                child: HistoryList(
                  records: history,
                  onDelete: (date) =>
                      bloc.add(PrayerTrackerEvent.deleteRecord(date)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
