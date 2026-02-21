import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';

class MockAudioBloc extends MockBloc<AudioEvent, AudioState> implements AudioBloc {}

void main() {
  late MockAudioBloc mockAudioBloc;

  setUp(() {
    mockAudioBloc = MockAudioBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BlocProvider<AudioBloc>.value(
          value: mockAudioBloc,
          child: const AudioPlayerBar(),
        ),
      ),
    );
  }

  testWidgets('AudioPlayerBar displays Ayah info correctly', (tester) async {
    final state = const AudioState(
      status: AudioStatus.playing,
      isBannerVisible: true,
      currentSurah: 1,
      currentAyah: 1,
      duration: Duration(seconds: 10),
      position: Duration(seconds: 2),
      currentReciter: Reciter(identifier: 'id', name: 'Reciter Name', englishName: 'English Name', language: 'ar'),
    );
    
    when(() => mockAudioBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Surah 1, Ayah 1'), findsOneWidget);
  });

  testWidgets('AudioPlayerBar clamps slider value when position > duration', (tester) async {
    final state = const AudioState(
      status: AudioStatus.playing,
      isBannerVisible: true,
      currentSurah: 1,
      currentAyah: 1,
      duration: Duration(seconds: 10),
      position: Duration(seconds: 12), // Position > Duration
      currentReciter: Reciter(identifier: 'id', name: 'Reciter Name', englishName: 'English Name', language: 'ar'),
    );
    
    when(() => mockAudioBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    
    final slider = tester.widget<Slider>(sliderFinder);
    expect(slider.value, equals(10000.0)); // Should be clamped to duration
    expect(slider.max, equals(10000.0));
  });

  testWidgets('AudioPlayerBar shows nothing when idle', (tester) async {
     when(() => mockAudioBloc.state).thenReturn(const AudioState(status: AudioStatus.idle));
     await tester.pumpWidget(createWidgetUnderTest());
     expect(find.byType(Container), findsNothing);
  });
}
