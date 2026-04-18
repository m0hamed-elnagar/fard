import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/blocs/connectivity/connectivity_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/connectivity_service.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/utils/offline_audio_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioBloc extends MockBloc<AudioEvent, AudioState> implements AudioBloc {}
class MockConnectivityBloc extends MockBloc<ConnectivityEvent, ConnectivityState> implements ConnectivityBloc {}
class MockAudioDownloadService extends Mock implements AudioDownloadService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockAudioBloc mockAudioBloc;
  late MockConnectivityBloc mockConnectivityBloc;
  late MockAudioDownloadService mockDownloadService;
  late MockConnectivityService mockConnectivityService;

  const alafasy = Reciter(
    identifier: 'ar.alafasy',
    name: 'مشاري العفاسي',
    englishName: 'Mishary Alafasy',
    language: 'ar',
  );

  const husary = Reciter(
    identifier: 'ar.husary',
    name: 'الحصري',
    englishName: 'Al-Husary',
    language: 'ar',
  );

  setUpAll(() {
    registerFallbackValue(const AudioState());
    registerFallbackValue(const Stop());
    registerFallbackValue(alafasy);
  });

  setUp(() {
    mockAudioBloc = MockAudioBloc();
    mockConnectivityBloc = MockConnectivityBloc();
    mockDownloadService = MockAudioDownloadService();
    mockConnectivityService = MockConnectivityService();

    getIt.allowReassignment = true;
    getIt.registerSingleton<AudioDownloadService>(mockDownloadService);
    getIt.registerSingleton<ConnectivityService>(mockConnectivityService);

    when(() => mockAudioBloc.state).thenReturn(const AudioState(currentReciter: alafasy));
    when(() => mockConnectivityBloc.state).thenReturn(const ConnectivityStatus(false));
    when(() => mockConnectivityService.hasInternet()).thenAnswer((_) async => false);
  });

  testWidgets('showAlternativeReciterDialog switches reciter and plays on "Play" click', (tester) async {
    // 1. Arrange: Alternative exists
    when(() => mockDownloadService.getRecitersWithDownloadedSurah(18))
        .thenAnswer((_) async => [husary]);
    
    when(() => mockDownloadService.getSurahStatus(
      reciterId: any(named: 'reciterId'),
      surahNumber: any(named: 'surahNumber'),
    )).thenAnswer((_) async => const SurahDownloadStatus(
      isDownloaded: false,
      isDownloading: false,
      sizeInBytes: 0,
      downloadedAyahs: 0,
      totalAyahs: 110,
    ));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AudioBloc>.value(value: mockAudioBloc),
          BlocProvider<ConnectivityBloc>.value(value: mockConnectivityBloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('ar')],
          locale: Locale('ar'),
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('Test'));

    // 2. Act: Trigger Dialog
    await OfflineAudioHelper.handlePlayRequest(
      context: context,
      surahNumber: 18,
      startAyah: 1,
      isDownloaded: false,
    );

    await tester.pumpAndSettle();

    // 3. Assert: Dialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('الحصري'), findsOneWidget);

    // 4. Act: Click "Play" (تشغيل السورة in Arabic locale)
    final playBtn = find.text('تشغيل السورة');
    expect(playBtn, findsOneWidget);
    await tester.tap(playBtn);
    await tester.pumpAndSettle();

    // 5. Assert: Dialog dismissed and events added
    expect(find.byType(AlertDialog), findsNothing);
    
    // Verify and check specific values directly using capture
    final selectReciterEvent = verify(() => mockAudioBloc.add(captureAny(that: isA<SelectReciter>())))
        .captured.last as SelectReciter;
    expect(selectReciterEvent.reciter.identifier, husary.identifier);

    final playSurahEvent = verify(() => mockAudioBloc.add(captureAny(that: isA<PlaySurah>())))
        .captured.last as PlaySurah;
    expect(playSurahEvent.surahNumber, 18);
    expect(playSurahEvent.startAyah, 1);

    verify(() => mockAudioBloc.add(any(that: isA<ShowBanner>()))).called(1);
  });
}
