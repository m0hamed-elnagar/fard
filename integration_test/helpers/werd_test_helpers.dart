import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/werd_progress_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/dashboard_carousel.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/di/injection.dart';

/// Test helper utilities for Wird integration tests
class WerdTestHelpers {
  /// Swipe to Werd card in carousel (it's on the last page)
  static Future<void> swipeToWerdCard(WidgetTester tester) async {
    debugPrint('🔄 Swiping to Werd card in carousel...');
    
    // First, try to find WerdProgressCard directly (it might already be visible)
    final werdCardDirect = find.byType(WerdProgressCard);
    if (werdCardDirect.evaluate().isNotEmpty) {
      debugPrint('✅ WerdProgressCard already visible, no swipe needed');
      return;
    }
    
    // Find the PageView inside DashboardCarousel
    final carousel = find.byType(DashboardCarousel);
    if (carousel.evaluate().isEmpty) {
      debugPrint('❌ DashboardCarousel not found!');
      dumpWidgetTree(tester);
    }
    expect(carousel, findsOneWidget, reason: 'DashboardCarousel should exist');
    
    // Find PageView that's a descendant of DashboardCarousel
    final pageView = find.descendant(
      of: carousel,
      matching: find.byType(PageView),
    );
    expect(pageView, findsOneWidget, reason: 'PageView should exist in carousel');
    
    // Swipe left to go to next page (do it twice to reach Werd card)
    await tester.drag(pageView, const Offset(-400, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.drag(pageView, const Offset(-400, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    
    // Verify Werd card is visible
    expect(
      find.byType(WerdProgressCard), 
      findsOneWidget, 
      reason: 'WerdProgressCard should be visible after swiping',
    );
    
    debugPrint('✅ Werd card is now visible');
  }

  /// Tap Continue button on Werd card
  static Future<void> tapContinueButton(WidgetTester tester) async {
    debugPrint('🎯 Tapping Continue button...');
    
    // Try to find Continue button directly (might be visible without swipe)
    Finder continueBtn = find.text('Continue');
    if (continueBtn.evaluate().isEmpty) {
      continueBtn = find.text('متابعة');
    }
    
    // If not found, swipe to Werd card
    if (continueBtn.evaluate().isEmpty) {
      await swipeToWerdCard(tester);
      
      // Try to find button again after swipe
      continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isEmpty) {
        continueBtn = find.text('متابعة');
      }
    }
    
    expect(
      continueBtn, 
      findsOneWidget, 
      reason: 'Continue button should be visible on Werd card',
    );
    
    await tester.tap(continueBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    debugPrint('✅ Continue button tapped');
  }

  /// Navigate to Quran tab using NavigationBar icon
  static Future<void> navigateToQuranTab(WidgetTester tester) async {
    debugPrint('📖 Navigating to Quran tab...');
    
    // Find Quran icon in NavigationBar
    final quranIcon = find.byIcon(Icons.menu_book_outlined);
    expect(
      quranIcon, 
      findsOneWidget, 
      reason: 'Quran navigation icon should exist in NavigationBar',
    );
    
    await tester.tap(quranIcon);
    await tester.pumpAndSettle();
    
    debugPrint('✅ Navigated to Quran tab');
  }

  /// Mark first visible ayah as last read via long press
  static Future<void> markFirstAyahAsRead(WidgetTester tester) async {
    debugPrint('📝 Marking first ayah as last read...');
    
    // Find first AyahText widget
    final ayahText = find.byType(AyahText).first;
    expect(
      ayahText, 
      findsOneWidget, 
      reason: 'At least one AyahText widget should be visible',
    );
    
    // Long press to show options
    await tester.longPress(ayahText);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    // Debug: Print what widgets are available
    debugPrint('🔍 After long press, checking available widgets...');
    final textButtons = find.byType(Text).evaluate().length;
    debugPrint('   Found $textButtons Text widgets');
    
    // Find "Mark as Last Read" button or similar
    // Try multiple strategies
    Finder? markBtn;
    
    // Strategy 1: Find by tooltip
    if (find.byTooltip('Mark as Last Read').evaluate().isNotEmpty) {
      markBtn = find.byTooltip('Mark as Last Read');
    }
    
    // Strategy 2: Find by text containing "Mark"
    if (markBtn == null && find.textContaining('Mark', findRichText: true).evaluate().isNotEmpty) {
      markBtn = find.textContaining('Mark', findRichText: true);
    }
    
    // Strategy 3: Find by icon
    if (markBtn == null && find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty) {
      markBtn = find.byIcon(Icons.bookmark_border);
    }
    
    expect(
      markBtn, 
      isNotNull, 
      reason: 'Should find a "Mark as Last Read" button after long press',
    );
    
    await tester.tap(markBtn!);
    await tester.pumpAndSettle();
    
    debugPrint('✅ Ayah marked as last read');
  }

  /// Open Edit dialog from Werd card
  static Future<void> openEditDialog(WidgetTester tester) async {
    debugPrint('✏️ Opening Edit dialog...');
    
    // Try to find Edit button directly
    final editBtn = find.byIcon(Icons.edit_rounded);
    if (editBtn.evaluate().isNotEmpty) {
      await tester.tap(editBtn);
      await tester.pumpAndSettle();
      debugPrint('✅ Edit dialog opened');
      return;
    }
    
    // If not found, swipe to Werd card first
    await swipeToWerdCard(tester);
    
    // Try again
    final editBtnAfter = find.byIcon(Icons.edit_rounded);
    expect(
      editBtnAfter, 
      findsOneWidget, 
      reason: 'Edit button should be visible on Werd card when segments exist',
    );
    
    await tester.tap(editBtnAfter);
    await tester.pumpAndSettle();
    
    debugPrint('✅ Edit dialog opened');
  }

  /// Alternative: Directly trigger events without UI (fallback)
  static Future<void> tapContinueButtonDirect(WidgetTester tester, int targetAyah) async {
    debugPrint('🎯 Directly triggering Continue event for ayah $targetAyah...');
    getIt<WerdBloc>().add(WerdEvent.startSession(targetAyah));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    debugPrint('✅ Continue event triggered');
  }

  /// Reload Werd state and wait for update
  static Future<void> reloadWerdState(WidgetTester tester) async {
    debugPrint('🔄 Reloading Werd state...');

    getIt<WerdBloc>().add(const WerdEvent.load(id: 'default'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    debugPrint('✅ Werd state reloaded');
  }

  /// Dump widget tree for debugging
  static void dumpWidgetTree(WidgetTester tester) {
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('📱 Widget Tree Dump:');
    debugPrint('╠══════════════════════════════════════╣');

    // Find all visible Text widgets with content
    final textWidgets = find.byType(Text).evaluate();
    debugPrint('📝 Text widgets found: ${textWidgets.length}');

    int count = 0;
    final textWidgetList = textWidgets.toList();
    for (var i = 0; i < textWidgetList.length && count < 30; i++) {
      try {
        final widget = textWidgetList[i].widget as Text;
        if (widget.data != null && widget.data!.isNotEmpty && widget.data!.trim().isNotEmpty) {
          debugPrint('  Text $count: "${widget.data}"');
          count++;
        }
      } catch (e) {
        // Skip widgets that can't be accessed
      }
    }

    // Find all buttons
    final elevatedButtons = find.byType(ElevatedButton).evaluate().length;
    final textButtons = find.byType(TextButton).evaluate().length;
    final iconButtons = find.byType(IconButton).evaluate().length;
    debugPrint('🔘 Buttons: Elevated=$elevatedButtons, Text=$textButtons, Icon=$iconButtons');

    // Find dialogs
    final dialogs = find.byType(Dialog).evaluate().length;
    debugPrint('💬 Dialogs found: $dialogs');

    debugPrint('╚══════════════════════════════════════╝');
  }

  /// Print current Werd state for debugging
  static void printWerdState() {
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('📊 Werd State Debug:');
    debugPrint('╠══════════════════════════════════════╣');
    
    try {
      final werdState = getIt<WerdBloc>().state;
      final progress = werdState.progress;
      
      if (progress != null) {
        debugPrint('📈 Total ayahs today: ${progress.totalAmountReadToday}');
        debugPrint('📍 Last read absolute: ${progress.lastReadAbsolute}');
        debugPrint('🎯 Session start: ${progress.sessionStartAbsolute}');
        debugPrint('📚 Segments count: ${progress.segmentsToday.length}');
        
        for (var i = 0; i < progress.segmentsToday.length; i++) {
          final seg = progress.segmentsToday[i];
          debugPrint('  Segment $i: ${seg.startAyah} → ${seg.endAyah} (${seg.ayahsCount} ayahs)');
          debugPrint('    Time: ${seg.formattedStartTime} - ${seg.formattedEndTime}');
        }
      } else {
        debugPrint('⚠️ Progress is null');
      }
    } catch (e) {
      debugPrint('❌ Error reading Werd state: $e');
    }
    
    debugPrint('╚══════════════════════════════════════╝');
  }
}
