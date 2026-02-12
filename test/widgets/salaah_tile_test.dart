import 'package:fard/domain/models/salaah.dart';
import 'package:fard/presentation/widgets/salaah_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalaahTile', () {
    testWidgets('renders all components correctly', (WidgetTester tester) async {
      bool addCalled = false;
      bool removeCalled = false;
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalaahTile(
              salaah: Salaah.fajr,
              qadaCount: 5,
              isMissedToday: true,
              onAdd: () => addCalled = true,
              onRemove: () => removeCalled = true,
              onToggleMissed: () => toggleCalled = true,
            ),
          ),
        ),
      );

      // Verify labels
      expect(find.text(Salaah.fajr.label), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('متبقي: 5'), findsOneWidget);

      // Verify toggle icon (close_rounded because isMissedToday is true)
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Test interactions
      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(addCalled, isTrue);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(removeCalled, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(toggleCalled, isTrue);
    });

    testWidgets('remove button is disabled when count is 0', (WidgetTester tester) async {
       bool removeCalled = false;

       await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalaahTile(
              salaah: Salaah.fajr,
              qadaCount: 0,
              isMissedToday: false,
              onAdd: () {},
              onRemove: () => removeCalled = true,
              onToggleMissed: () {},
            ),
          ),
        ),
      );

      // Tap remove button
      await tester.tap(find.byIcon(Icons.remove_rounded));
      
      // Should NOT have been called because it's passed as null in the widget when count is 0
      expect(removeCalled, isFalse);
    });
  });
}
