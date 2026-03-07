import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock channels
  const MethodChannel compassChannel = MethodChannel('hemanthraj/flutter_compass');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(compassChannel, (MethodCall methodCall) async => null);

  const MethodChannel audioMethodsChannel = MethodChannel('com.ryanheise.just_audio.methods');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(audioMethodsChannel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init': return {};
      case 'load': return {'duration': 10000000};
      default: return null;
    }
  });

  group('Werd Starting Point Integration Test', () {
    testWidgets('Starting point should stay fixed after reading more ayahs', (tester) async {
      final tempDir = Directory.systemTemp.createTempSync('fard_starting_point_test_');
      await configureDependencies(hivePath: tempDir.path);
      
      final prefs = getIt<SharedPreferences>();
      await prefs.clear();
      await prefs.setBool('onboarding_complete', true);
      
      // 1. Initial State: Starting at Surah 1, Ayah 1
      await prefs.setString('werd_progress', '{"totalAyahsReadToday":0,"readAyahsToday":[],"sessionStartAbsolute":1,"lastUpdated":"2026-03-03T00:00:00.000","streak":0,"history":{}}');

      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pumpAndSettle();

      // 2. Open Reader directly
      // We'll use the route to ensure we are in the right place
      await tester.pumpWidget(MaterialApp(
        home: const QadaTrackerApp(),
        onGenerateRoute: (settings) => QuranReaderPage.route(surahNumber: 1, ayahNumber: 1),
      ));
      
      // Actually let's just use the navigator
      getIt<GlobalKey<NavigatorState>>().currentState?.push(QuranReaderPage.route(surahNumber: 1, ayahNumber: 1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 3. Verify Flag is at Ayah 1
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);

      // 4. Mark Ayah 5 as last read
      final ayah5Marker = find.text(' ۝٥ ');
      await tester.scrollUntilVisible(ayah5Marker, 500);
      await tester.tap(ayah5Marker);
      await tester.pumpAndSettle();

      final markBtn = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(markBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 5. Verify Flag is STILL at Ayah 1 and Bookmark is at Ayah 5
      // Ayah 1 is at the top, Ayah 5 is visible now
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      try { tempDir.deleteSync(recursive: true); } catch (_) {}
    });
  });
}
