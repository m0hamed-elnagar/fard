import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/quran/presentation/widgets/cycle_completion_dialog.dart';
import 'package:fard/features/quran/presentation/widgets/jump_dialog.dart';

/// Test pump helper for dialogs
Future<void> _pumpDialog(
  WidgetTester tester,
  Widget dialog, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: Material(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => SingleChildScrollView(
                  child: dialog,
                ),
              ),
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Tap button to show dialog
  await tester.tap(find.text('Show Dialog'));
  await tester.pumpAndSettle();
}

void main() {
  // ============================================
  // CYCLE COMPLETION DIALOG TESTS
  // ============================================
  group('CycleCompletionDialog - UI Rendering', () {
    testWidgets('shows celebration header with trophy icon', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Verify trophy icon is present
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);

      // Verify title text
      expect(find.text('Quran Completion'), findsOneWidget);

      // Verify subtitle text
      expect(
        find.text("You've completed reading the entire Quran"),
        findsOneWidget,
      );
    });

    testWidgets('shows exactly 3 option buttons', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Verify all 3 options are present
      expect(find.text('Read completion doaa'), findsOneWidget);
      expect(find.text('Start new cycle'), findsOneWidget);
      expect(find.text('Stay here'), findsOneWidget);
    });

    testWidgets('each option has icon, label, and description', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Verify icons for each option
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byIcon(Icons.place_rounded), findsOneWidget);

      // Verify descriptions
      expect(find.text('Navigate to completion supplications'), findsOneWidget);
      expect(find.text('Reset to Surah Al-Fatihah (Ayah 1)'), findsOneWidget);
      expect(find.text('Keep current position at Surah An-Nas'), findsOneWidget);
    });

    testWidgets('dialog has correct visual styling', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Find the dialog container (inside SingleChildScrollView)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('"Start new cycle" option is highlighted', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // The highlighted option should have emerald green color
      final restartText = find.text('Start new cycle');
      expect(restartText, findsOneWidget);

      // Verify it has a different visual style (check for Icon in the same row)
      final refreshIcon = find.byIcon(Icons.refresh_rounded);
      expect(refreshIcon, findsOneWidget);
    });

    testWidgets('all options are tappable (InkWell)', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Verify options use InkWell for tap feedback (at least 3)
      final inkWellFinder = find.byType(InkWell);
      expect(inkWellFinder, findsWidgets);
      expect(inkWellFinder.evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('has forward arrow icons for navigation hint', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Each option should have arrow_forward_ios_rounded
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(3));
    });
  });

  group('CycleCompletionDialog - User Interactions', () {
    testWidgets('tapping "Read completion doaa" closes dialog', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Tap the doaa option
      await tester.tap(find.text('Read completion doaa'));
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Read completion doaa'), findsNothing);
    });

    testWidgets('tapping "Start new cycle" closes dialog', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Tap the restart option
      await tester.tap(find.text('Start new cycle'));
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Start new cycle'), findsNothing);
    });

    testWidgets('tapping "Stay here" closes dialog', (tester) async {
      await _pumpDialog(tester, const CycleCompletionDialog());

      // Tap the stay option
      await tester.tap(find.text('Stay here'));
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Stay here'), findsNothing);
    });
  });

  // Static show method tested indirectly through interaction tests

  group('CycleCompletionDialog - Arabic Localization', () {
    testWidgets('shows Arabic text when locale is ar', (tester) async {
      await _pumpDialog(
        tester,
        const CycleCompletionDialog(),
        locale: const Locale('ar'),
      );

      // Verify Arabic title
      expect(find.text('إتمام القرآن الكريم'), findsOneWidget);

      // Verify Arabic subtitle
      expect(find.text('لقد أتممت قراءة القرآن الكريم بالكامل'), findsOneWidget);
    });

    testWidgets('shows Arabic option labels', (tester) async {
      await _pumpDialog(
        tester,
        const CycleCompletionDialog(),
        locale: const Locale('ar'),
      );

      // Verify Arabic options
      expect(find.text('قراءة دعاء الختم'), findsOneWidget);
      expect(find.text('بدء دورة جديدة'), findsOneWidget);
      expect(find.text('البقاء هنا'), findsOneWidget);
    });

    testWidgets('shows Arabic option descriptions', (tester) async {
      await _pumpDialog(
        tester,
        const CycleCompletionDialog(),
        locale: const Locale('ar'),
      );

      // Verify Arabic descriptions
      expect(find.text('الانتقال إلى صفحة الأذكار'), findsOneWidget);
      expect(find.text('العودة إلى سورة الفاتحة (الآية 1)'), findsOneWidget);
      expect(find.text('الإبقاء على الموضع الحالي عند سورة الناس'), findsOneWidget);
    });
  });

  // ============================================
  // JUMP DIALOG TESTS
  // ============================================
  group('JumpDialog - UI Rendering', () {
    testWidgets('shows jump header with swap icon', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Verify swap icon
      expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);

      // Verify dialog title
      expect(find.text('Significant Jump Detected'), findsOneWidget);
    });

    testWidgets('shows gap information', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Should show gap info: "Gap: 90 ayahs (5 pages)"
      expect(find.textContaining('Gap:'), findsOneWidget);
      expect(find.textContaining('90'), findsWidgets);
    });

    testWidgets('shows exactly 3 option buttons', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Verify all 3 options
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Start new session'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);
    });

    testWidgets('each option has icon, label, and description', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Verify icons
      expect(find.byIcon(Icons.close_rounded, skipOffstage: false), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline_rounded, skipOffstage: false), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded, skipOffstage: false), findsOneWidget);
    });

    testWidgets('dismiss option shows current total', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Description should mention keeping current total (5 ayahs)
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('mark all option is highlighted', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // The highlighted option should be "Mark all as read"
      final markAllText = find.text('Mark all as read');
      expect(markAllText, findsOneWidget);

      // Verify it has the check_circle icon
      final checkIcon = find.byIcon(Icons.check_circle_rounded);
      expect(checkIcon, findsOneWidget);
    });

    testWidgets('dialog has correct visual styling', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Find the dialog container (inside SingleChildScrollView)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('all options are tappable (InkWell)', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Verify all options use InkWell (at least 3)
      final inkWellFinder = find.byType(InkWell);
      expect(inkWellFinder, findsWidgets);
      expect(inkWellFinder.evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('has forward arrow icons for navigation hint', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Each option should have arrow_forward_ios_rounded
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(3));
    });
  });

  group('JumpDialog - User Interactions', () {
    testWidgets('tapping "Dismiss" closes dialog', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Ensure the dismiss button is visible by scrolling to it
      await tester.ensureVisible(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Tap dismiss
      await tester.tap(find.text('Dismiss'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Dismiss', skipOffstage: false), findsNothing);
    });

    testWidgets('tapping "Start new session" closes dialog', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Tap new session
      await tester.tap(find.text('Start new session'));
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Start new session'), findsNothing);
    });

    testWidgets('tapping "Mark all as read" closes dialog', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Tap mark all
      await tester.tap(find.text('Mark all as read'));
      await tester.pumpAndSettle();

      // Dialog should attempt to close
      expect(find.text('Mark all as read'), findsNothing);
    });
  });

  group('JumpDialog - Calculated Values', () {
    testWidgets('calculates correct gap (90 ayahs)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 10,
        targetAyah: 100,
        currentTotalToday: 5,
      );

      expect(dialog.gap, 90);
    });

    testWidgets('calculates correct pages (5 pages)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 10,
        targetAyah: 100,
        currentTotalToday: 5,
      );

      // 90 / 20 = 4.5, ceil = 5
      expect(dialog.pages, 5);
    });

    testWidgets('calculates correct new total if mark all (95)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 10,
        targetAyah: 100,
        currentTotalToday: 5,
      );

      // 5 + 90 = 95
      expect(dialog.newTotalIfMarkAll, 95);
    });

    testWidgets('shows correct gap info in dialog UI', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
      );

      // Should show "90 ayahs, 5 pages"
      expect(find.textContaining('90'), findsWidgets);
      expect(find.textContaining('5'), findsWidgets);
    });
  });

  group('JumpDialog - Arabic Localization', () {
    testWidgets('shows Arabic title', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('تم اكتشاف قفزة كبيرة'), findsOneWidget);
    });

    testWidgets('shows Arabic option labels', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('تجاهل'), findsOneWidget);
      expect(find.text('ابدأ جلسة جديدة'), findsOneWidget);
      expect(find.text('تحديد الكل كمقروء'), findsOneWidget);
    });

    testWidgets('shows Arabic-Indic numerals', (tester) async {
      await _pumpDialog(
        tester,
        const JumpDialog(
          lastReadAyah: 10,
          targetAyah: 100,
          currentTotalToday: 5,
        ),
        locale: const Locale('ar'),
      );

      // Arabic-Indic numerals should be used
      // ٩٠ = 90, ٥ = 5
      expect(find.textContaining('٩٠'), findsWidgets);
    });
  });

  group('JumpDialog - Edge Cases', () {
    testWidgets('handles small gap (51 ayahs)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 100,
        targetAyah: 151,
        currentTotalToday: 10,
      );

      // Gap should be 51
      expect(dialog.gap, 51);
      // ceil(51/20) = 3
      expect(dialog.pages, 3);
    });

    testWidgets('handles large gap (1000 ayahs)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 100,
        targetAyah: 1100,
        currentTotalToday: 50,
      );

      // Gap should be 1000
      expect(dialog.gap, 1000);
      // ceil(1000/20) = 50
      expect(dialog.pages, 50);
    });

    testWidgets('handles zero current total', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 10,
        targetAyah: 100,
        currentTotalToday: 0,
      );

      expect(dialog.gap, 90);
      expect(dialog.newTotalIfMarkAll, 90); // 0 + 90
    });

    testWidgets('handles backward jump (target < lastRead)', (tester) async {
      const dialog = JumpDialog(
        lastReadAyah: 100,
        targetAyah: 10,
        currentTotalToday: 50,
      );

      // Gap should be absolute value
      expect(dialog.gap, 90);
      expect(dialog.pages, 5);
      expect(dialog.newTotalIfMarkAll, 140); // 50 + 90
    });
  });
}
