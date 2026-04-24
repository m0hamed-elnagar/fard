import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
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

    when(() => mockAudioPlayerBloc.state).thenReturn(const AudioPlayerState());
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

  const tReciters = [
    Reciter(
      identifier: 'ar.alafasy',
      name: 'مشاري العفاسي',
      englishName: 'Alafasy',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.husary',
      name: 'محمود خليل الحصري',
      englishName: 'Husary',
      language: 'ar',
    ),
    Reciter(
      identifier: 'ar.minshawi',
      name: 'محمد صديق المنشاوي',
      englishName: 'Minshawi',
      language: 'ar',
    ),
  ];

  testWidgets('ReciterSelector should display Alafasy and Husary', (
    tester,
  ) async {
    when(() => mockReciterManagerBloc.state).thenReturn(
      const ReciterManagerState(availableReciters: tReciters),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    // Check popular horizontal list and full list
    expect(find.text('Alafasy'), findsAtLeastNWidgets(1));
    expect(find.text('Husary'), findsAtLeastNWidgets(1));

    // Check full list (shows full name)
    expect(find.text('مشاري العفاسي'), findsAtLeastNWidgets(1));
    expect(find.text('محمود خليل الحصري'), findsAtLeastNWidgets(1));
  });
}
