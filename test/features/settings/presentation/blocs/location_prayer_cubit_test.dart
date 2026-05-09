import 'package:fard/core/services/location_service.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockSyncLocationSettings extends Mock implements SyncLocationSettings {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}
class MockUpdateCalculationMethodUseCase extends Mock implements UpdateCalculationMethodUseCase {}

void main() {
  late LocationPrayerCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockLocationService mockLocation;
  late MockSyncLocationSettings mockSyncLoc;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockUpdateCalculationMethodUseCase mockUpdateMethod;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockLocation = MockLocationService();
    mockSyncLoc = MockSyncLocationSettings();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockUpdateMethod = MockUpdateCalculationMethodUseCase();

    when(() => mockRepo.latitude).thenReturn(null);
    when(() => mockRepo.longitude).thenReturn(null);
    when(() => mockRepo.cityName).thenReturn(null);
    when(() => mockRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockRepo.madhab).thenReturn('shafi');
    when(() => mockRepo.hijriAdjustment).thenReturn(0);

    when(() => mockRepo.updateMadhab(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateHijriAdjustment(any())).thenAnswer((_) async {});
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});
    when(() => mockUpdateMethod.execute(any())).thenAnswer((_) async => 0);

    cubit = LocationPrayerCubit(
      mockRepo,
      mockLocation,
      mockSyncLoc,
      mockSyncNotif,
      mockUpdateMethod,
    );
  });

  group('LocationPrayerCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.calculationMethod, 'muslim_league');
      expect(cubit.state.madhab, 'shafi');
    });

    test('refreshLocation updates state with sync results', () async {
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

      await cubit.refreshLocation();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.cityName, 'Cairo');
      expect(cubit.state.calculationMethod, 'egyptian');
      verify(() => mockSyncLoc.execute()).called(1);
    });

    test('updateMadhab updates state and repo', () async {
      cubit.updateMadhab('hanafi');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.madhab, 'hanafi');
      verify(() => mockRepo.updateMadhab('hanafi')).called(1);
    });

    test('updateCalculationMethod updates state and repo', () async {
      cubit.updateCalculationMethod('egyptian');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.calculationMethod, 'egyptian');
      verify(() => mockUpdateMethod.execute('egyptian')).called(1);
    });

    test('updateHijriAdjustment updates state and repo', () async {
      cubit.updateHijriAdjustment(2);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.hijriAdjustment, 2);
      verify(() => mockRepo.updateHijriAdjustment(2)).called(1);
    });
  });
}
