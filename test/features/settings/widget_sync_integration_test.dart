import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}
class MockSyncLocationSettings extends Mock implements SyncLocationSettings {}
class MockUpdateCalcMethod extends Mock implements UpdateCalculationMethodUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationPrayerCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockLocationService mockLocation;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockSyncLocationSettings mockSyncLoc;
  late MockUpdateCalcMethod mockUpdateMethod;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockLocation = MockLocationService();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockSyncLoc = MockSyncLocationSettings();
    mockUpdateMethod = MockUpdateCalcMethod();

    // Mock SettingsRepository defaults
    when(() => mockRepo.latitude).thenReturn(30.0);
    when(() => mockRepo.longitude).thenReturn(31.0);
    when(() => mockRepo.cityName).thenReturn('Cairo');
    when(() => mockRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockRepo.madhab).thenReturn('shafi');
    when(() => mockRepo.hijriAdjustment).thenReturn(0);

    when(() => mockRepo.updateMadhab(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateHijriAdjustment(any())).thenAnswer((_) async {});
    when(() => mockUpdateMethod.execute(any())).thenAnswer((_) async => 0);
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});

    cubit = LocationPrayerCubit(
      mockRepo,
      mockLocation,
      mockSyncLoc,
      mockSyncNotif,
      mockUpdateMethod,
    );
  });

  group('Widget Sync Integration', () {
    test('Changing Madhab triggers state update', () async {
      cubit.updateMadhab('hanafi');
      await Future.delayed(Duration.zero);
      expect(cubit.state.madhab, 'hanafi');
      verify(() => mockRepo.updateMadhab('hanafi')).called(1);
    });

    test('Changing Calculation Method triggers state update', () async {
      cubit.updateCalculationMethod('egyptian');
      await Future.delayed(Duration.zero);
      expect(cubit.state.calculationMethod, 'egyptian');
      verify(() => mockUpdateMethod.execute('egyptian')).called(1);
    });

    test('Changing Hijri Adjustment triggers state update', () async {
      cubit.updateHijriAdjustment(2);
      await Future.delayed(Duration.zero);
      expect(cubit.state.hijriAdjustment, 2);
      verify(() => mockRepo.updateHijriAdjustment(2)).called(1);
    });
  });
}
