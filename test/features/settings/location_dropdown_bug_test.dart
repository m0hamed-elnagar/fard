import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/widgets/location_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationPrayerCubit extends Mock implements LocationPrayerCubit {}

void main() {
  late MockLocationPrayerCubit mockCubit;

  setUp(() {
    mockCubit = MockLocationPrayerCubit();
  });

  testWidgets('Madhab dropdown should update when changed', (tester) async {
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
    when(() => mockCubit.updateMadhab(any())).thenAnswer((_) async {});

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

    // Expand the section and find the dropdown
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Shafi, Maliki, Hanbali'), findsOneWidget);

    // Tap the dropdown
    await tester.tap(find.text('Shafi, Maliki, Hanbali'));
    await tester.pumpAndSettle();

    // Tap 'Hanafi'
    final hanafiOption = find.text('Hanafi');
    expect(hanafiOption, findsOneWidget);
    await tester.tap(hanafiOption);
    await tester.pumpAndSettle();

    verify(() => mockCubit.updateMadhab('hanafi')).called(1);
  });
}
