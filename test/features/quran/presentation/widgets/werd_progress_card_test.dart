import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/werd_progress_card.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockWerdBloc mockWerdBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  });

  setUp(() {
    mockWerdBloc = MockWerdBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createWidgetUnderTest({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [mockNavigatorObserver],
      home: Scaffold(
        body: BlocProvider<WerdBloc>.value(
          value: mockWerdBloc,
          child: WerdProgressCard(onSetGoalPressed: () {}),
        ),
      ),
    );
  }

  testWidgets('should show Surah 1, Ayah 1 when no progress yet (English)', (tester) async {
    when(() => mockWerdBloc.state).thenReturn(
      WerdState(
        goal: WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount, 
          value: 10, 
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
        ),
        progress: WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 0,
          lastUpdated: DateTime.now(),
          streak: 0,
        ),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('en')));
    
    // In new implementation, if lastReadAbsolute is null, it might show "Al Fatiha, 1"
    expect(find.text('Al Fatiha, 1'), findsOneWidget);
  });

  testWidgets('should show Surah 1, Ayah 1 when no progress yet (Arabic)', (tester) async {
    when(() => mockWerdBloc.state).thenReturn(
      WerdState(
        goal: WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount, 
          value: 10, 
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
        ),
        progress: WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 0,
          lastUpdated: DateTime.now(),
          streak: 0,
        ),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('ar')));
    
    expect(find.text('الفاتحة، ١'), findsOneWidget);
  });

  testWidgets('Go button should be present and enabled even with no progress', (tester) async {
    when(() => mockWerdBloc.state).thenReturn(
      WerdState(
        goal: WerdGoal(
          id: 'default',
          type: WerdGoalType.fixedAmount, 
          value: 10, 
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
        ),
        progress: WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 0,
          lastUpdated: DateTime.now(),
          streak: 0,
        ),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    final goButton = find.byType(ElevatedButton);
    expect(goButton, findsOneWidget);
    
    final button = tester.widget<ElevatedButton>(goButton);
    expect(button.enabled, isTrue);
  });
}
