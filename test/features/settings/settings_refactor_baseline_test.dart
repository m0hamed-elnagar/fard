import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/azkar/data/azkar_source.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/usecases/apply_theme_preset.dart';
import 'package:fard/features/settings/domain/usecases/get_available_theme_presets.dart';
import 'package:fard/features/settings/domain/usecases/save_custom_theme.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAzkarSource extends Mock implements IAzkarSource {}
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
  late MockLocationService mockLocation;
  late MockSyncLocationSettings mockSyncLoc;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkarUseCase mockToggleAzkar;
  late MockUpdateCalculationMethodUseCase mockUpdateMethod;
  late MockApplyThemePreset mockApplyTheme;
  late MockSaveCustomTheme mockSaveCustomTheme;
  late MockGetAvailableThemePresets mockGetPresets;
  late MockWidgetUpdateService mockWidget;

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(const SettingsState(locale: Locale('ar')));
    registerFallbackValue(AzkarReminder(category: '', time: '', title: ''));
    registerFallbackValue(PrayerReminderType.after);
    registerFallbackValue(CustomTheme.defaultPalette(id: '1', name: '1'));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(SalaahSettings(salaah: Salaah.fajr));
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockLocation = MockLocationService();
    mockSyncLoc = MockSyncLocationSettings();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggleAzkar = MockToggleAfterSalahAzkarUseCase();
    mockUpdateMethod = MockUpdateCalculationMethodUseCase();
    mockApplyTheme = MockApplyThemePreset();
    mockSaveCustomTheme = MockSaveCustomTheme();
    mockGetPresets = MockGetAvailableThemePresets();
    mockWidget = MockWidgetUpdateService();

    // Default Repo Stubs
    when(() => mockRepo.latitude).thenReturn(30.0);
    when(() => mockRepo.longitude).thenReturn(31.0);
    when(() => mockRepo.cityName).thenReturn('Cairo');
    when(() => mockRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockRepo.madhab).thenReturn('shafi');
    when(() => mockRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockRepo.reminders).thenReturn([]);
    when(() => mockRepo.salaahSettings).thenReturn(
      Salaah.values.map((s) => SalaahSettings(salaah: s)).toList(),
    );
    when(() => mockRepo.isQadaEnabled).thenReturn(true);
    when(() => mockRepo.hijriAdjustment).thenReturn(0);
    when(() => mockRepo.themePresetId).thenReturn('emerald_gold');
    when(() => mockRepo.customThemeColors).thenReturn(null);
    when(() => mockRepo.savedCustomThemes).thenReturn([]);
    when(() => mockRepo.activeCustomThemeId).thenReturn(null);
    when(() => mockRepo.audioQuality).thenReturn(AudioQuality.low64);
    when(() => mockRepo.isAudioPlayerExpanded).thenReturn(false);
    when(() => mockRepo.isSalahReminderEnabled).thenReturn(false);
    when(() => mockRepo.salahReminderOffsetMinutes).thenReturn(0);
    when(() => mockRepo.prayerReminderType).thenReturn(PrayerReminderType.after);
    when(() => mockRepo.enabledSalahReminders).thenReturn(<Salaah>{});
    when(() => mockRepo.isWerdReminderEnabled).thenReturn(false);
    when(() => mockRepo.werdReminderTime).thenReturn('04:00');
    when(() => mockRepo.isSalawatReminderEnabled).thenReturn(false);
    when(() => mockRepo.salawatFrequencyHours).thenReturn(1);
    when(() => mockRepo.salawatStartTime).thenReturn('08:00');
    when(() => mockRepo.salawatEndTime).thenReturn('22:00');

    // Default UseCase Stubs
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});
    when(() => mockSyncLoc.execute()).thenAnswer(
      (_) async => LocationSyncResult(
        latitude: 30.0444,
        longitude: 31.2357,
        cityName: 'Cairo',
        calculationMethod: 'egyptian',
        hijriAdjustment: 0,
        status: LocationStatus.success,
      ),
    );
    when(() => mockWidget.updateWidget()).thenAnswer((_) async {});
    when(() => mockWidget.clearWidgetTheme(triggerUpdate: any(named: 'triggerUpdate'))).thenAnswer((_) async {});
    when(() => mockApplyTheme.execute(any())).thenAnswer((_) async {});

    cubit = SettingsCubit(
      mockRepo,
      mockLocation,
      mockSyncLoc,
      mockSyncNotif,
      mockToggleAzkar,
      mockUpdateMethod,
      mockApplyTheme,
      mockSaveCustomTheme,
      mockGetPresets,
      mockWidget,
    );
  });

  group('SettingsCubit Refactor Baselines', () {
    test('Location Flow: refreshLocation updates state and triggers syncs', () async {
      await cubit.refreshLocation();
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify state update
      expect(cubit.state.latitude, 30.0444);
      expect(cubit.state.cityName, 'Cairo');
      expect(cubit.state.calculationMethod, 'egyptian');

      // Verify coordination
      verify(() => mockSyncLoc.execute()).called(1);
      verify(() => mockSyncNotif.execute()).called(1);
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('Notification Flow: updateSalaahSettings triggers notification sync', () async {
      final settings = SalaahSettings(salaah: Salaah.fajr, isAzanEnabled: false);
      when(() => mockRepo.updateSalaahSettings(any())).thenAnswer((_) async {});

      cubit.updateSalaahSettings(settings);
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify coordination
      verify(() => mockSyncNotif.execute()).called(1);
      // Verify persistence
      verify(() => mockRepo.updateSalaahSettings(any())).called(1);
    });

    test('Theme Flow: selectThemePreset updates state and triggers widget sync', () async {
      await cubit.selectThemePreset('ocean_blue');
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify state update
      expect(cubit.state.themePresetId, 'ocean_blue');

      // Verify coordination
      verify(() => mockApplyTheme.execute('ocean_blue')).called(1);
      verify(() => mockWidget.clearWidgetTheme(triggerUpdate: false)).called(1);
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('Reminder Flow: toggleSalahReminder triggers notification sync', () async {
      when(() => mockRepo.updateSalahReminderEnabled(any())).thenAnswer((_) async {});
      
      cubit.toggleSalahReminder(true);
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockSyncNotif.execute()).called(1);
      verify(() => mockRepo.updateSalahReminderEnabled(true)).called(1);
    });

    test('Smart Toggle Invariant: enabling specific reminder turns on master if off', () async {
      when(() => mockRepo.updateSalahReminderEnabled(any())).thenAnswer((_) async {});
      when(() => mockRepo.updateEnabledSalahReminders(any())).thenAnswer((_) async {});
      
      expect(cubit.state.isSalahReminderEnabled, false);

      cubit.toggleSpecificSalahReminder(Salaah.fajr);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isSalahReminderEnabled, true);
      expect(cubit.state.enabledSalahReminders, contains(Salaah.fajr));
      
      verify(() => mockRepo.updateSalahReminderEnabled(true)).called(1);
      verify(() => mockSyncNotif.execute()).called(1);
    });
  });
}
