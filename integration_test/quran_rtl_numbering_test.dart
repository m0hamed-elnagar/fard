import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock the compass channel
  const MethodChannel compassChannel = MethodChannel('hemanthraj/flutter_compass');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(compassChannel, (MethodCall methodCall) async {
    return null;
  });

  // Mock the just_audio channels
  const MethodChannel audioMethodsChannel = MethodChannel('com.ryanheise.just_audio.methods');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(audioMethodsChannel, (MethodCall methodCall) async {
    return {};
  });

  group('Quran RTL Numbering Integration Test', () {
    testWidgets('Verify Ayah markers are ordered RTL (3 2 1 from left to right)', (tester) async {
      // 1. Setup environment
      final tempDir = Directory.systemTemp.createTempSync('fard_rtl_test_');
      await configureDependencies(hivePath: tempDir.path);
      
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('locale', 'ar'); 

      // 2. Start app
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pump(const Duration(seconds: 2));

      // 3. Navigate to Quran tab
      final quranIcon = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(quranIcon.first);
      await tester.pump(const Duration(seconds: 2));

      // 4. Find and tap Al-Imran (Surah 3)
      debugPrint('Navigating to Al-Imran...');
      // Use the Surah number in Arabic to find it reliably
      final alImranNumberFinder = find.text('٣'); 
      final listView = find.byType(ListView).first;
      
      await tester.dragUntilVisible(
        alImranNumberFinder,
        listView,
        const Offset(0, -200),
      );
      await tester.tap(alImranNumberFinder);
      await tester.pump(const Duration(seconds: 5));

      // 5. Verify the first 3 markers positions using TextSpan geometry
      debugPrint('Verifying marker positions via TextSpan geometry...');
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets); // Might find multiple, usually the main one is large

      // Find the one that contains the Surah text (we look for a specific ayah text or marker)
      // Marker 1 in Arabic-Indic is '١' prefixed with '۝'
      final targetMarker1 = '۝١';
      final targetMarker2 = '۝٢';
      final targetMarker3 = '۝٣';

      final Finder surahTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText && widget.text.toPlainText().contains(targetMarker1)) {
          return true;
        }
        return false;
      });

      expect(surahTextFinder, findsOneWidget);
      
      final RenderObject renderObject = tester.renderObject(surahTextFinder);
      expect(renderObject, isA<RenderParagraph>());
      final RenderParagraph renderParagraph = renderObject as RenderParagraph;

      final String plainText = renderParagraph.text.toPlainText();
      
      // Helper to get center Dx of a text substring
      double getMarkerDx(String marker) {
        final int startIndex = plainText.indexOf(marker);
        if (startIndex == -1) fail('Marker $marker not found in text');
        final int endIndex = startIndex + marker.length;
        
        final List<ui.TextBox> boxes = renderParagraph.getBoxesForSelection(
          TextSelection(baseOffset: startIndex, extentOffset: endIndex),
        );
        
        if (boxes.isEmpty) fail('No boxes found for marker $marker');
        
        // Return the center of the first box (usually specific enough)
        // Convert local coordinates to global
        final Offset localCenter = boxes.first.toRect().center;
        final Offset globalCenter = renderParagraph.localToGlobal(localCenter);
        return globalCenter.dx;
      }
      
      final dx1 = getMarkerDx(targetMarker1);
      final dx2 = getMarkerDx(targetMarker2);
      final dx3 = getMarkerDx(targetMarker3);

      debugPrint('Marker 1 ($targetMarker1) global dx: $dx1');
      debugPrint('Marker 2 ($targetMarker2) global dx: $dx2');
      debugPrint('Marker 3 ($targetMarker3) global dx: $dx3');

      // In RTL, the first Ayah (Rightmost) should have largest Dx
      // Line: [Ayah 3] ... [Ayah 2] ... [Ayah 1] ->
      // Dx:   Small        Medium       Large
      
      expect(dx1, greaterThan(dx2), reason: 'Marker 1 should be to the right of Marker 2');
      expect(dx2, greaterThan(dx3), reason: 'Marker 2 should be to the right of Marker 3');

      // Clean up temp dir
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (e) {
        debugPrint('Failed to delete temp dir: $e');
      }
    });
  });
}
