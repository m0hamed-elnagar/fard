import 'package:fard/core/di/injection.dart';
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
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
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';

import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  Timer? _azkarTimer;
  DateTime? _lastShownDate;

  @override
  void initState() {
    super.initState();
    // Check every minute
    _azkarTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAzkarTime();
    });
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAzkarTime();
    });
  }

  @override
  void dispose() {
    _azkarTimer?.cancel();
    super.dispose();
  }

  void _checkAzkarTime() {
    if (!mounted) return;

    final settings = context.read<SettingsCubit>().state;
    final azkarState = context.read<AzkarBloc>().state;
    if (azkarState.categories.isEmpty) return;

    final now = DateTime.now();
    
    // Prevent showing multiple times a day for the same category
    if (_lastShownDate != null && 
        _lastShownDate!.year == now.year && 
        _lastShownDate!.month == now.month && 
        _lastShownDate!.day == now.day) {
      return;
    }

    DateTime morningTime;
    DateTime eveningTime;

    if (settings.autoAzkarTimes && settings.latitude != null && settings.longitude != null) {
      try {
        final prayerTimes = getIt<PrayerTimeService>().getPrayerTimes(
          latitude: settings.latitude!,
          longitude: settings.longitude!,
          method: settings.calculationMethod,
          madhab: settings.madhab,
          date: now,
        );
        morningTime = prayerTimes.fajr;
        eveningTime = prayerTimes.asr;
      } catch (_) {
        morningTime = _parseTime(settings.morningAzkarTime, now);
        eveningTime = _parseTime(settings.eveningAzkarTime, now);
      }
    } else {
      morningTime = _parseTime(settings.morningAzkarTime, now);
      eveningTime = _parseTime(settings.eveningAzkarTime, now);
    }

    String? category;
    String? title;

    final l10n = AppLocalizations.of(context)!;

    // Show dialog exactly at the time (within the 1-minute window)
    if (now.hour == morningTime.hour && now.minute == morningTime.minute) {
      category = azkarState.categories.firstWhere(
        (c) => c.contains('الصباح') || c.contains('Morning'),
        orElse: () => '',
      );
      title = l10n.morningAzkar;
    } else if (now.hour == eveningTime.hour && now.minute == eveningTime.minute) {
      category = azkarState.categories.firstWhere(
        (c) => c.contains('المساء') || c.contains('Evening'),
        orElse: () => '',
      );
      title = l10n.eveningAzkar;
    }

    if (category != null && category.isNotEmpty) {
      _lastShownDate = now;
      _showAzkarDialog(category, title!);
    }
  }

  void _showAzkarDialog(String category, String title) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppTheme.accent),
            const SizedBox(width: 12),
            Text(l10n.timeFor, style: GoogleFonts.amiri(fontSize: 18)),
          ],
        ),
        content: Text(
          '${l10n.localeName == 'ar' ? 'حان وقت' : 'It is time for'} $title. ${l10n.localeName == 'ar' ? 'هل تريد قراءتها الآن؟' : 'Would you like to read it now?'}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarListScreen(category: category),
                ),
              );
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return now;
    }
  }

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
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 52.0, top: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.location_off_rounded, size: 14, color: AppTheme.missed),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.locationNotSet,
                                    style: const TextStyle(
                                      color: AppTheme.missed,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
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
                // Suggested Azkar Section
                _buildSuggestedAzkarSection(context, settings),
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

  Widget _buildSuggestedAzkarSection(BuildContext context, SettingsState settings) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, azkarState) {
        if (azkarState.categories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        final now = DateTime.now();
        DateTime morningTime;
        DateTime eveningTime;

        if (settings.autoAzkarTimes && settings.latitude != null && settings.longitude != null) {
          try {
            final prayerTimes = getIt<PrayerTimeService>().getPrayerTimes(
              latitude: settings.latitude!,
              longitude: settings.longitude!,
              method: settings.calculationMethod,
              madhab: settings.madhab,
              date: now,
            );
            morningTime = prayerTimes.fajr;
            eveningTime = prayerTimes.asr;
          } catch (_) {
            morningTime = _parseTime(settings.morningAzkarTime, now);
            eveningTime = _parseTime(settings.eveningAzkarTime, now);
          }
        } else {
          morningTime = _parseTime(settings.morningAzkarTime, now);
          eveningTime = _parseTime(settings.eveningAzkarTime, now);
        }

        String categoryToOpen = '';
        String? displayTitle;
        IconData? icon;
        List<Color>? colors;

        final l10n = AppLocalizations.of(context)!;

        if (now.isAfter(morningTime.subtract(const Duration(minutes: 30))) && 
            now.isBefore(morningTime.add(const Duration(hours: 4)))) {
          categoryToOpen = azkarState.categories.firstWhere(
            (c) => c.contains('الصباح') || c.contains('Morning'),
            orElse: () => '',
          );
          if (categoryToOpen.isNotEmpty) {
            displayTitle = l10n.morningAzkar;
            icon = Icons.wb_sunny_rounded;
            colors = [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.8)];
          }
        } else if (now.isAfter(eveningTime.subtract(const Duration(minutes: 30))) && 
                   now.isBefore(eveningTime.add(const Duration(hours: 4)))) {
          categoryToOpen = azkarState.categories.firstWhere(
            (c) => c.contains('المساء') || c.contains('Evening'),
            orElse: () => '',
          );
          if (categoryToOpen.isNotEmpty) {
            displayTitle = l10n.eveningAzkar;
            icon = Icons.nightlight_round;
            colors = [const Color(0xFF7986CB), const Color(0xFF5C6BC0)];
          }
        }

        if (categoryToOpen.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AzkarListScreen(category: categoryToOpen),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors!.first.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.first.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: colors.first, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.first,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.timeFor,
                                style: GoogleFonts.outfit(
                                  color: colors.first,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            displayTitle!,
                            style: GoogleFonts.amiri(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: colors.first, size: 18),
                  ],
                ),
              ),
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
      child: Icon(Icons.mosque_rounded, color: AppTheme.onPrimary, size: 22.0),
    );
  }
}
