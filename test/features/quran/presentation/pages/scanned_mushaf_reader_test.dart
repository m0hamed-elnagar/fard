import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/presentation/pages/scanned_mushaf_reader_page.dart';
import 'package:fard/features/quran/presentation/widgets/scanned/mushaf_page_item.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

class MockMushafDownloadService extends Mock implements MushafDownloadService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFile extends Mock implements File {}

void main() {
  late MockAudioBloc mockAudioBloc;
  late MockWerdBloc mockWerdBloc;
  late MockMushafDownloadService mockDownloadService;
  late MockSharedPreferences mockSharedPreferences;
  late StreamController<AudioState> audioStateController;

  setUpAll(() {
    registerFallbackValue(const AudioState());
    registerFallbackValue(AudioEvent.stop());
    registerFallbackValue(const WerdEvent.load());
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockAudioBloc = MockAudioBloc();
    mockWerdBloc = MockWerdBloc();
    mockDownloadService = MockMushafDownloadService();
    mockSharedPreferences = MockSharedPreferences();
    audioStateController = StreamController<AudioState>.broadcast();

    getIt.registerSingleton<MushafDownloadService>(mockDownloadService);
    getIt.registerSingleton<SharedPreferences>(mockSharedPreferences);

    when(() => mockSharedPreferences.getBool(any())).thenReturn(false);
    when(
      () => mockSharedPreferences.setBool(any(), any()),
    ).thenAnswer((_) async => true);

    when(() => mockAudioBloc.state).thenReturn(const AudioState());
    when(
      () => mockAudioBloc.stream,
    ).thenAnswer((_) => audioStateController.stream);
    when(() => mockWerdBloc.state).thenReturn(const WerdState());

    when(
      () => mockDownloadService.prefetchPages(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDownloadService.getLocalFile(any()),
    ).thenAnswer((_) async => File('lib/main.dart'));
    when(
      () => mockDownloadService.downloadAllPages(),
    ).thenAnswer((_) => Stream.fromIterable([0.1, 0.5, 1.0]));
  });

  tearDown(() {
    audioStateController.close();
  });

  Widget createWidgetUnderTest({int initialPage = 1}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioBloc>.value(value: mockAudioBloc),
        BlocProvider<WerdBloc>.value(value: mockWerdBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: ScannedMushafReaderPage(initialPage: initialPage),
        ),
      ),
    );
  }

  bool findDigit(WidgetTester tester, String digit) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String arabicDigit = '';
    for (var i = 0; i < digit.length; i++) {
      final d = int.tryParse(digit[i]);
      if (d != null) {
        arabicDigit += arabicDigits[d];
      } else {
        arabicDigit += digit[i];
      }
    }

    final found = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final text = widget.data ?? '';
        return text.contains(digit) || text.contains(arabicDigit);
      }
      return false;
    });
    return found.evaluate().isNotEmpty;
  }

  testWidgets('renders MushafPageItem and AppBar', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MushafPageItem), findsOneWidget);
    expect(findDigit(tester, '1'), isTrue);
  });

  testWidgets('navigation buttons update current page', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));

    // In RTL, Icons.chevron_right is "Next" (page 2)
    final nextButton = find.byIcon(Icons.chevron_right);
    await tester.tap(nextButton);
    // Multi-pump for animation
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(findDigit(tester, '2'), isTrue);
  });

  testWidgets('swiping updates page and triggers events', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));

    // In RTL (Arabic), to go to the next page (index 0 -> 1),
    // we drag from Left to Right (Positive Offset).
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(findDigit(tester, '2'), isTrue);
  });

  testWidgets('AudioBloc state changes update reader page', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));

    final newState = const AudioState().copyWith(
      status: AudioStatus.playing,
      currentSurah: 2,
      currentAyah: 1,
    );

    audioStateController.add(newState);
    when(() => mockAudioBloc.state).thenReturn(newState);

    // Pump many times to allow listener and animation to complete
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(findDigit(tester, '2'), isTrue);
  });

  testWidgets('Dark mode toggle updates UI and saves preference', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));

    final darkModeButton = find.byIcon(Icons.dark_mode_rounded);
    await tester.tap(darkModeButton);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    final pageItem = tester.widget<MushafPageItem>(find.byType(MushafPageItem));
    expect(pageItem.isDarkMode, true);
    verify(
      () => mockSharedPreferences.setBool('scanned_mushaf_dark_mode', true),
    ).called(1);
  });

  testWidgets('Loads dark mode preference on init', (tester) async {
    when(
      () => mockSharedPreferences.getBool('scanned_mushaf_dark_mode'),
    ).thenReturn(true);

    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    final pageItem = tester.widget<MushafPageItem>(find.byType(MushafPageItem));
    expect(pageItem.isDarkMode, true);
  });

  testWidgets('MushafPageItem handles retry on failure', (tester) async {
    // 1. Initial failure
    final mockFileFailure = MockFile();
    when(() => mockFileFailure.exists()).thenAnswer((_) async => false);
    when(
      () => mockDownloadService.getLocalFile(any()),
    ).thenAnswer((_) async => mockFileFailure);
    when(
      () => mockDownloadService.downloadPage(any()),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest(initialPage: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Should show error icon and retry button
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final retryButton = find.byType(ElevatedButton);
    expect(retryButton, findsOneWidget);

    // 2. Mock success for retry
    // Use a real image file from assets that we know exists
    final successFile = File('assets/pages/1.png');
    when(
      () => mockDownloadService.getLocalFile(any()),
    ).thenAnswer((_) async => successFile);

    await tester.tap(retryButton);
    await tester.runAsync(() async {
      await tester.pump(const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(seconds: 1));

    // Error should be gone
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });
}
