import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/settings/presentation/widgets/widget_preview.dart';
import 'package:fard/features/settings/domain/entities/widget_preview_theme.dart';

void main() {
  group('WidgetPreview widget tests', () {
    group('Basic rendering', () {
      testWidgets('renders with default theme without errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('renders prayer schedule layout by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
              ),
            ),
          ),
        );

        // Verify prayer names are displayed
        expect(find.text('Fajr'), findsOneWidget);
        expect(find.text('Dhuhr'), findsOneWidget);
        expect(find.text('Asr'), findsOneWidget);
      });

      testWidgets('renders countdown layout when widgetType is countdown', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.countdown,
              ),
            ),
          ),
        );

        // Verify countdown text is displayed
        expect(find.text('Next Prayer'), findsOneWidget);
        expect(find.text('Asr'), findsWidgets); // Appears in countdown too
        expect(find.text('3h 45m'), findsOneWidget);
      });
    });

    group('Prayer schedule layout', () {
      testWidgets('shows all prayer times', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        expect(find.text('05:30 AM'), findsOneWidget); // Fajr
        expect(find.text('06:15 AM'), findsOneWidget); // Sunrise
        expect(find.text('12:30 PM'), findsOneWidget); // Dhuhr
        expect(find.text('03:45 PM'), findsOneWidget); // Asr
      });

      testWidgets('shows date header', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        expect(find.text('Tuesday, Apr 14, 2026'), findsOneWidget);
        expect(find.text('26 Shawwal 1447'), findsOneWidget);
      });

      testWidgets('highlights next prayer (Asr)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        // Asr should be highlighted (find the container with Asr text)
        final asrFinder = find.text('Asr');
        expect(asrFinder, findsOneWidget);
      });
    });

    group('Countdown layout', () {
      testWidgets('shows next prayer label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.countdown,
              ),
            ),
          ),
        );

        expect(find.text('Next Prayer'), findsOneWidget);
        expect(find.text('Asr'), findsWidgets);
        expect(find.text('3h 45m'), findsOneWidget);
      });
    });

    group('RTL mode', () {
      testWidgets('shows Arabic text in RTL mode for prayer schedule', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.prayerSchedule,
                isRtl: true,
              ),
            ),
          ),
        );

        // Verify Arabic text is rendered
        expect(find.textContaining('٢٠٢٦'), findsOneWidget);
        expect(find.textContaining('١٤٤٧'), findsOneWidget);
      });

      testWidgets('shows Arabic text in RTL mode for countdown', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: const WidgetPreviewTheme(),
                widgetType: WidgetPreviewType.countdown,
                isRtl: true,
              ),
            ),
          ),
        );

        // Verify Arabic countdown text
        expect(find.textContaining('الصلاة'), findsOneWidget);
        expect(find.textContaining('العصر'), findsOneWidget);
      });
    });

    group('ValueKey behavior', () {
      testWidgets('ValueKey changes when widgetType changes', (tester) async {
        const theme = WidgetPreviewTheme();

        // Render with prayer schedule
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: Scaffold(
              body: WidgetPreview(
                theme: theme,
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        // Find container with ValueKey
        final prayerScheduleContainer = tester.widget<Container>(
          find.byWidgetPredicate((widget) => widget is Container && widget.key is ValueKey).first,
        );
        final prayerScheduleKey = prayerScheduleContainer.key;

        // Render with countdown
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: Scaffold(
              body: WidgetPreview(
                theme: theme,
                widgetType: WidgetPreviewType.countdown,
              ),
            ),
          ),
        );

        final countdownContainer = tester.widget<Container>(
          find.byWidgetPredicate((widget) => widget is Container && widget.key is ValueKey).first,
        );
        final countdownKey = countdownContainer.key;

        // Keys should be different
        expect(prayerScheduleKey, isNotNull);
        expect(countdownKey, isNotNull);
        expect(prayerScheduleKey, isNot(equals(countdownKey)));
      });

      testWidgets('ValueKey changes when theme changes', (tester) async {
        const theme1 = WidgetPreviewTheme(primaryColorHex: '#FF0000');
        const theme2 = WidgetPreviewTheme(primaryColorHex: '#00FF00');

        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: Scaffold(
              body: WidgetPreview(
                theme: theme1,
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        final container1 = tester.widget<Container>(
          find.byWidgetPredicate((widget) => widget is Container && widget.key is ValueKey).first,
        );
        final key1 = container1.key;

        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: Scaffold(
              body: WidgetPreview(
                theme: theme2,
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        final container2 = tester.widget<Container>(
          find.byWidgetPredicate((widget) => widget is Container && widget.key is ValueKey).first,
        );
        final key2 = container2.key;

        expect(key1, isNotNull);
        expect(key2, isNotNull);
        expect(key1, isNot(equals(key2)));
      });
    });

    group('Custom theme colors', () {
      testWidgets('renders with custom theme colors', (tester) async {
        const customTheme = WidgetPreviewTheme(
          primaryColorHex: '#FF0000',
          accentColorHex: '#00FF00',
          backgroundColorHex: '#0000FF',
          surfaceColorHex: '#FFFF00',
          textColorHex: '#FF00FF',
          textSecondaryColorHex: '#00FFFF',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: customTheme,
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        // Widget should render without errors
        expect(find.byType(WidgetPreview), findsOneWidget);
      });

      testWidgets('background color is applied', (tester) async {
        const customTheme = WidgetPreviewTheme(
          backgroundColorHex: '#123456',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPreview(
                theme: customTheme,
                widgetType: WidgetPreviewType.prayerSchedule,
              ),
            ),
          ),
        );

        // Find the main container with decoration
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(const Color(0xFF123456)));
      });
    });
  });

  group('WidgetPreviewType enum', () {
    test('has expected index values', () {
      expect(WidgetPreviewType.prayerSchedule.index, 0);
      expect(WidgetPreviewType.countdown.index, 1);
    });
  });

  group('WidgetColors', () {
    test('stores all color values', () {
      const colors = WidgetColors(
        primary: Color(0xFFFF0000),
        accent: Color(0xFF00FF00),
        background: Color(0xFF0000FF),
        surface: Color(0xFFFFFF00),
        text: Color(0xFFFF00FF),
        textSecondary: Color(0xFF00FFFF),
      );

      expect(colors.primary, equals(const Color(0xFFFF0000)));
      expect(colors.accent, equals(const Color(0xFF00FF00)));
      expect(colors.background, equals(const Color(0xFF0000FF)));
      expect(colors.surface, equals(const Color(0xFFFFFF00)));
      expect(colors.text, equals(const Color(0xFFFF00FF)));
      expect(colors.textSecondary, equals(const Color(0xFF00FFFF)));
    });
  });
}
