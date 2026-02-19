import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate to Quran Library tab and check for crash', (tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Verify we are on the home screen initially
    expect(find.byIcon(Icons.mosque_outlined), findsOneWidget);

    // Tap on the Quran Library tab (The Mushaf)
    // The label is 'المصحف' and icon is Icons.library_books_outlined
    final libraryTab = find.byIcon(Icons.library_books_outlined);
    expect(libraryTab, findsOneWidget);
    
    await tester.tap(libraryTab);
    await tester.pumpAndSettle();

    // Verify we are on the Quran Library page
    // We can look for the "QuranLibraryPage" widget or unique text from the library
    // Since we can't easily access the library's internal widgets by key, we'll check if the tab is selected
    // and if the app hasn't crashed.
    
    // If the library shows a SnackBar about internet, it might appear now.
    // We wait a bit to ensure async operations (like network checks) complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    // If it crashes, the test will fail here.
    
    // Check for some text that might be on the library screen
    // The library has tabs like "الفهرس" (Index)
    expect(find.text('الفهرس'), findsOneWidget);
  });
}
