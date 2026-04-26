import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
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
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
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
  bool _isDailyPrayersExpanded = true;

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

  void _showReminderSnackBar(String title, bool enabled, {String? customMessage}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final String status = enabled
        ? (isAr ? 'مفعل' : 'Enabled')
        : (isAr ? 'معطل' : 'Disabled');

    final String message = customMessage ?? (enabled ? '$title: $status' : '$title: $status');

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
    final bloc = context.read<PrayerTrackerBloc>();
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.latitude != current.latitude ||
          previous.longitude != current.longitude ||
          previous.calculationMethod != current.calculationMethod ||
          previous.madhab != current.madhab ||
          previous.locale != current.locale ||
          previous.cityName != current.cityName ||
          previous.isQadaEnabled != current.isQadaEnabled ||
          previous.hijriAdjustment != current.hijriAdjustment ||
          previous.isSalahReminderEnabled != current.isSalahReminderEnabled ||
          previous.enabledSalahReminders != current.enabledSalahReminders,
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

        // Update widget when critical settings change (locale, location, method, etc.)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getIt<WidgetUpdateService>().updateWidget();
        });

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
                                Icon(
                                  Icons.location_off_rounded,
                                  color: context.errorColor,
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
                                  backgroundColor: context.errorColor,
                                  foregroundColor: context.onSurfaceColor,
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

                // Unified Today's Prayers Section (Header + List) inside a Frame
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
                  sliver: SliverToBoxAdapter(
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
                            color:
                                context.backgroundColor.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header (Inside the frame)
                          InkWell(
                            onTap:
                                () => setState(() {
                                  _isDailyPrayersExpanded =
                                      !_isDailyPrayersExpanded;
                                }),
                            borderRadius: BorderRadius.vertical(
                              top: const Radius.circular(24.0),
                              bottom: Radius.circular(
                                _isDailyPrayersExpanded ? 0 : 24.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                12.0,
                                12.0,
                              ),
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
                                          !settings.isSalahReminderEnabled;
                                      context
                                          .read<SettingsCubit>()
                                          .toggleSalahReminder(newState);
                                      _showReminderSnackBar(
                                        isAr
                                            ? 'تذكيرات الصلاة'
                                            : 'Salah Reminders',
                                        newState,
                                        customMessage:
                                            newState
                                                ? (isAr
                                                    ? 'سنذكرك بتسجيل صلواتك بعد الأذان بـ ${settings.salahReminderOffsetMinutes} دقيقة'
                                                    : 'We will remind you to log prayers ${settings.salahReminderOffsetMinutes}m after Azan')
                                                : (isAr
                                                    ? 'تم إيقاف تذكيرات تسجيل الصلاة'
                                                    : 'Post-prayer logging reminders disabled'),
                                      );
                                    },
                                    icon: Icon(
                                      settings.isSalahReminderEnabled
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      color:
                                          settings.isSalahReminderEnabled
                                              ? context.secondaryColor
                                              : context.onSurfaceColor
                                                  .withValues(alpha: 0.5),
                                      size: 20,
                                    ),
                                    tooltip: l10n.azanNotifications,
                                  ),
                                  Icon(
                                    _isDailyPrayersExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: context.onSurfaceColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Collapsible List
                          if (_isDailyPrayersExpanded) ...[
                            const Divider(height: 1.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                8.0,
                                12.0,
                                8.0,
                                16.0,
                              ),
                              child: Column(
                                children: [
                                  for (int index = 0;
                                      index < Salaah.values.length;
                                      index++) ...[
                                    SalaahTile(
                                      salaah: Salaah.values[index],
                                      qadaCount:
                                          widget.qadaStatus[Salaah
                                                      .values[index]]
                                                  ?.value ??
                                              0,
                                      completedQadaCount:
                                          widget.completedQadaToday[Salaah
                                                  .values[index]] ??
                                              0,
                                      isMissedToday: widget.missedToday
                                          .contains(Salaah.values[index]),
                                      isCompletedToday: widget.completedToday
                                          .contains(Salaah.values[index]),
                                      isUpcoming: getIt<PrayerTimeService>()
                                              .isUpcoming(
                                        Salaah.values[index],
                                        prayerTimes: selectedDatePrayerTimes,
                                        date: widget.selectedDate,
                                      ),
                                      time:
                                          selectedDatePrayerTimes != null
                                              ? getIt<PrayerTimeService>()
                                                  .getTimeForSalaah(
                                                    selectedDatePrayerTimes,
                                                    Salaah.values[index],
                                                  )
                                              : null,
                                      isQadaEnabled: settings.isQadaEnabled,
                                      isReminderEnabled:
                                          settings.isSalahReminderEnabled &&
                                          settings.enabledSalahReminders
                                              .contains(
                                                Salaah.values[index],
                                              ),
                                      onAdd:
                                          () => bloc.add(
                                            PrayerTrackerEvent.addQada(
                                              Salaah.values[index],
                                            ),
                                          ),
                                      onRemove:
                                          () => bloc.add(
                                            PrayerTrackerEvent.removeQada(
                                              Salaah.values[index],
                                            ),
                                          ),
                                      onToggleMissed:
                                          () => bloc.add(
                                            PrayerTrackerEvent.togglePrayer(
                                              Salaah.values[index],
                                            ),
                                          ),
                                      onToggleReminder: () {
                                        final salaah = Salaah.values[index];
                                        final isEnabled = settings
                                            .enabledSalahReminders
                                            .contains(salaah);
                                        context
                                            .read<SettingsCubit>()
                                            .toggleSpecificSalahReminder(
                                              salaah,
                                            );
                                        _showReminderSnackBar(
                                          salaah.localizedName(l10n),
                                          !isEnabled,
                                          customMessage:
                                              !isEnabled
                                                  ? (isAr
                                                      ? 'سنذكرك بتسجيل ${salaah.localizedName(l10n)} بعد الأذان'
                                                      : 'We will remind you to log ${salaah.localizedName(l10n)} after Azan')
                                                  : (isAr
                                                      ? 'تم إيقاف تذكير ${salaah.localizedName(l10n)}'
                                                      : 'Reminder for ${salaah.localizedName(l10n)} disabled'),
                                        );
                                      },
                                      onLimitExceeded: _scrollToAddQada,
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
