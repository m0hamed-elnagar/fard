import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:fard/presentation/widgets/counter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterCard', () {
    final status = {
      for (var s in Salaah.values) s: const MissedCounter(10)
    };

    testWidgets('displays total remaining count correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterCard(
              qadaStatus: status,
              todayMissedCount: 2,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      // Total = 5 * 10 = 50
      expect(find.text('50'), findsOneWidget);
      // Missed today badge
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('expands to show breakdown on tap', (WidgetTester tester) async {
       await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CounterCard(
                qadaStatus: status,
                todayMissedCount: 0,
                onAddPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Initially breakdown is hidden (Simplified check: look for prayer labels)
      // Note: AnimatedCrossFade might have both in tree depending on state.
      // But we can check for visibility if we want to be strict.
      
      // Tap to expand
      await tester.tap(find.text('المتبقي'));
      await tester.pumpAndSettle();

      // Now breakdown should be visible
      for (var s in Salaah.values) {
        expect(find.text(s.label), findsOneWidget);
        expect(find.text('10'), findsAtLeast(1));
      }
    });
  });
}
