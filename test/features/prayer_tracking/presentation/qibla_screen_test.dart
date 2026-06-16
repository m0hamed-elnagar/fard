import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/qibla_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocationPrayerCubit extends Mock implements LocationPrayerCubit {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockLocationPrayerCubit mockLocationPrayerCubit;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockLocationPrayerCubit = MockLocationPrayerCubit();
    mockPrefs = MockSharedPreferences();

    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(mockPrefs);
    getIt.registerSingleton<LocationPrayerCubit>(mockLocationPrayerCubit);

    when(() => mockLocationPrayerCubit.state).thenReturn(
      const LocationPrayerState(
        cityName: 'London',
        latitude: 51.5,
        longitude: -0.1,
        calculationMethod: 'muslim_league',
      ),
    );
    when(() => mockLocationPrayerCubit.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockPrefs.getBool('has_seen_qibla_calibration_onboarding')).thenReturn(true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<LocationPrayerCubit>.value(
      value: mockLocationPrayerCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const QiblaScreen(),
      ),
    );
  }

  testWidgets('renders Qibla screen on Windows', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('Compass is not supported on this platform'), findsOneWidget);
    expect(find.text('Please use the mobile app for Qibla direction'), findsOneWidget);
  });
}
