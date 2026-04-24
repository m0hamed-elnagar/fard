import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

class MockReciterManagerBloc extends MockBloc<ReciterManagerEvent, ReciterManagerState>
    implements ReciterManagerBloc {}

void main() {
  late MockAudioPlayerBloc mockAudioPlayerBloc;
  late MockReciterManagerBloc mockReciterManagerBloc;

  setUp(() {
    mockAudioPlayerBloc = MockAudioPlayerBloc();
    mockReciterManagerBloc = MockReciterManagerBloc();

    when(() => mockAudioPlayerBloc.state).thenReturn(
      const AudioPlayerState(quality: AudioQuality.medium128),
    );
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AudioPlayerBloc>.value(value: mockAudioPlayerBloc),
          BlocProvider<ReciterManagerBloc>.value(value: mockReciterManagerBloc),
        ],
        child: const Scaffold(body: ReciterSelector()),
      ),
    );
  }

  // Create a long list of reciters, with 'ar.alafasy' at index 20
  final tReciters = List.generate(50, (i) {
    if (i == 20) {
      return const Reciter(
        identifier: 'ar.alafasy',
        name: 'Mishary Alafasy',
        englishName: 'Mishary Alafasy',
        language: 'ar',
      );
    }
    return Reciter(
      identifier: 'reciter_$i',
      name: 'Reciter $i',
      englishName: 'Reciter $i',
      language: 'ar',
    );
  });

  testWidgets('Selecting popular reciter should scroll the full list', (
    tester,
  ) async {
    // Set initial state
    when(() => mockReciterManagerBloc.state).thenReturn(
      ReciterManagerState(
        availableReciters: tReciters,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify 'ar.alafasy' is in the popular list (top horizontal list)
    // Find Alafasy in the popular list (first ListView)
    final popularAlafasyFinder = find.descendant(
      of: find.byType(ListView).first,
      matching: find.text('Alafasy'),
    );
    expect(popularAlafasyFinder, findsOneWidget);

    // Get the main list (second ListView)
    final mainListFinder = find.byType(ListView).last;
    final ScrollController scrollController = tester
        .widget<ListView>(mainListFinder)
        .controller!;

    expect(scrollController.offset, 0.0);

    // Tap Alafasy in popular list
    await tester.tap(popularAlafasyFinder);

    // Pump for animation (500ms in code)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify offset changed (index 20 * 72.0 = 1440.0)
    expect(scrollController.offset, greaterThan(0.0));
    expect(scrollController.offset, closeTo(1440.0, 1.0));
  });
}
