import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/main.dart';
// import 'core/services/background_service.dart';
// import 'core/services/migration_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  debugPrint('--- INTERACTIVE GAP REPRO STARTING ---');
  WidgetsFlutterBinding.ensureInitialized();


  // 1. Configure dependencies
  await configureDependencies();

  // 2. Setup the "Gap" state
  final repo = getIt<PrayerRepo>();

  // Create a record from 5 days ago (March 19, 2026)
  final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
  final normalizedPast = DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day);

  final pastRecord = DailyRecord(
    id: '${normalizedPast.year}-${normalizedPast.month.toString().padLeft(2, '0')}-${normalizedPast.day.toString().padLeft(2, '0')}',
    date: normalizedPast,
    missedToday: {Salaah.fajr, Salaah.dhuhr},
    completedToday: {Salaah.asr, Salaah.maghrib, Salaah.isha},
    qada: {
      Salaah.fajr: const MissedCounter(1),
      Salaah.dhuhr: const MissedCounter(1),
      Salaah.asr: const MissedCounter(0),
      Salaah.maghrib: const MissedCounter(0),
      Salaah.isha: const MissedCounter(0),
    },
  );

  debugPrint('Cleaning database to ensure gap detection works...');
  final all = await repo.loadAllRecords();
  for (final r in all) {
    if (r.date.isAfter(normalizedPast) || r.date.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
       await repo.deleteRecord(r.date);
    }
  }

  debugPrint('Inserting seed record for: ${pastRecord.date}');
  await repo.saveToday(pastRecord);

  final notificationService = getIt<NotificationService>();
  await notificationService.init();

  debugPrint('Launching app in INTERACTIVE mode...');
  runApp(const QadaTrackerApp());

  notificationService.handleInitialNotification();
}
