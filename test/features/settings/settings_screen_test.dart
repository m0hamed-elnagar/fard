import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/theme/theme_presets.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_state.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/blocs/theme_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationPrayerCubit extends Mock implements LocationPrayerCubit {}
class MockThemeCubit extends Mock implements ThemeCubit {}
class MockAdhanCubit extends Mock implements AdhanCubit {}
class MockDailyRemindersCubit extends Mock implements DailyRemindersCubit {}
class MockNotificationService extends Mock implements NotificationService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}
class MockAzkarBloc extends Mock implements AzkarBloc {}
class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

void main() {
  late MockLocationPrayerCubit mockLocationPrayerCubit;
  late MockThemeCubit mockThemeCubit;
  late MockAdhanCubit mockAdhanCubit;
  late MockDailyRemindersCubit mockDailyRemindersCubit;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;
  late MockAzkarBloc mockAzkarBloc;
  late MockWidgetUpdateService mockWidgetUpdateService;

  setUp(() {
    mockLocationPrayerCubit = MockLocationPrayerCubit();
    mockThemeCubit = MockThemeCubit();
    mockAdhanCubit = MockAdhanCubit();
    mockDailyRemindersCubit = MockDailyRemindersCubit();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();
    mockAzkarBloc = MockAzkarBloc();
    mockWidgetUpdateService = MockWidgetUpdateService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<WidgetUpdateService>(mockWidgetUpdateService);
    getIt.registerSingleton<LocationPrayerCubit>(mockLocationPrayerCubit);
    getIt.registerSingleton<ThemeCubit>(mockThemeCubit);
    getIt.registerSingleton<AdhanCubit>(mockAdhanCubit);
    getIt.registerSingleton<DailyRemindersCubit>(mockDailyRemindersCubit);
    getIt.registerSingleton<AzkarBloc>(mockAzkarBloc);

    when(() => mockNotificationService.runDiagnostics()).thenAnswer((_) async => {
      'notifications_enabled': true,
      'exact_alarm_permission': true,
      'battery_optimization_ignored': true,
    });
    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockWidgetUpdateService.getWidgetTheme()).thenAnswer((_) async => null);

    when(() => mockLocationPrayerCubit.state).thenReturn(const LocationPrayerState(
      cityName: 'London',
      latitude: 51.5,
      longitude: -0.1,
      calculationMethod: 'muslim_league',
    ));
    when(() => mockLocationPrayerCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockThemeCubit.state).thenReturn(ThemeState(themePresetId: 'emerald', locale: const Locale('en')));
    when(() => mockThemeCubit.getAvailablePresets()).thenReturn(ThemePresets.all);
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockAdhanCubit.state).thenReturn(const AdhanState());
    when(() => mockAdhanCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockDailyRemindersCubit.state).thenReturn(const DailyRemindersState());
    when(() => mockDailyRemindersCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockAzkarBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationPrayerCubit>.value(value: mockLocationPrayerCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<AdhanCubit>.value(value: mockAdhanCubit),
        BlocProvider<DailyRemindersCubit>.value(value: mockDailyRemindersCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets('renders settings screen with all sections', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Reminders & Notifications'), findsOneWidget);
  });

  testWidgets('shows current location city', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    final dataLocationFinder = find.text('Data & Location');
    await tester.scrollUntilVisible(dataLocationFinder, 500, scrollable: find.byType(Scrollable).first);
    await tester.tap(dataLocationFinder);
    await tester.pumpAndSettle();
    expect(find.text('London'), findsOneWidget);
  });
}
