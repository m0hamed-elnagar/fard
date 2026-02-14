import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        locale: Locale('en'),
        cityName: 'London',
        calculationMethod: 'muslim_league',
        madhab: 'shafi',
      ),
    );
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<SettingsCubit>.value(
        value: mockSettingsCubit,
        child: const SettingsScreen(),
      ),
    );
  }

  testWidgets('renders settings screen with all sections', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Location Settings'), findsOneWidget);
    expect(find.text('Prayer Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    
    // Check for descriptions
    expect(find.textContaining('coordinates'), findsOneWidget);
    expect(find.textContaining('authority'), findsOneWidget);
  });

  testWidgets('shows current location city', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('London'), findsOneWidget);
  });
}
