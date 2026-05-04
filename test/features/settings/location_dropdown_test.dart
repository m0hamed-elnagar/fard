import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/settings/presentation/widgets/location_section.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockLocationPrayerCubit extends Mock implements LocationPrayerCubit {}

void main() {
  testWidgets('Location dropdown interaction test', (tester) async {
    final mockCubit = MockLocationPrayerCubit();
    when(() => mockCubit.state).thenReturn(const LocationPrayerState(
      madhab: 'shafi',
      calculationMethod: 'muslim_league',
      hijriAdjustment: 0,
    ));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const LocationPrayerState(
      madhab: 'shafi',
      calculationMethod: 'muslim_league',
      hijriAdjustment: 0,
    )));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<LocationPrayerCubit>.value(
            value: mockCubit,
            child: const DataAndLocationSection(initiallyExpanded: true),
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Shafi, Maliki, Hanbali'), findsOneWidget);

    // Tap the madhab dropdown
    await tester.tap(find.text('Shafi, Maliki, Hanbali'));
    await tester.pumpAndSettle();

    // Tap the hanafi option
    await tester.tap(find.text('Hanafi'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.updateMadhab('hanafi')).called(1);
  });

  testWidgets('Calculation method dropdown interaction test', (tester) async {
    final mockCubit = MockLocationPrayerCubit();
    when(() => mockCubit.state).thenReturn(const LocationPrayerState(
      madhab: 'shafi',
      calculationMethod: 'muslim_league',
      hijriAdjustment: 0,
    ));
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const LocationPrayerState(
      madhab: 'shafi',
      calculationMethod: 'muslim_league',
      hijriAdjustment: 0,
    )));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BlocProvider<LocationPrayerCubit>.value(
            value: mockCubit,
            child: const DataAndLocationSection(initiallyExpanded: true),
          ),
        ),
      ),
    );

    // Find and tap the calculation method dropdown
    // Note: The text displayed depends on localization. 'Muslim World League' is the text for 'muslim_league'
    await tester.tap(find.text('Muslim World League'));
    await tester.pumpAndSettle();

    // Tap another option, e.g., 'Umm al-Qura University, Makkah' for 'umm_al_qura'
    await tester.tap(find.text('Umm al-Qura University, Makkah'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.updateCalculationMethod('umm_al_qura')).called(1);
  });
}
