import 'package:fard/core/di/injection.dart';
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/counter_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = getIt<PrayerTrackerBloc>();
            bloc.add(const PrayerTrackerEvent.checkMissedDays());
            bloc.add(PrayerTrackerEvent.load(DateTime.now()));
            return bloc;
          },
        ),
      ],
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
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppTheme.missed,
              ),
            );
          },
          missedDaysPrompt: (missedDates) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => MissedDaysDialog(
                missedDates: missedDates,
                onResponse: (selectedDates) {
                  context.read<PrayerTrackerBloc>().add(
                        PrayerTrackerEvent.acknowledgeMissedDays(
                          selectedDates: selectedDates,
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
              child: CircularProgressIndicator(
                  color: AppTheme.primaryLight, strokeWidth: 4.0),
            ),
          ),
          error: (message) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.missed, size: 48.0),
                  const SizedBox(height: 16.0),
                  Text(
                    AppLocalizations.of(context)!.errorOccurred,
                    style: GoogleFonts.amiri(
                      color: AppTheme.textPrimary,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PrayerTrackerBloc>()
                        .add(PrayerTrackerEvent.load(DateTime.now())),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          ),
          missedDaysPrompt: (_) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                  color: AppTheme.accent, strokeWidth: 4.0),
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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.latitude != current.latitude ||
          previous.longitude != current.longitude ||
          previous.calculationMethod != current.calculationMethod ||
          previous.madhab != current.madhab ||
          previous.locale != current.locale ||
          previous.cityName != current.cityName,
      builder: (context, settings) {
        final locale = settings.locale.languageCode;
        final hijriDate = selectedDate.toHijriDate(locale);
        
        final prayerTimes = (settings.latitude != null && settings.longitude != null)
            ? getIt<PrayerTimeService>().getPrayerTimes(
                latitude: settings.latitude!,
                longitude: settings.longitude!,
                method: settings.calculationMethod,
                madhab: settings.madhab,
                date: selectedDate,
              )
            : null;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _MosqueIcon(),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                l10n.appName,
                                style: GoogleFonts.amiri(
                                  color: AppTheme.textPrimary,
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 52.0, top: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMEEEEd(locale).format(selectedDate),
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                hijriDate,
                                style: GoogleFonts.amiri(
                                  color: AppTheme.accent,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (settings.cityName != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 52.0),
                            child: Text(
                              settings.cityName!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
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
                            onConfirm: (counts) =>
                                bloc.add(PrayerTrackerEvent.bulkAddQada(counts)),
                          ),
                        );
                      },
                      onEditPressed: () {
                        final currentCounts = {
                          for (final s in Salaah.values)
                            s: qadaStatus[s]?.value ?? 0
                        };
                        showDialog(
                          context: context,
                          builder: (_) => AddQadaDialog(
                            title: l10n.editQada,
                            initialCounts: currentCounts,
                            onConfirm: (counts) =>
                                bloc.add(PrayerTrackerEvent.updateQada(counts)),
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
                      l10n.dailyPrayers,
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
                        DateTime? time;
                        if (prayerTimes != null) {
                          time = getIt<PrayerTimeService>().getTimeForSalaah(prayerTimes, salaah);
                        }
                        
                        return SalaahTile(
                          salaah: salaah,
                          qadaCount: qadaStatus[salaah]?.value ?? 0,
                          isMissedToday: missedToday.contains(salaah),
                          time: time,
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
      },
    );
  }
}

class _MosqueIcon extends StatelessWidget {
  const _MosqueIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22.0),
    );
  }
}
