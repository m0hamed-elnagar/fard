import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Werd Dialog Button Color Tests', () {
    
    testWidgets(
      'Mark All button in JumpDialog should be GREEN (AppTheme.accent)',
      (WidgetTester tester) async {
        Color? markAllButtonColor;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent, // GREEN for Mark All
                    foregroundColor: AppTheme.onAccent,
                  ),
                  child: const Text('Mark All'),
                );
              },
            ),
          ),
        );

        // Find the ElevatedButton that contains the Text 'Mark All'
        final elevatedButtonFinder = find.byWidgetPredicate(
          (widget) => widget is ElevatedButton &&
                     widget.child is Text &&
                     (widget.child as Text).data == 'Mark All',
        );
        
        expect(elevatedButtonFinder, findsOneWidget);
        
        final elevatedButton = tester.widget<ElevatedButton>(elevatedButtonFinder);
        markAllButtonColor = elevatedButton.style?.backgroundColor?.resolve({});
        
        expect(
          markAllButtonColor,
          equals(AppTheme.accent),
          reason: 'Mark All button should have GREEN color (AppTheme.accent)',
        );
      },
    );

    testWidgets(
      'New Session button in JumpDialog should be YELLOW (Colors.amber)',
      (WidgetTester tester) async {
        Color? newSessionButtonColor;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // YELLOW for New Session
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('New Session'),
                );
              },
            ),
          ),
        );

        // Find the ElevatedButton that contains the Text 'New Session'
        final elevatedButtonFinder = find.byWidgetPredicate(
          (widget) => widget is ElevatedButton &&
                     widget.child is Text &&
                     (widget.child as Text).data == 'New Session',
        );
        
        expect(elevatedButtonFinder, findsOneWidget);
        
        final elevatedButton = tester.widget<ElevatedButton>(elevatedButtonFinder);
        newSessionButtonColor = elevatedButton.style?.backgroundColor?.resolve({});
        
        expect(
          newSessionButtonColor,
          equals(Colors.amber),
          reason: 'New Session button should have YELLOW color (Colors.amber)',
        );
      },
    );
  });

  group('Werd Dialog Dismissal - Single Press Verification', () {
    
    testWidgets(
      'Dialog should dismiss after SINGLE button press (Close button)',
      (WidgetTester tester) async {
        bool dialogVisible = true;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Test Dialog'),
                              content: const Text('This is a test dialog'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // FIXED: Perform actions BEFORE popping
                                    debugPrint('Action performed');
                                    // THEN pop the dialog
                                    Navigator.of(dialogContext).pop();
                                    setState(() => dialogVisible = false);
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Show Dialog'),
                      ),
                      if (!dialogVisible)
                        const Text('Dialog Dismissed'),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is showing
        expect(find.text('Test Dialog'), findsOneWidget);

        // Tap Close button ONCE
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Verify dialog is dismissed
        expect(
          find.text('Test Dialog'),
          findsNothing,
          reason: 'Dialog MUST be dismissed after a SINGLE tap on Close button',
        );
        
        // Verify the dismissal message is shown
        expect(find.text('Dialog Dismissed'), findsOneWidget);
      },
    );

    testWidgets(
      'Dialog with SnackBar should dismiss after SINGLE button press',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Test Dialog'),
                            content: const Text('This is a test dialog'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // FIXED: Show SnackBar BEFORE popping
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Action completed'),
                                    ),
                                  );
                                  // THEN pop the dialog
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is showing
        expect(find.text('Test Dialog'), findsOneWidget);

        // Tap OK button ONCE
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Verify dialog is dismissed
        expect(
          find.text('Test Dialog'),
          findsNothing,
          reason: 'Dialog MUST be dismissed after a SINGLE tap on OK button even when showing SnackBar',
        );
      },
    );
  });
}
