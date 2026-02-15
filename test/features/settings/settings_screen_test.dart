import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAzkarBloc extends Mock implements AzkarBloc {}

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockNotificationService mockNotificationService;
  late MockAzkarBloc mockAzkarBloc;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockNotificationService = MockNotificationService();
    mockAzkarBloc = MockAzkarBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        locale: Locale('en'),
        cityName: 'London',
        calculationMethod: 'muslim_league',
        madhab: 'shafi',
        isAzanVoiceDownloading: false,
        salaahSettings: [
          SalaahSettings(salaah: Salaah.fajr),
          SalaahSettings(salaah: Salaah.dhuhr),
          SalaahSettings(salaah: Salaah.asr),
          SalaahSettings(salaah: Salaah.maghrib),
          SalaahSettings(salaah: Salaah.isha),
        ],
      ),
    );
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockAzkarBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        ],
        child: const SettingsScreen(),
      ),
    );
  }

  testWidgets('renders settings screen with all sections', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Location Settings'), findsOneWidget);
    
    await tester.scrollUntilVisible(find.text('Azan & Reminder Settings'), 500);
    expect(find.text('Azan & Reminder Settings'), findsOneWidget);
    
    await tester.scrollUntilVisible(find.text('Language'), 500);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('shows current location city', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('London'), findsOneWidget);
  });

  testWidgets('tapping a prayer opens azan settings dialog', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll to Fajr
    final fajrFinder = find.text('Fajr');
    await tester.ensureVisible(fajrFinder);
    await tester.pumpAndSettle();
    
    await tester.tap(fajrFinder);
    await tester.pumpAndSettle();

    expect(find.text('Enable Azan'), findsOneWidget);
    expect(find.text('Enable Reminder'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });
}
