import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('HistoryList displays records correctly', (WidgetTester tester) async {
    final record = DailyRecord(
      id: 'test',
      date: DateTime(2024, 2, 17),
      missedToday: {Salaah.fajr},
      qada: {
        Salaah.fajr: const MissedCounter(10),
        Salaah.dhuhr: const MissedCounter(0),
        Salaah.asr: const MissedCounter(0),
        Salaah.maghrib: const MissedCounter(0),
        Salaah.isha: const MissedCounter(0),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: HistoryList(
            records: [record],
            onDelete: (_) {},
          ),
        ),
      ),
    );

    // Initial state might be collapsed, depends on implementation (sortedKeys.first is expanded)
    await tester.pumpAndSettle();

    // Individual salaah count 10 should NO LONGER be there
    expect(find.text('10'), findsNothing);
    
    // Check for missed icon (close_rounded) for Fajr
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    
    // Check for check icons for other prayers (4 other prayers)
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(4));
    
    // Check if Fajr is styled as missed (using its text name which should be there)
    // We can't easily check colors here without more complex logic, but we confirmed count and icons.
  });
}
