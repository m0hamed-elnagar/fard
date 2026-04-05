import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAzkarRepository extends Mock implements AzkarRepository {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

class MockSyncLocationSettings extends Mock implements SyncLocationSettings {}

class MockSyncNotificationSchedule extends Mock
    implements SyncNotificationSchedule {}

class MockToggleAfterSalahAzkarUseCase extends Mock
    implements ToggleAfterSalahAzkarUseCase {}

class MockUpdateCalculationMethodUseCase extends Mock
    implements UpdateCalculationMethodUseCase {}

void main() {
  late SettingsCubit cubit;
  late MockSettingsRepository mockSettingsRepo;
  late MockLocationService mockLocation;
  late MockSyncLocationSettings mockSyncLoc;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkarUseCase mockToggleAzkar;
  late MockUpdateCalculationMethodUseCase mockUpdateMethod;
  late MockWidgetUpdateService mockWidget;

  setUp(() {
    mockSettingsRepo = MockSettingsRepository();
    mockLocation = MockLocationService();
    mockSyncLoc = MockSyncLocationSettings();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggleAzkar = MockToggleAfterSalahAzkarUseCase();
    mockUpdateMethod = MockUpdateCalculationMethodUseCase();
    mockWidget = MockWidgetUpdateService();

    // Mock SettingsRepository defaults
    when(() => mockSettingsRepo.locale).thenReturn(const Locale('ar'));
    when(() => mockSettingsRepo.latitude).thenReturn(null);
    when(() => mockSettingsRepo.longitude).thenReturn(null);
    when(() => mockSettingsRepo.cityName).thenReturn(null);
    when(() => mockSettingsRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockSettingsRepo.madhab).thenReturn('shafi');
    when(() => mockSettingsRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockSettingsRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockSettingsRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockSettingsRepo.isQadaEnabled).thenReturn(true);
    when(() => mockSettingsRepo.hijriAdjustment).thenReturn(0);
    when(() => mockSettingsRepo.reminders).thenReturn([]);
    when(
      () => mockSettingsRepo.salaahSettings,
    ).thenReturn(Salaah.values.map((s) => SalaahSettings(salaah: s)).toList());
    when(() => mockSettingsRepo.updateLocale(any())).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateLocation(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        cityName: any(named: 'cityName'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateCalculationMethod(any()),
    ).thenAnswer((_) async {});
    when(() => mockSettingsRepo.updateMadhab(any())).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateMorningAzkarTime(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateEveningAzkarTime(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateSalaahSettings(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateHijriAdjustment(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAfterSalahAzkarEnabled(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSettingsRepo.toggleQadaEnabled(),
    ).thenAnswer((_) async => true);
    when(() => mockSettingsRepo.addReminder(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepo.removeReminder(any())).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateReminder(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockSettingsRepo.toggleReminder(any())).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAllAzanEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAllReminderEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAllAzanSound(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAllReminderMinutes(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsRepo.updateAllAfterSalahMinutes(any()),
    ).thenAnswer((_) async {});

    // Mock use cases
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});
    when(() => mockSyncNotif.init()).thenAnswer((_) async {});
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
    when(() => mockToggleAzkar.execute()).thenAnswer((_) async => true);
    when(() => mockUpdateMethod.execute(any())).thenAnswer((_) async => 0);
    when(() => mockWidget.updateWidget()).thenAnswer((_) async {});
    when(
      () => mockLocation.openLocationSettings(),
    ).thenAnswer((_) async => true);
    when(() => mockLocation.openAppSettings()).thenAnswer((_) async => true);

    cubit = SettingsCubit(
      mockSettingsRepo,
      mockLocation,
      mockSyncLoc,
      mockSyncNotif,
      mockToggleAzkar,
      mockUpdateMethod,
      mockWidget,
    );
  });

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(const SettingsState(locale: Locale('ar')));
    registerFallbackValue(AzkarReminder(category: '', time: '', title: ''));
  });

  group('SettingsCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.calculationMethod, 'muslim_league');
      expect(cubit.state.salaahSettings, isNotEmpty);
    });

    test(
      'updateSalaahSettings updates state, saves to prefs and schedules notifications',
      () async {
        final initialSettings = cubit.state.salaahSettings;
        final target = initialSettings.first;
        final updatedItem = target.copyWith(isAzanEnabled: false);

        cubit.updateSalaahSettings(updatedItem);

        // Wait for async calls
        await Future.delayed(const Duration(milliseconds: 100));

        // 1. Verify State
        expect(cubit.state.salaahSettings.first.isAzanEnabled, false);
        
        // 2. Verify Repository - This is the crucial check the user likely wants
        // We want to make sure the list passed to the repo contains our change
        verify(() => mockSettingsRepo.updateSalaahSettings(
          any(that: isA<List<SalaahSettings>>().having(
            (list) => list.firstWhere((s) => s.salaah == updatedItem.salaah).isAzanEnabled,
            'item isAzanEnabled',
            false,
          )),
        )).called(1);
        
        verify(() => mockSyncNotif.execute()).called(1);
      },
    );

    test('updateLocale updates state and prefs', () async {
      cubit.updateLocale(const Locale('en'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.locale, const Locale('en'));
      verify(() => mockSettingsRepo.updateLocale(const Locale('en'))).called(1);
    });

    test(
      'refreshLocation updates state with mapped calculation method',
      () async {
        final position = Position(
          latitude: 30.0444,
          longitude: 31.2357,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        when(
          () => mockLocation.getCurrentPosition(),
        ).thenAnswer((_) async => position);
        when(
          () => mockLocation.getLocationDataFromCoordinates(any(), any()),
        ).thenAnswer((_) async => {'city': 'Cairo', 'countryCode': 'EG'});

        await cubit.refreshLocation();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.cityName, 'Cairo');
        expect(cubit.state.calculationMethod, 'egyptian');
        verify(() => mockSyncLoc.execute()).called(1);
      },
    );

    test('mapCountryToMethod returns correct methods', () async {
      when(() => mockSyncLoc.execute()).thenAnswer(
        (_) async => LocationSyncResult(
          latitude: 21.4225,
          longitude: 39.8262,
          cityName: 'Mecca',
          calculationMethod: 'umm_al_qura',
          hijriAdjustment: 0,
          status: LocationStatus.success,
        ),
      );

      await cubit.refreshLocation();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.calculationMethod, 'umm_al_qura');
    });

    test('updateMadhab triggers widget update', () async {
      cubit.updateMadhab('hanafi');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.madhab, 'hanafi');
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('updateCalculationMethod triggers widget update', () async {
      cubit.updateCalculationMethod('egyptian');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.calculationMethod, 'egyptian');
      verify(() => mockWidget.updateWidget()).called(1);
    });

    test('updateHijriAdjustment triggers widget update', () async {
      cubit.updateHijriAdjustment(2);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.hijriAdjustment, 2);
      verify(() => mockWidget.updateWidget()).called(1);
    });

    group('Bulk Updates', () {
      test('updateAllAzanEnabled updates repo and state', () async {
        final updatedSettings = Salaah.values
            .map((s) => SalaahSettings(salaah: s, isAzanEnabled: false))
            .toList();
        when(
          () => mockSettingsRepo.updateAllAzanEnabled(any()),
        ).thenAnswer((_) async {});
        when(() => mockSettingsRepo.salaahSettings).thenReturn(updatedSettings);

        cubit.updateAllAzanEnabled(false);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.salaahSettings.every((s) => !s.isAzanEnabled), true);
        verify(() => mockSettingsRepo.updateAllAzanEnabled(false)).called(1);
        verify(() => mockSyncNotif.execute()).called(1);
      });

      test('updateAllReminderEnabled updates repo and state', () async {
        final updatedSettings = Salaah.values
            .map((s) => SalaahSettings(salaah: s, isReminderEnabled: true))
            .toList();
        when(
          () => mockSettingsRepo.updateAllReminderEnabled(any()),
        ).thenAnswer((_) async {});
        when(() => mockSettingsRepo.salaahSettings).thenReturn(updatedSettings);

        cubit.updateAllReminderEnabled(true);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          cubit.state.salaahSettings.every((s) => s.isReminderEnabled),
          true,
        );
        verify(() => mockSettingsRepo.updateAllReminderEnabled(true)).called(1);
        verify(() => mockSyncNotif.execute()).called(1);
      });

      test('updateAllAzanSound updates repo and state', () async {
        const sound = 'custom_azan.mp3';
        final updatedSettings = Salaah.values
            .map((s) => SalaahSettings(salaah: s, azanSound: sound))
            .toList();
        when(
          () => mockSettingsRepo.updateAllAzanSound(any()),
        ).thenAnswer((_) async {});
        when(() => mockSettingsRepo.salaahSettings).thenReturn(updatedSettings);

        cubit.updateAllAzanSound(sound);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          cubit.state.salaahSettings.every((s) => s.azanSound == sound),
          true,
        );
        verify(() => mockSettingsRepo.updateAllAzanSound(sound)).called(1);
        verify(() => mockSyncNotif.execute()).called(1);
      });

      test('updateAllReminderMinutes updates repo and state', () async {
        const mins = 10;
        final updatedSettings = Salaah.values
            .map((s) => SalaahSettings(salaah: s, reminderMinutesBefore: mins))
            .toList();
        when(
          () => mockSettingsRepo.updateAllReminderMinutes(any()),
        ).thenAnswer((_) async {});
        when(() => mockSettingsRepo.salaahSettings).thenReturn(updatedSettings);

        cubit.updateAllReminderMinutes(mins);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          cubit.state.salaahSettings.every(
            (s) => s.reminderMinutesBefore == mins,
          ),
          true,
        );
        verify(() => mockSettingsRepo.updateAllReminderMinutes(mins)).called(1);
        verify(() => mockSyncNotif.execute()).called(1);
      });

      test('updateAllAfterSalahMinutes updates repo and state', () async {
        const mins = 5;
        final updatedSettings = Salaah.values
            .map(
              (s) => SalaahSettings(salaah: s, afterSalaahAzkarMinutes: mins),
            )
            .toList();
        when(
          () => mockSettingsRepo.updateAllAfterSalahMinutes(any()),
        ).thenAnswer((_) async {});
        when(() => mockSettingsRepo.salaahSettings).thenReturn(updatedSettings);

        cubit.updateAllAfterSalahMinutes(mins);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          cubit.state.salaahSettings.every(
            (s) => s.afterSalaahAzkarMinutes == mins,
          ),
          true,
        );
        verify(
          () => mockSettingsRepo.updateAllAfterSalahMinutes(mins),
        ).called(1);
        verify(() => mockSyncNotif.execute()).called(1);
      });
    });
  });
}
