import 'package:adhan/adhan.dart';
import 'package:fard/core/constants/calculation_contract.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLocationService extends Mock implements LocationService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAzkarRepository extends Mock implements AzkarRepository {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsCubit cubit;
  late MockSharedPreferences mockPrefs;
  late MockLocationService mockLocationService;
  late MockNotificationService mockNotificationService;
  late MockAzkarRepository mockAzkarRepository;
  late MockPrayerTimeService mockPrayerTimeService;
  late WidgetUpdateService widgetUpdateService;

  final List<MethodCall> methodCalls = <MethodCall>[];

  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
    registerFallbackValue(
      const SettingsState(locale: Locale('ar'), isAzanVoiceDownloading: false),
    );
    registerFallbackValue(const Locale('en'));
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockLocationService = MockLocationService();
    mockNotificationService = MockNotificationService();
    mockAzkarRepository = MockAzkarRepository();
    mockPrayerTimeService = MockPrayerTimeService();

    // Reset method calls
    methodCalls.clear();

    // Setup Calculation MethodChannel mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(CalculationContract.channelName),
          (MethodCall methodCall) async {
            methodCalls.add(methodCall);
            return true;
          },
        );

    // Setup home_widget MethodChannel mock to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), (
          MethodCall methodCall,
        ) async {
          return true;
        });

    // Mock basic SharedPreferences behavior
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getDouble(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setDouble(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);

    // Mock Prayer Times
    final mockTimes = PrayerTimes(
      Coordinates(30.0, 31.0),
      DateComponents.from(DateTime.now()),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(
      () => mockPrayerTimeService.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      ),
    ).thenReturn(mockTimes);

    // Mock notification service
    when(
      () => mockNotificationService.scheduleAzkarReminders(
        settings: any(named: 'settings'),
        allAzkar: any(named: 'allAzkar'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.schedulePrayerNotifications(
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async {});

    // Mock Azkar Repository
    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => []);

    widgetUpdateService = WidgetUpdateService(mockPrayerTimeService, mockPrefs);

    cubit = SettingsCubit(
      mockPrefs,
      mockLocationService,
      mockNotificationService,
      mockAzkarRepository,
      widgetUpdateService,
    );

    // Give it a location so WidgetUpdateService doesn't exit early
    // ignore: invalid_use_of_protected_member
    cubit.emit(cubit.state.copyWith(latitude: 30.0, longitude: 31.0));
    methodCalls.clear(); // Clear initial sync if any
  });

  group('Widget Sync Integration', () {
    test(
      'Changing Madhab triggers settingsChanged MethodChannel call with prayer_data',
      () async {
        // 1. Act: Update Madhab
        cubit.updateMadhab('hanafi');

        // Allow time for async calls
        await Future.delayed(Duration.zero);

        // 2. Assert: Verify MethodChannel was called with correct data
        expect(
          methodCalls.any((call) => call.method == 'settingsChanged'),
          isTrue,
        );
        final call = methodCalls.firstWhere(
          (call) => call.method == 'settingsChanged',
        );
        expect(call.arguments['madhab'], CalculationContract.madhabHanafi);
        expect(call.arguments['prayer_data'], isA<String>());
        expect(call.arguments['prayer_data'], contains('name'));
        expect(call.arguments['prayer_data'], contains('minutesFromMidnight'));
      },
    );

    test(
      'Changing Calculation Method triggers settingsChanged MethodChannel call',
      () async {
        // 1. Act: Update Calculation Method
        cubit.updateCalculationMethod('egyptian');

        // Allow time for async calls
        await Future.delayed(Duration.zero);

        // 2. Assert: Verify MethodChannel was called
        expect(
          methodCalls.any(
            (call) =>
                call.method == 'settingsChanged' &&
                call.arguments['calculation_method'] ==
                    CalculationContract.methodEgyptian &&
                call.arguments['prayer_data'] != null,
          ),
          isTrue,
        );
      },
    );

    test(
      'Changing Hijri Adjustment triggers settingsChanged MethodChannel call',
      () async {
        // 1. Act: Update Hijri Adjustment
        cubit.updateHijriAdjustment(2);

        // Allow time for async calls
        await Future.delayed(Duration.zero);

        // 2. Assert: Verify MethodChannel was called
        expect(
          methodCalls.any(
            (call) =>
                call.method == 'settingsChanged' &&
                call.arguments['prayer_data'] != null,
          ),
          isTrue,
        );
      },
    );

    test('Manual refresh button triggers sync with prayer_data', () async {
      // 1. Act: Trigger manual refresh
      await widgetUpdateService.updateWidget(cubit.state);

      // 2. Assert: Verify sync
      expect(
        methodCalls.any(
          (call) =>
              call.method == 'settingsChanged' &&
              call.arguments['prayer_data'] != null,
        ),
        isTrue,
      );
    });
  });
}
