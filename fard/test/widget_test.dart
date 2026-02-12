import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:fard/domain/repositories/prayer_repo.dart';
import 'package:fard/presentation/blocs/prayer_tracker/prayer_tracker_bloc.dart';
import 'package:fard/presentation/screens/home_screen.dart';
import 'package:fard/presentation/widgets/calendar_widget.dart';
import 'package:fard/presentation/widgets/counter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}

void main() {
  late MockPrayerRepo repo;

  setUp(() async {
    registerFallbackValue(DailyRecord(
      id: 'dummy',
      date: DateTime.now(),
      missedToday: {},
      qada: {},
    ));
    repo = MockPrayerRepo();
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerFactory<PrayerTrackerBloc>(() => PrayerTrackerBloc(repo));
  });

  testWidgets('HomeScreen renders key components', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle(); // Wait for initial load

    // Verify Calendar
    expect(find.byType(CalendarWidget), findsOneWidget);

    // Verify Counter Card
    expect(find.byType(CounterCard), findsOneWidget);

    // Verify "Fard" title
    expect(find.text('فرض'), findsOneWidget);

    // Verify Prayer Tiles
    for (final s in Salaah.values) {
      expect(find.text(s.label), findsOneWidget);
    }
  });

  testWidgets('Tapping Add button opens dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // Find '+' button on counter card (FloatingActionButton is inside CounterCard)
    // Actually CounterCard has an IconButton or similar.
    // Let's find by icon.
    final addIcon = find.widgetWithIcon(FloatingActionButton, Icons.add_rounded);
    expect(addIcon, findsOneWidget);

    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    // Verify Dialog opens
    expect(find.text('إضافة قضاء'), findsOneWidget);
  });
}
