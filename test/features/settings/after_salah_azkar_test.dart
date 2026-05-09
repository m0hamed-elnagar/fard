import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}
class MockToggleAfterSalahAzkarUseCase extends Mock implements ToggleAfterSalahAzkarUseCase {}
class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

void main() {
  late DailyRemindersCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkarUseCase mockToggle;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  void mockDefaults() {
    when(() => mockRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockRepo.reminders).thenReturn([]);
    when(() => mockRepo.isQadaEnabled).thenReturn(true);
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
    
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});
  }

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggle = MockToggleAfterSalahAzkarUseCase();
    mockDefaults();

    cubit = DailyRemindersCubit(
      mockRepo,
      mockSyncNotif,
      mockToggle,
    );
  });

  group('After-Salah Azkar Toggle', () {
    test('toggling after-salah azkar calls the use case and updates state', () async {
      // Simulate the use case toggling and returning true
      when(() => mockToggle.execute()).thenAnswer((_) async => true);

      cubit.toggleAfterSalahAzkar();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isAfterSalahAzkarEnabled, true);
      verify(() => mockToggle.execute()).called(1);
      verify(() => mockSyncNotif.execute()).called(1);
    });
  });
}
