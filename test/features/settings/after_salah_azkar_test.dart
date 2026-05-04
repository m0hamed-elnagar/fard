import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/usecases/apply_theme_preset.dart';
import 'package:fard/features/settings/domain/usecases/get_available_theme_presets.dart';
import 'package:fard/features/settings/domain/usecases/save_custom_theme.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockAzkarRepository extends Mock implements AzkarRepository {}
class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}
class MockSyncLocationSettings extends Mock implements SyncLocationSettings {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}
class MockToggleAfterSalahAzkarUseCase extends Mock implements ToggleAfterSalahAzkarUseCase {}
class MockUpdateCalculationMethodUseCase extends Mock implements UpdateCalculationMethodUseCase {}
class MockApplyThemePreset extends Mock implements ApplyThemePreset {}
class MockSaveCustomTheme extends Mock implements SaveCustomTheme {}
class MockGetAvailableThemePresets extends Mock implements GetAvailableThemePresets {}

void main() {
  late SettingsCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockSyncLocationSettings mockSyncLoc;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkarUseCase mockToggle;
  late MockUpdateCalculationMethodUseCase mockUpdateMethod;
  late MockApplyThemePreset mockApplyTheme;
  late MockSaveCustomTheme mockSaveCustomTheme;
  late MockGetAvailableThemePresets mockGetPresets;
  late MockWidgetUpdateService mockWidget;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(const Locale('ar'));
    registerFallbackValue(const SettingsState(locale: Locale('ar')));
    registerFallbackValue(AzkarReminder(category: '', time: '', title: ''));
  });

  void mockDefaults() {
    when(() => mockRepo.audioQuality).thenReturn(AudioQuality.high192);
    when(() => mockRepo.locale).thenReturn(const Locale('ar'));
    when(() => mockRepo.latitude).thenReturn(null);
    when(() => mockRepo.longitude).thenReturn(null);
    when(() => mockRepo.cityName).thenReturn(null);
    when(() => mockRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockRepo.madhab).thenReturn('shafi');
    when(() => mockRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockRepo.isSalahReminderEnabled).thenReturn(false);
    when(() => mockRepo.salahReminderOffsetMinutes).thenReturn(15);
    when(() => mockRepo.prayerReminderType).thenReturn(PrayerReminderType.after);
    when(() => mockRepo.enabledSalahReminders).thenReturn({});
    when(() => mockRepo.isWerdReminderEnabled).thenReturn(false);
    when(() => mockRepo.werdReminderTime).thenReturn('20:00');
    when(() => mockRepo.isSalawatReminderEnabled).thenReturn(false);
    when(() => mockRepo.salawatFrequencyHours).thenReturn(3);
    when(() => mockRepo.salawatStartTime).thenReturn('10:00');
    when(() => mockRepo.salawatEndTime).thenReturn('20:00');
    when(() => mockRepo.isAudioPlayerExpanded).thenReturn(false);
    when(() => mockRepo.isQadaEnabled).thenReturn(true);
    when(() => mockRepo.hijriAdjustment).thenReturn(0);
    when(() => mockRepo.themePresetId).thenReturn('emerald');
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
              isAfterSalahAzkarEnabled: false,
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
  }

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockSyncLoc = MockSyncLocationSettings();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggle = MockToggleAfterSalahAzkarUseCase();
    mockUpdateMethod = MockUpdateCalculationMethodUseCase();
    mockApplyTheme = MockApplyThemePreset();
    mockSaveCustomTheme = MockSaveCustomTheme();
    mockGetPresets = MockGetAvailableThemePresets();
    mockWidget = MockWidgetUpdateService();
    mockDefaults();

    cubit = SettingsCubit(
      mockRepo,
      MockLocationService(),
      mockSyncLoc,
      mockSyncNotif,
      mockToggle,
      mockUpdateMethod,
      mockApplyTheme,
      mockSaveCustomTheme,
      mockGetPresets,
      mockWidget,
    );
  });

  group('After-Salah Azkar Toggle', () {
    test('toggling after-salah azkar updates all prayers', () async {
      // Simulate the use case toggling and returning true
      when(() => mockToggle.execute()).thenAnswer((_) async => true);
      // After toggling, repo returns updated salaah settings
      when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(true);
      when(() => mockRepo.salaahSettings).thenReturn(
        Salaah.values
            .map(
              (s) => SalaahSettings(salaah: s, isAfterSalahAzkarEnabled: true),
            )
            .toList(),
      );

      cubit.toggleAfterSalahAzkar();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isAfterSalahAzkarEnabled, true);
      expect(
        cubit.state.salaahSettings.every((s) => s.isAfterSalahAzkarEnabled),
        true,
      );
      verify(() => mockToggle.execute()).called(1);
    });
  });
}
