import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/blocs/theme_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MockLocationPrayerCubit extends MockCubit<LocationPrayerState>
    implements LocationPrayerCubit {}

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

class MockDailyRemindersCubit extends MockCubit<DailyRemindersState>
    implements DailyRemindersCubit {}

class MockAdhanCubit extends MockCubit<AdhanState> implements AdhanCubit {}

class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState>
    implements AzkarBloc {}

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<Map<String, dynamic>> runDiagnostics() async => {
    'notifications_enabled': true,
    'exact_alarm_permission': true,
    'battery_optimization_ignored': true,
  };
}

class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {
  @override
  Future<Map<String, String>?> getWidgetTheme() async => {};
  @override
  Future<void> updateWidget() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
  });

  late MockLocationPrayerCubit mockLocationPrayerCubit;
  late MockThemeCubit mockThemeCubit;
  late MockDailyRemindersCubit mockDailyRemindersCubit;
  late MockAdhanCubit mockAdhanCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;

  setUp(() {
    mockLocationPrayerCubit = MockLocationPrayerCubit();
    mockThemeCubit = MockThemeCubit();
    mockDailyRemindersCubit = MockDailyRemindersCubit();
    mockAdhanCubit = MockAdhanCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<WidgetUpdateService>(MockWidgetUpdateService());

    when(() => mockNotificationService.canScheduleExactNotifications())
        .thenAnswer((_) async => true);

    when(() => mockLocationPrayerCubit.state)
        .thenReturn(const LocationPrayerState());

    when(() => mockThemeCubit.state)
        .thenReturn(const ThemeState(locale: Locale('en')));
    when(() => mockThemeCubit.getAvailablePresets()).thenReturn([]);

    when(() => mockAdhanCubit.state).thenReturn(const AdhanState());

    when(() => mockAzkarBloc.state).thenReturn(
      const AzkarState(
        categories: [
          'Morning Azkar',
          'Evening Azkar',
        ],
        azkar: [],
        isLoading: false,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        BlocProvider<LocationPrayerCubit>.value(value: mockLocationPrayerCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<DailyRemindersCubit>.value(value: mockDailyRemindersCubit),
        BlocProvider<AdhanCubit>.value(value: mockAdhanCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: AzkarCategoriesScreen(),
      ),
    );
  }

  testWidgets('renders bell icon with badge and tapping it opens unified bottom sheet with reminders',
      (tester) async {
    when(() => mockDailyRemindersCubit.state).thenReturn(
      const DailyRemindersState(
        reminders: [
          AzkarReminder(
            category: 'Morning Azkar',
            time: '06:30',
            title: 'Morning Alarm',
            isEnabled: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify active bell icon is shown in AppBar and card
    expect(find.byIcon(Icons.notifications_active_rounded), findsNWidgets(2));
    
    // Verify category card displays the reminder time
    expect(find.text('6:30 AM'), findsOneWidget);

    // Tap the AppBar bell icon to open the bottom sheet
    await tester.tap(find.byKey(const Key('azkar_reminders_badge_button')));
    await tester.pumpAndSettle();

    // Verify bottom sheet content
    expect(find.text('Active Reminders'), findsOneWidget);
    expect(find.text('Morning Alarm'), findsOneWidget);
    expect(find.text('6:30 AM'), findsNWidgets(2)); // One on card, one in bottom sheet

    // Tap edit icon inside the bottom sheet
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    // Verify Edit Reminder dialog is shown
    expect(find.text('Edit Reminder'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('reminders empty shows outline bell icon and card notification buttons',
      (tester) async {
    when(() => mockDailyRemindersCubit.state).thenReturn(
      const DailyRemindersState(reminders: []),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify outline bell in AppBar (findsAtLeast(2) because one is in AppBar, others are on cards)
    expect(find.byIcon(Icons.notifications_none_rounded), findsAtLeast(2));
  });
}
