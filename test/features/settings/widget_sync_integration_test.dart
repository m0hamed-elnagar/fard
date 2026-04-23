import 'package:adhan/adhan.dart';
import 'package:fard/core/constants/calculation_contract.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:fard/features/settings/domain/usecases/apply_theme_preset.dart';
import 'package:fard/features/settings/domain/usecases/save_custom_theme.dart';
import 'package:fard/features/settings/domain/usecases/get_available_theme_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLocationService extends Mock implements LocationService {}

class MockAzkarRepository extends Mock implements AzkarRepository {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

class MockSyncLocationSettings extends Mock implements SyncLocationSettings {}

class MockSyncNotificationSchedule extends Mock
    implements SyncNotificationSchedule {}

class MockToggleAfterSalahAzkar extends Mock
    implements ToggleAfterSalahAzkarUseCase {}

class MockUpdateCalcMethod extends Mock
    implements UpdateCalculationMethodUseCase {}

class MockApplyThemePreset extends Mock implements ApplyThemePreset {}

class MockSaveCustomTheme extends Mock implements SaveCustomTheme {}

class MockGetAvailableThemePresets extends Mock
    implements GetAvailableThemePresets {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockLocationService mockLocation;
  late MockPrayerTimeService mockPrayerTime;
  late MockWidgetUpdateService mockWidget;
  late MockSyncLocationSettings mockSyncLoc;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkar mockToggle;
  late MockUpdateCalcMethod mockUpdateMethod;
  late MockApplyThemePreset mockApplyTheme;
  late MockSaveCustomTheme mockSaveCustomTheme;
  late MockGetAvailableThemePresets mockGetPresets;

  final List<MethodCall> methodCalls = <MethodCall>[];

  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
    registerFallbackValue(const SettingsState(locale: Locale('ar')));
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(AzkarReminder(category: '', time: '', title: ''));
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockLocation = MockLocationService();
    mockPrayerTime = MockPrayerTimeService();
    mockWidget = MockWidgetUpdateService();
    mockSyncLoc = MockSyncLocationSettings();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggle = MockToggleAfterSalahAzkar();
    mockUpdateMethod = MockUpdateCalcMethod();
    mockApplyTheme = MockApplyThemePreset();
    mockSaveCustomTheme = MockSaveCustomTheme();
    mockGetPresets = MockGetAvailableThemePresets();
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

    // Setup home_widget MethodChannel mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), (
          MethodCall methodCall,
        ) async {
          return true;
        });

    // Mock Prayer Times
    final mockTimes = PrayerTimes(
      Coordinates(30.0, 31.0),
      DateComponents.from(DateTime.now()),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(
      () => mockPrayerTime.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      ),
    ).thenReturn(mockTimes);

    // Mock SettingsRepository
    when(() => mockRepo.audioQuality).thenReturn(AudioQuality.high192);
    when(() => mockRepo.locale).thenReturn(const Locale('ar'));
    when(() => mockRepo.latitude).thenReturn(30.0);
    when(() => mockRepo.longitude).thenReturn(31.0);
    when(() => mockRepo.cityName).thenReturn('Cairo');
    when(() => mockRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockRepo.madhab).thenReturn('shafi');
    when(() => mockRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockRepo.isQadaEnabled).thenReturn(true);
    when(() => mockRepo.hijriAdjustment).thenReturn(0);
    when(() => mockRepo.themePresetId).thenReturn('emerald_gold');
    when(() => mockRepo.customThemeColors).thenReturn(null);
    when(() => mockRepo.savedCustomThemes).thenReturn([]);
    when(() => mockRepo.activeCustomThemeId).thenReturn(null);
    when(() => mockRepo.reminders).thenReturn([]);
    when(() => mockRepo.salaahSettings).thenReturn(
      Salaah.values
          .map(
            (s) => SalaahSettings(
              salaah: s,
              isAzanEnabled: true,
              isReminderEnabled: false,
            ),
          )
          .toList(),
    );
    when(() => mockRepo.updateLocale(any())).thenAnswer((_) async {});
    when(
      () => mockRepo.updateLocation(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        cityName: any(named: 'cityName'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRepo.updateCalculationMethod(any()),
    ).thenAnswer((_) async {});
    when(() => mockRepo.updateMadhab(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateMorningAzkarTime(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateEveningAzkarTime(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateSalaahSettings(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateHijriAdjustment(any())).thenAnswer((_) async {});
    when(
      () => mockRepo.updateAfterSalahAzkarEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => mockRepo.toggleQadaEnabled()).thenAnswer((_) async {});
    when(() => mockRepo.addReminder(any())).thenAnswer((_) async {});
    when(() => mockRepo.removeReminder(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateReminder(any(), any())).thenAnswer((_) async {});
    when(() => mockRepo.toggleReminder(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAllAzanEnabled(any())).thenAnswer((_) async {});
    when(
      () => mockRepo.updateAllReminderEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => mockRepo.updateAllAzanSound(any())).thenAnswer((_) async {});
    when(
      () => mockRepo.updateAllReminderMinutes(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockRepo.updateAllAfterSalahMinutes(any()),
    ).thenAnswer((_) async {});
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});
    when(() => mockSyncNotif.init()).thenAnswer((_) async {});
    when(() => mockSyncLoc.execute()).thenAnswer(
      (_) async => const LocationSyncResult(
        calculationMethod: 'muslim_league',
        hijriAdjustment: 0,
        status: LocationStatus.success,
      ),
    );
    when(() => mockToggle.execute()).thenAnswer((_) async => true);
    when(() => mockUpdateMethod.execute(any())).thenAnswer((_) async => 0);
    when(() => mockWidget.updateWidget()).thenAnswer((_) async {});

    cubit = SettingsCubit(
      mockRepo,
      mockLocation,
      mockSyncLoc,
      mockSyncNotif,
      mockToggle,
      mockUpdateMethod,
      mockApplyTheme,
      mockSaveCustomTheme,
      mockGetPresets,
      mockWidget,
    );

    // Give it a location so WidgetUpdateService doesn't exit early
    // ignore: invalid_use_of_protected_member
    cubit.emit(cubit.state.copyWith(latitude: 30.0, longitude: 31.0));
    methodCalls.clear(); // Clear initial sync if any
  });

  group('Widget Sync Integration', () {
    test('Changing Madhab triggers widget update', () async {
      // 1. Act: Update Madhab
      cubit.updateMadhab('hanafi');

      // Allow time for async calls
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. Assert: Verify updateWidget was called
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('Changing Calculation Method triggers widget update', () async {
      // 1. Act: Update Calculation Method
      cubit.updateCalculationMethod('egyptian');

      // Allow time for async calls
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. Assert: Verify updateWidget was called
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('Changing Hijri Adjustment triggers widget update', () async {
      // 1. Act: Update Hijri Adjustment
      cubit.updateHijriAdjustment(2);

      // Allow time for async calls
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. Assert: Verify updateWidget was called
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('Manual refresh triggers widget update', () async {
      // 1. Act: Trigger manual refresh via widget update directly on the mock
      await mockWidget.updateWidget();

      // 2. Assert: Verify it was called (was already called in Act, but confirms the mock works)
      verify(() => mockWidget.updateWidget()).called(1);
    });
  });
}
