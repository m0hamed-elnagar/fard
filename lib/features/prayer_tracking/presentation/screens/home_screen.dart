import 'dart:async';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/background_prayer_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/azkar/presentation/manager/azkar_dialog_manager.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/home_content.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/core/utils/location_dialog_helper.dart';
import 'package:fard/core/services/in_app_update_service.dart';
import 'package:fard/core/services/in_app_review_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/presentation/screens/azan_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool showAddQadaOnStart;
  const HomeScreen({super.key, this.showAddQadaOnStart = false});

  @override
  Widget build(BuildContext context) {
    return AzkarDialogManager(
      child: _HomeBody(showAddQadaOnStart: showAddQadaOnStart),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final bool showAddQadaOnStart;
  const _HomeBody({this.showAddQadaOnStart = false});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with WidgetsBindingObserver {
  StreamSubscription<Salaah>? _markPrayedSubscription;
  bool _isNotificationBlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.showAddQadaOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialAddQadaDialog();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRemovedVoiceNotice();
      _checkNotificationStatus();
      if (getIt.isRegistered<InAppUpdateService>()) {
        getIt<InAppUpdateService>().checkForUpdateSilently(context);
      }
    });
    if (getIt.isRegistered<NotificationService>()) {
      _markPrayedSubscription = getIt<NotificationService>().onMarkPrayed.listen((salaah) {
        if (mounted) {
          debugPrint('HomeScreen: received mark prayed stream event for $salaah');
          context.read<PrayerTrackerBloc>().add(PrayerTrackerEvent.togglePrayer(salaah));
        }
      });
    }
  }

  Future<void> _checkNotificationStatus() async {
    if (getIt.isRegistered<NotificationService>()) {
      try {
        final isBlocked = await getIt<NotificationService>().isCountdownChannelBlocked();
        if (mounted && isBlocked != _isNotificationBlocked) {
          setState(() {
            _isNotificationBlocked = isBlocked;
          });
        }
      } catch (e) {
        debugPrint('HomeScreen: Error checking notification status: $e');
      }
    }
  }

  void _checkRemovedVoiceNotice() {
    final settingsRepo = getIt<SettingsRepository>();
    if (settingsRepo.shouldShowRemovedVoiceNotice) {
      settingsRepo.clearRemovedVoiceNotice();
      _showRemovedVoiceNoticeDialog();
    }
  }

  void _showRemovedVoiceNoticeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.voiceRemovedTitle,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.voiceRemovedDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AzanSettingsScreen(),
                ),
              );
            },
            child: Text(l10n.changeVoice),
          ),
        ],
      ),
    );
  }

  void _showInitialAddQadaDialog() {
    showDialog(
      context: context,
      builder: (context) => AddQadaDialog(
        onConfirm: (counts) => context.read<PrayerTrackerBloc>().add(
          PrayerTrackerEvent.bulkAddQada(counts),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _markPrayedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('HomeScreen: App lifecycle state changed to $state');
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('HomeScreen: App resumed - triggering widget update');
        
        // Drain any pending completed prayers from SharedPreferences first
        final prefs = getIt<SharedPreferences>();
        BackgroundPrayerSyncService.drainQueue(prefs).then((_) {
          if (mounted) {
            // Refresh prayer data
            final bloc = context.read<PrayerTrackerBloc>();
            bloc.state.mapOrNull(
              loaded: (s) {
                bloc.add(PrayerTrackerEvent.load(s.selectedDate));
              },
            );
          }
        });

        // Check if notification settings changed while app was in background
        _checkNotificationStatus();
        if (getIt.isRegistered<InAppUpdateService>()) {
          getIt<InAppUpdateService>().onResumeCheck(context);
        }

        // Refresh widget with latest data (includes locale, location, prayer times)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('HomeScreen: App resumed - triggering widget update');
          getIt<WidgetUpdateService>().updateWidget();
        });
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        debugPrint('HomeScreen: App pausing - flushing widget update');
        // Flush data and update widget before app backgrounds
        // This is the last reliable moment before Android may kill the process
        _flushAndUpdateWidget();
        break;

      default:
        break;
    }
  }

  /// Flushes current data to SharedPreferences and triggers widget update.
  /// Called when app is about to background to prevent lost updates.
  Future<void> _flushAndUpdateWidget() async {
    try {
      await getIt<WidgetUpdateService>().updateWidget();
    } catch (e) {
      // Silently fail - widget update is not critical
      debugPrint('Failed to update widget on pause: $e');
    }
  }

  Widget _buildBlockedNotificationBanner(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final text = isAr 
        ? "إشعارات مؤقت الصلاة معطلة في النظام. اضغط هنا لتفعيلها."
        : "Countdown notifications are blocked. Tap here to enable in settings.";

    return Material(
      color: colorScheme.errorContainer,
      child: InkWell(
        onTap: () {
          getIt<NotificationService>().openNotificationSettings();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.0,
                color: colorScheme.onErrorContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateStreak(List<DailyRecord> history) {
    if (history.isEmpty) return 0;
    final sorted = List<DailyRecord>.from(history)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? currentCheck = DateTime.now();

    for (final record in sorted) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      final checkDate = DateTime(currentCheck!.year, currentCheck.month, currentCheck.day);
      final diff = checkDate.difference(recordDate).inDays;

      if (diff > 1 && streak > 0) {
        break;
      }

      final hasActivity = record.completedToday.isNotEmpty ||
          record.completedQada.values.any((v) => v > 0);

      if (hasActivity) {
        streak++;
        currentCheck = recordDate;
      } else if (diff > 0) {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<LocationPrayerCubit, LocationPrayerState>(
      listenWhen: (prev, curr) =>
          curr.lastLocationStatus != null &&
          curr.lastLocationStatus != prev.lastLocationStatus,
      listener: (context, state) =>
          LocationDialogHelper.showLocationStatusDialog(context, state.lastLocationStatus!),
      child: BlocConsumer<PrayerTrackerBloc, PrayerTrackerState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: colorScheme.error,
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
            loading: () => Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 4.0,
                ),
              ),
            ),
            error: (message) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 48.0,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      AppLocalizations.of(context)!.errorOccurred,
                      style: GoogleFonts.amiri(
                        color: colorScheme.onSurface,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () => context.read<PrayerTrackerBloc>().add(
                        PrayerTrackerEvent.load(DateTime.now()),
                      ),
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ),
            ),
            missedDaysPrompt: (_) => Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: colorScheme.secondary,
                  strokeWidth: 4.0,
                ),
              ),
            ),
            loaded:
                (
                  selectedDate,
                  missedToday,
                  completedToday,
                  qadaStatus,
                  completedQadaToday,
                  monthRecords,
                  history,
                ) {
                  final streak = _calculateStreak(history);
                  if (getIt.isRegistered<InAppReviewService>()) {
                    getIt<InAppReviewService>().checkAndPromptReviewIfEligible(currentStreak: streak);
                  }

                  bool showCountdown = false;
                  try {
                    showCountdown = getIt<SettingsRepository>().showSalahCountdownNotification;
                  } catch (_) {
                    showCountdown = false;
                  }
                  final showBanner = _isNotificationBlocked && showCountdown;
                  
                  final homeContent = HomeContent(
                    selectedDate: selectedDate,
                    missedToday: missedToday,
                    completedToday: completedToday,
                    qadaStatus: qadaStatus,
                    completedQadaToday: completedQadaToday,
                    monthRecords: monthRecords,
                    history: history,
                  );
                  
                  if (!showBanner) return homeContent;
                  
                  return Column(
                    children: [
                      _buildBlockedNotificationBanner(context),
                      Expanded(child: homeContent),
                    ],
                  );
                },
          );
        },
      ),
    );
  }
}
