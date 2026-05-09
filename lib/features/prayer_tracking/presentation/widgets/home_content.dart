import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/dashboard_carousel.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/suggested_azkar_section.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/widgets/reminders_settings_dialog.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/widgets/set_werd_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );

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

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.appName,
          style: GoogleFonts.amiri(
            color: context.onSurfaceColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => RemindersSettingsDialog.show(context),
            icon: const Icon(Icons.notifications_active_rounded),
            color: context.secondaryColor,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sliver 1: Dashboard Carousel (Optimized Rebuilds)
            BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
              buildWhen: (prev, curr) =>
                  prev.latitude != curr.latitude ||
                  prev.longitude != curr.longitude ||
                  prev.calculationMethod != curr.calculationMethod ||
                  prev.madhab != curr.madhab ||
                  prev.cityName != curr.cityName,
              builder: (context, locationState) {
                return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
                  buildWhen: (prev, curr) =>
                      prev.isQadaEnabled != curr.isQadaEnabled,
                  builder: (context, remindersState) {
                    final todayPrayerTimes = (locationState.latitude != null &&
                            locationState.longitude != null)
                        ? getIt<PrayerTimeService>().getPrayerTimes(
                            latitude: locationState.latitude!,
                            longitude: locationState.longitude!,
                            method: locationState.calculationMethod,
                            madhab: locationState.madhab,
                            date: DateTime.now(),
                          )
                        : null;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      sliver: SliverToBoxAdapter(
                        child: DashboardCarousel(
                          prayerTimes: todayPrayerTimes,
                          selectedDate: widget.selectedDate,
                          cityName: locationState.cityName,
                          qadaStatus: widget.qadaStatus,
                          pageController: _pageController,
                          isQadaEnabled: remindersState.isQadaEnabled,
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
                                onConfirm: (counts) => bloc.add(
                                    PrayerTrackerEvent.updateQada(counts)),
                              ),
                            );
                          },
                          onSetWerdGoalPressed: () =>
                              _showWerdGoalDialog(context),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Sliver 2: Calendar Section (Optimized Rebuilds)
            BlocSelector<LocationPrayerCubit, LocationPrayerState, int>(
              selector: (state) => state.hijriAdjustment,
              builder: (context, hijriAdjustment) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  sliver: SliverToBoxAdapter(
                    child: CalendarWidget(
                      selectedDate: widget.selectedDate,
                      monthRecords: widget.monthRecords,
                      hijriAdjustment: hijriAdjustment,
                      onDaySelected: (date) =>
                          bloc.add(PrayerTrackerEvent.load(date)),
                      onMonthChanged: (year, month) =>
                          bloc.add(PrayerTrackerEvent.loadMonth(year, month)),
                    ),
                  ),
                );
              },
            ),

            // Sliver 3: Suggested Azkar Section (Optimized Rebuilds)
            BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
              builder: (context, remindersState) {
                return SuggestedAzkarSection(settings: remindersState);
              },
            ),

            // Sliver 4: Location Warning (Optimized Rebuilds)
            BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
              buildWhen: (prev, curr) =>
                  (prev.latitude == null) != (curr.latitude == null) ||
                  (prev.longitude == null) != (curr.longitude == null),
              builder: (context, locationState) {
                if (locationState.latitude == null ||
                    locationState.longitude == null) {
                  return _LocationWarning(
                    givePermissionLabel: l10n.givePermission,
                    locationWarningLabel: l10n.locationWarning,
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Sliver 5: Daily Prayers Section (Optimized Rebuilds)
            BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
              buildWhen: (prev, curr) =>
                  prev.latitude != curr.latitude ||
                  prev.longitude != curr.longitude ||
                  prev.calculationMethod != curr.calculationMethod ||
                  prev.madhab != curr.madhab,
              builder: (context, locationState) {
                return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
                  builder: (context, remindersState) {
                    final selectedDatePrayerTimes =
                        (locationState.latitude != null &&
                                locationState.longitude != null)
                            ? getIt<PrayerTimeService>().getPrayerTimes(
                                latitude: locationState.latitude!,
                                longitude: locationState.longitude!,
                                method: locationState.calculationMethod,
                                madhab: locationState.madhab,
                                date: widget.selectedDate,
                              )
                            : null;

                    return _DailyPrayersSection(
                      locationState: locationState,
                      remindersState: remindersState,
                      selectedDate: widget.selectedDate,
                      selectedDatePrayerTimes: selectedDatePrayerTimes,
                      missedToday: widget.missedToday,
                      completedToday: widget.completedToday,
                      qadaStatus: widget.qadaStatus,
                      completedQadaToday: widget.completedQadaToday,
                      onScrollToAddQada: _scrollToAddQada,
                    );
                  },
                );
              },
            ),

            // Sliver 6: History section
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
  }
}

class _LocationWarning extends StatelessWidget {
  final String locationWarningLabel;
  final String givePermissionLabel;

  const _LocationWarning({
    required this.locationWarningLabel,
    required this.givePermissionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.errorColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_off_rounded, color: context.errorColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      locationWarningLabel,
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
                  onPressed: () =>
                      context.read<LocationPrayerCubit>().refreshLocation(),
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(givePermissionLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.errorColor,
                    foregroundColor: context.onSurfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }
}

class _DailyPrayersSection extends StatefulWidget {
  final LocationPrayerState locationState;
  final DailyRemindersState remindersState;
  final DateTime selectedDate;
  final dynamic selectedDatePrayerTimes; // Use actual type from Adhan
  final Set<Salaah> missedToday;
  final Set<Salaah> completedToday;
  final Map<Salaah, MissedCounter> qadaStatus;
  final Map<Salaah, int> completedQadaToday;
  final VoidCallback onScrollToAddQada;

  const _DailyPrayersSection({
    required this.locationState,
    required this.remindersState,
    required this.selectedDate,
    required this.selectedDatePrayerTimes,
    required this.missedToday,
    required this.completedToday,
    required this.qadaStatus,
    required this.completedQadaToday,
    required this.onScrollToAddQada,
  });

  @override
  State<_DailyPrayersSection> createState() => _DailyPrayersSectionState();
}

class _DailyPrayersSectionState extends State<_DailyPrayersSection> {
  bool _isExpanded = true;

  void _showReminderSnackBar(
    String title,
    bool enabled, {
    String? customMessage,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final String status = enabled
        ? (isAr ? 'مفعل' : 'Enabled')
        : (isAr ? 'معطل' : 'Disabled');

    final String message =
        customMessage ?? (enabled ? '$title: $status' : '$title: $status');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: context.secondaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.amiri(
                  color: context.onSurfaceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.surfaceContainerHighestColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      sliver: SliverToBoxAdapter(
        child: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceContainerColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: context.outlineColor.withValues(alpha: 0.8),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.backgroundColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(24.0),
                    bottom: Radius.circular(_isExpanded ? 0 : 24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.today_rounded,
                          color: context.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.dailyPrayers,
                          style: GoogleFonts.amiri(
                            color: context.onSurfaceColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            final newState =
                                !widget.remindersState.isSalahReminderEnabled;
                            context
                                .read<DailyRemindersCubit>()
                                .toggleSalahReminder(
                                  newState,
                                );
                            _showReminderSnackBar(
                              isAr ? 'تذكيرات الصلاة' : 'Salah Reminders',
                              newState,
                              customMessage: newState
                                  ? (isAr
                                        ? 'سنذكرك بتسجيل صلواتك بعد الأذان بـ ${widget.remindersState.salahReminderOffsetMinutes} دقيقة'
                                        : 'We will remind you to log prayers ${widget.remindersState.salahReminderOffsetMinutes}m after Azan')
                                  : (isAr
                                        ? 'تم إيقاف تذكيرات تسجيل الصلاة'
                                        : 'Post-prayer logging reminders disabled'),
                            );
                          },
                          icon: Icon(
                            widget.remindersState.isSalahReminderEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: widget.remindersState.isSalahReminderEnabled
                                ? context.secondaryColor
                                : context.onSurfaceColor.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          tooltip: l10n.azanNotifications,
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: context.onSurfaceColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const Divider(height: 1.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 16.0),
                    child: Column(
                      children: [
                        for (
                          int index = 0;
                          index < Salaah.values.length;
                          index++
                        ) ...[
                          SalaahTile(
                            salaah: Salaah.values[index],
                            qadaCount:
                                widget.qadaStatus[Salaah.values[index]]?.value ??
                                    0,
                            completedQadaCount:
                                widget.completedQadaToday[Salaah.values[index]] ??
                                    0,
                            isMissedToday: widget.missedToday.contains(
                              Salaah.values[index],
                            ),
                            isCompletedToday: widget.completedToday.contains(
                              Salaah.values[index],
                            ),
                            isUpcoming: getIt<PrayerTimeService>().isUpcoming(
                              Salaah.values[index],
                              prayerTimes: widget.selectedDatePrayerTimes,
                              date: widget.selectedDate,
                            ),
                            time: widget.selectedDatePrayerTimes != null
                                ? getIt<PrayerTimeService>().getTimeForSalaah(
                                    widget.selectedDatePrayerTimes,
                                    Salaah.values[index],
                                  )
                                : null,
                            isQadaEnabled: widget.remindersState.isQadaEnabled,
                            isReminderEnabled:
                                widget.remindersState.isSalahReminderEnabled &&
                                    widget.remindersState.enabledSalahReminders
                                        .contains(
                                      Salaah.values[index],
                                    ),
                            onAdd: () => context.read<PrayerTrackerBloc>().add(
                              PrayerTrackerEvent.addQada(Salaah.values[index]),
                            ),
                            onRemove: () => context.read<PrayerTrackerBloc>().add(
                              PrayerTrackerEvent.removeQada(
                                Salaah.values[index],
                              ),
                            ),
                            onToggleMissed: () => context.read<PrayerTrackerBloc>().add(
                              PrayerTrackerEvent.togglePrayer(
                                Salaah.values[index],
                              ),
                            ),
                            onToggleReminder: () {
                              final salaah = Salaah.values[index];
                              final isEnabled = widget.remindersState
                                  .enabledSalahReminders
                                  .contains(salaah);
                              context
                                  .read<DailyRemindersCubit>()
                                  .toggleSpecificSalahReminder(salaah);
                              _showReminderSnackBar(
                                salaah.localizedName(l10n),
                                !isEnabled,
                                customMessage: !isEnabled
                                    ? (isAr
                                          ? 'سنذكرك بتسجيل ${salaah.localizedName(l10n)} بعد الأذان'
                                          : 'We will remind you to log ${salaah.localizedName(l10n)} after Azan')
                                    : (isAr
                                          ? 'تم إيقاف تذكير ${salaah.localizedName(l10n)}'
                                          : 'Reminder for ${salaah.localizedName(l10n)} disabled'),
                              );
                            },
                            onLimitExceeded: widget.onScrollToAddQada,
                          ),
                          if (index < Salaah.values.length - 1)
                            const SizedBox(height: 8.0),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
