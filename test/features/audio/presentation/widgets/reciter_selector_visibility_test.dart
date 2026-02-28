import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioBloc extends MockBloc<AudioEvent, AudioState> implements AudioBloc {}

void main() {
  late MockAudioBloc mockAudioBloc;

  setUp(() {
    mockAudioBloc = MockAudioBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AudioBloc>.value(
        value: mockAudioBloc,
        child: const Scaffold(
          body: ReciterSelector(),
        ),
      ),
    );
  }

  const tReciters = [
    Reciter(
      identifier: 'ar.alijaber',
      name: 'علي جابر',
      englishName: 'Ali Jaber',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.yasseraldossari',
      name: 'ياسر الدوسري',
      englishName: 'Yasser Al-Dosari',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.alafasy',
      name: 'مشاري العفاسي',
      englishName: 'Alafasy',
      language: 'ar',
    ),
  ];

  testWidgets('ReciterSelector should display Ali Jaber and Yasser Al-Dosari', (tester) async {
    when(() => mockAudioBloc.state).thenReturn(
      const AudioState(
        availableReciters: tReciters,
        status: AudioStatus.idle,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    // Check popular horizontal list (using englishName or parts of it as split in widget)
    // The widget shows englishName.split(' ').last
    expect(find.text('Jaber'), findsOneWidget);
    expect(find.text('Al-Dosari'), findsOneWidget);

    // Check full list (shows full name)
    expect(find.text('علي جابر'), findsOneWidget);
    expect(find.text('ياسر الدوسري'), findsOneWidget);
  });
}
