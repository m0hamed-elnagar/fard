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
    return AzkarDialogManager(child: _HomeBody(showAddQadaOnStart: showAddQadaOnStart));
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
        onConfirm: (counts) => context
            .read<PrayerTrackerBloc>()
            .add(PrayerTrackerEvent.bulkAddQada(counts)),
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
    if (state == AppLifecycleState.resumed) {
      final bloc = context.read<PrayerTrackerBloc>();
      bloc.state.whenOrNull(
        loaded: (selectedDate, _, __, ___, ____, _____) {
          bloc.add(PrayerTrackerEvent.load(selectedDate));
        },
      );
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
          loaded: (selectedDate, missedToday, completedToday, qadaStatus, monthRecords,
                  history) =>
              HomeContent(
            selectedDate: selectedDate,
            missedToday: missedToday,
            completedToday: completedToday,
            qadaStatus: qadaStatus,
            monthRecords: monthRecords,
            history: history,
          ),
        );
      },
    );
  }
}
