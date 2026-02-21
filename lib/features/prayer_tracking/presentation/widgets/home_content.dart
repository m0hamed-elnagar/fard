import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/home_hero.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/suggested_azkar_section.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class HomeContent extends StatelessWidget {
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
          previous.isQadaEnabled != current.isQadaEnabled,
      builder: (context, settings) {
        final locale = settings.locale.languageCode;
        
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
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Consolidated Header (Dome + Branding + Location + Qada)
                SliverToBoxAdapter(
                  child: HomeHero(
                    qadaStatus: qadaStatus,
                    selectedDate: selectedDate,
                    locale: locale,
                    cityName: settings.cityName,
                    isQadaEnabled: settings.isQadaEnabled,
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
                    onLocationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
                
                // Calendar section with subtle top padding
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
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
                          border: Border.all(color: AppTheme.missed.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_off_rounded, color: AppTheme.missed),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.locationWarning,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.read<SettingsCubit>().refreshLocation(),
                                icon: const Icon(Icons.my_location, size: 18),
                                label: Text(l10n.givePermission),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.missed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        const Icon(Icons.today_rounded, color: AppTheme.accent, size: 20),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final salaah = Salaah.values[index];
                        final time = prayerTimes != null 
                            ? getIt<PrayerTimeService>().getTimeForSalaah(prayerTimes, salaah)
                            : null;
                        
                        final isUpcoming = getIt<PrayerTimeService>().isUpcoming(
                          salaah, 
                          prayerTimes: prayerTimes, 
                          date: selectedDate,
                        );
                        
                        return SalaahTile(
                          salaah: salaah,
                          qadaCount: qadaStatus[salaah]?.value ?? 0,
                          completedQadaCount: completedQadaToday[salaah] ?? 0,
                          isMissedToday: missedToday.contains(salaah),
                          isCompletedToday: completedToday.contains(salaah),
                          isUpcoming: isUpcoming,
                          time: time,
                          isQadaEnabled: settings.isQadaEnabled,
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
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 40.0),
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
