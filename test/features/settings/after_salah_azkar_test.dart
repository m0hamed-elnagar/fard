import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockLocationService extends Mock implements LocationService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAzkarRepository extends Mock implements AzkarRepository {}
class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

void main() {
  late SettingsCubit cubit;
  late MockSharedPreferences mockPrefs;
  late MockLocationService mockLocationService;
  late MockNotificationService mockNotificationService;
  late MockAzkarRepository mockAzkarRepository;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockVoiceDownloadService mockVoiceDownloadService;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(const Locale('ar'));
    registerFallbackValue(SettingsState(locale: const Locale('ar')));
  });

  setUp(() async {
    mockPrefs = MockSharedPreferences();
    mockLocationService = MockLocationService();
    mockNotificationService = MockNotificationService();
    mockAzkarRepository = MockAzkarRepository();
    mockPrayerTimeService = MockPrayerTimeService();
    mockVoiceDownloadService = MockVoiceDownloadService();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<AzkarRepository>(mockAzkarRepository);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());

    when(() => mockPrefs.getString(any())).thenAnswer((_) => null);
    when(() => mockPrefs.getBool(any())).thenAnswer((_) => null);
    when(() => mockPrefs.getDouble(any())).thenAnswer((_) => null);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    
    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => [
      const AzkarItem(
        category: 'الأذكار بعد السلام من الصلاة', 
        zekr: 'SubhanAllah', 
        count: 33,
        description: '',
        reference: '',
      ),
    ]);
    
    when(() => mockNotificationService.scheduleAzkarReminders(
      settings: any(named: 'settings'),
      allAzkar: any(named: 'allAzkar'),
    )).thenAnswer((_) async {});
    
    when(() => mockNotificationService.schedulePrayerNotifications(
      settings: any(named: 'settings'),
    )).thenAnswer((_) async {});

    cubit = SettingsCubit(
      mockPrefs,
      mockLocationService,
      mockNotificationService,
      mockAzkarRepository,
    );
  });

  group('After Salah Azkar Feature', () {
    test('toggleAfterSalahAzkar updates global and individual settings', () async {
      // Initial state should be false
      expect(cubit.state.isAfterSalahAzkarEnabled, false);
      for (var s in cubit.state.salaahSettings) {
        expect(s.isAfterSalahAzkarEnabled, false);
      }

      // Toggle ON
      cubit.toggleAfterSalahAzkar();
      
      expect(cubit.state.isAfterSalahAzkarEnabled, true);
      for (var s in cubit.state.salaahSettings) {
        expect(s.isAfterSalahAzkarEnabled, true);
      }

      // Toggle OFF
      cubit.toggleAfterSalahAzkar();
      
      expect(cubit.state.isAfterSalahAzkarEnabled, false);
      for (var s in cubit.state.salaahSettings) {
        expect(s.isAfterSalahAzkarEnabled, false);
      }
    });

    test('updateSalaahSettings can override individual after salah azkar setting', () {
      cubit.toggleAfterSalahAzkar(); // Set all to true
      expect(cubit.state.salaahSettings.first.isAfterSalahAzkarEnabled, true);

      final updatedFajr = cubit.state.salaahSettings.first.copyWith(
        isAfterSalahAzkarEnabled: false,
      );
      
      cubit.updateSalaahSettings(updatedFajr);
      
      expect(cubit.state.salaahSettings.first.salaah, Salaah.fajr);
      expect(cubit.state.salaahSettings.first.isAfterSalahAzkarEnabled, false);
      // Other settings should still be true
      expect(cubit.state.salaahSettings[1].isAfterSalahAzkarEnabled, true);
    });
  });
}
