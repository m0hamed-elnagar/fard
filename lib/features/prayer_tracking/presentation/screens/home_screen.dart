import 'package:fard/features/azkar/presentation/manager/azkar_dialog_manager.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/home_content.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AzkarDialogManager(child: _HomeBody());
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
              HomeContent(
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
}
