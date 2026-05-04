import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/presentation/manager/azkar_dialog_manager.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/home_content.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.showAddQadaOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialAddQadaDialog();
      });
    }
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('HomeScreen: App lifecycle state changed to $state');
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('HomeScreen: App resumed - triggering widget update');
        // Refresh prayer data
        final bloc = context.read<PrayerTrackerBloc>();
        bloc.state.mapOrNull(
          loaded: (s) {
            bloc.add(PrayerTrackerEvent.load(s.selectedDate));
          },
        );

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
                color: AppTheme.primaryLight,
                strokeWidth: 4.0,
              ),
            ),
          ),
          error: (message) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.missed,
                    size: 48.0,
                  ),
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
                    onPressed: () => context.read<PrayerTrackerBloc>().add(
                      PrayerTrackerEvent.load(DateTime.now()),
                    ),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          ),
          missedDaysPrompt: (_) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
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
              ) => HomeContent(
                selectedDate: selectedDate,
                missedToday: missedToday,
                completedToday: completedToday,
                qadaStatus: qadaStatus,
                completedQadaToday: completedQadaToday,
                monthRecords: monthRecords,
                history: history,
              ),
        );
      },
    );
  }
}
