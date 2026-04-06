import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/werd/presentation/widgets/set_werd_goal_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/dashboard_carousel.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/suggested_azkar_section.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class HomeContent extends StatefulWidget {
  final DateTime selectedDate;
  final Set<Salaah> missedToday;
  final Set<Salaah> completedToday;
  final Map<Salaah, MissedCounter> qadaStatus;
  final Map<Salaah, int> completedQadaToday;
  final Map<DateTime, DailyRecord> monthRecords;
  final List<DailyRecord> history;

  const HomeContent({
    super.key,
    required this.selectedDate,
    required this.missedToday,
    required this.completedToday,
    required this.qadaStatus,
    required this.completedQadaToday,
    required this.monthRecords,
    required this.history,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToAddQada() {
    // Scroll to top to make DashboardCarousel visible
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );

    // Change PageView to index 1 (PrayerTrackingCard)
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _showWerdGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<WerdBloc>(),
        child: const SetWerdGoalDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PrayerTrackerBloc>();
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.latitude != current.latitude ||
          previous.longitude != current.longitude ||
          previous.calculationMethod != current.calculationMethod ||
          previous.madhab != current.madhab ||
          previous.locale != current.locale ||
          previous.cityName != current.cityName ||
          previous.isQadaEnabled != current.isQadaEnabled ||
          previous.hijriAdjustment != current.hijriAdjustment,
      builder: (context, settings) {
        // Calculate today's prayer times for countdown (always uses DateTime.now())
        final todayPrayerTimes =
            (settings.latitude != null && settings.longitude != null)
            ? getIt<PrayerTimeService>().getPrayerTimes(
                latitude: settings.latitude!,
                longitude: settings.longitude!,
                method: settings.calculationMethod,
                madhab: settings.madhab,
                date: DateTime.now(),
              )
            : null;

        // Calculate selected date prayer times for display in prayer list
        final selectedDatePrayerTimes =
            (settings.latitude != null && settings.longitude != null)
            ? getIt<PrayerTimeService>().getPrayerTimes(
                latitude: settings.latitude!,
                longitude: settings.longitude!,
                method: settings.calculationMethod,
                madhab: settings.madhab,
                date: widget.selectedDate,
              )
            : null;

        // DEBUG: Log what we're passing to the widgets
        debugPrint('╔═══════════════════════════════════════════╗');
        debugPrint('║ HomeContent: Prayer Times Calculation     ║');
        debugPrint('╠═══════════════════════════════════════════╣');
        debugPrint('║ Today: ${DateTime.now().toString().substring(0, 10)}');
        debugPrint('║ Selected: ${widget.selectedDate.toString().substring(0, 10)}');
        debugPrint('║ Today Prayer Times: ${todayPrayerTimes != null ? "YES (Fajr: ${todayPrayerTimes!.fajr.toString().substring(0, 10)})" : "NO"}');
        debugPrint('║ Selected Date Prayer Times: ${selectedDatePrayerTimes != null ? "YES (Fajr: ${selectedDatePrayerTimes!.fajr.toString().substring(0, 10)})" : "NO"}');
        debugPrint('║ DashboardCarousel gets: TODAY times');
        debugPrint('║ Prayer list gets: SELECTED DATE times');
        debugPrint('╚═══════════════════════════════════════════╝');

        // Update widget when critical settings change (locale, location, method, etc.)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getIt<WidgetUpdateService>().updateWidget();
        });

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n.appName,
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: DashboardCarousel(
                      prayerTimes: todayPrayerTimes,
                      selectedDate: widget.selectedDate,
                      cityName: settings.cityName,
                      qadaStatus: widget.qadaStatus,
                      pageController: _pageController,
                      isQadaEnabled: settings.isQadaEnabled,
                      onAddQadaPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddQadaDialog(
                            onConfirm: (counts) => bloc.add(
                              PrayerTrackerEvent.bulkAddQada(counts),
                            ),
                          ),
                        );
                      },
                      onEditQadaPressed: () {
                        final currentCounts = {
                          for (final s in Salaah.values)
                            s: widget.qadaStatus[s]?.value ?? 0,
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
                      onSetWerdGoalPressed: () => _showWerdGoalDialog(context),
                    ),
                  ),
                ),

                // Calendar section with subtle top padding
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  sliver: SliverToBoxAdapter(
                    child: CalendarWidget(
                      selectedDate: widget.selectedDate,
                      monthRecords: widget.monthRecords,
                      hijriAdjustment: settings.hijriAdjustment,
                      onDaySelected: (date) =>
                          bloc.add(PrayerTrackerEvent.load(date)),
                      onMonthChanged: (year, month) =>
                          bloc.add(PrayerTrackerEvent.loadMonth(year, month)),
                    ),
                  ),
                ),

                // Suggested Azkar Section
                SuggestedAzkarSection(settings: settings),

                // Location Warning
                if (settings.latitude == null || settings.longitude == null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.missed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.missed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_off_rounded,
                                  color: AppTheme.missed,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.locationWarning,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<SettingsCubit>()
                                    .refreshLocation(),
                                icon: const Icon(Icons.my_location, size: 18),
                                label: Text(l10n.givePermission),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.missed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Today's Prayers Section Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.today_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.dailyPrayers,
                          key: const Key('daily_prayers_header'),
                          style: GoogleFonts.amiri(
                            color: AppTheme.textPrimary,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Salaah list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final salaah = Salaah.values[index];
                      final time = selectedDatePrayerTimes != null
                          ? getIt<PrayerTimeService>().getTimeForSalaah(
                              selectedDatePrayerTimes,
                              salaah,
                            )
                          : null;

                      final isUpcoming = getIt<PrayerTimeService>().isUpcoming(
                        salaah,
                        prayerTimes: selectedDatePrayerTimes,
                        date: widget.selectedDate,
                      );

                      return SalaahTile(
                        salaah: salaah,
                        qadaCount: widget.qadaStatus[salaah]?.value ?? 0,
                        completedQadaCount:
                            widget.completedQadaToday[salaah] ?? 0,
                        isMissedToday: widget.missedToday.contains(salaah),
                        isCompletedToday: widget.completedToday.contains(
                          salaah,
                        ),
                        isUpcoming: isUpcoming,
                        time: time,
                        isQadaEnabled: settings.isQadaEnabled,
                        onAdd: () =>
                            bloc.add(PrayerTrackerEvent.addQada(salaah)),
                        onRemove: () =>
                            bloc.add(PrayerTrackerEvent.removeQada(salaah)),
                        onToggleMissed: () =>
                            bloc.add(PrayerTrackerEvent.togglePrayer(salaah)),
                        onLimitExceeded: _scrollToAddQada,
                      );
                    }, childCount: Salaah.values.length),
                  ),
                ),

                // History section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 40.0),
                  sliver: SliverToBoxAdapter(
                    child: HistoryList(
                      records: widget.history,
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
