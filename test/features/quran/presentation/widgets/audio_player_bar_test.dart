import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';

import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

void main() {
  late MockAudioPlayerBloc mockAudioPlayerBloc;

  setUp(() {
    mockAudioPlayerBloc = MockAudioPlayerBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: Scaffold(
        bottomNavigationBar: BlocProvider<AudioPlayerBloc>.value(
          value: mockAudioPlayerBloc,
          child: const AudioPlayerBar(),
        ),
      ),
    );
  }

  testWidgets('AudioPlayerBar displays Ayah info correctly', (tester) async {
    final state = const AudioPlayerState(
      status: AudioStatus.playing,
      isBannerVisible: true,
      currentSurah: 1,
      currentAyah: 1,
      duration: Duration(seconds: 10),
      position: Duration(seconds: 2),
      currentReciter: Reciter(
        identifier: 'id',
        name: 'Reciter Name',
        englishName: 'English Name',
        language: 'ar',
      ),
    );

    when(() => mockAudioPlayerBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Surah Al Fatiha, Ayah 1'), findsOneWidget);
  });

  testWidgets('AudioPlayerBar clamps slider value when position > duration', (
    tester,
  ) async {
    final state = const AudioPlayerState(
      status: AudioStatus.playing,
      isBannerVisible: true,
      currentSurah: 1,
      currentAyah: 1,
      duration: Duration(seconds: 10),
      position: Duration(seconds: 12), // Position > Duration
      currentReciter: Reciter(
        identifier: 'id',
        name: 'Reciter Name',
        englishName: 'English Name',
        language: 'ar',
      ),
    );

    when(() => mockAudioPlayerBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    final slider = tester.widget<Slider>(sliderFinder);
    expect(slider.value, equals(10000.0)); // Should be clamped to duration
    expect(slider.max, equals(10000.0));
  });

  testWidgets('AudioPlayerBar shows nothing when idle', (tester) async {
    when(
      () => mockAudioPlayerBloc.state,
    ).thenReturn(const AudioPlayerState(status: AudioStatus.idle));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(Container), findsNothing);
  });
}
