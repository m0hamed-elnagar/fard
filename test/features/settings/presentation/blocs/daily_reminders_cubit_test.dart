import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}
class MockToggleAfterSalahAzkarUseCase extends Mock implements ToggleAfterSalahAzkarUseCase {}

void main() {
  late DailyRemindersCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockSyncNotificationSchedule mockSyncNotif;
  late MockToggleAfterSalahAzkarUseCase mockToggleAzkar;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockSyncNotif = MockSyncNotificationSchedule();
    mockToggleAzkar = MockToggleAfterSalahAzkarUseCase();

    when(() => mockRepo.morningAzkarTime).thenReturn('05:00');
    when(() => mockRepo.eveningAzkarTime).thenReturn('18:00');
    when(() => mockRepo.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockRepo.reminders).thenReturn([]);
    when(() => mockRepo.isQadaEnabled).thenReturn(true);
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

    when(() => mockRepo.updateMorningAzkarTime(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateEveningAzkarTime(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateSalahReminderEnabled(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateEnabledSalahReminders(any())).thenAnswer((_) async {});
    when(() => mockRepo.toggleQadaEnabled()).thenAnswer((_) async {});
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});

    cubit = DailyRemindersCubit(
      mockRepo,
      mockSyncNotif,
      mockToggleAzkar,
    );
  });

  setUpAll(() {
    registerFallbackValue(AzkarReminder(category: '', time: '', title: ''));
    registerFallbackValue(PrayerReminderType.after);
  });

  group('DailyRemindersCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.morningAzkarTime, '05:00');
      expect(cubit.state.isQadaEnabled, true);
    });

    test('updateMorningAzkarTime updates state and repo', () async {
      cubit.updateMorningAzkarTime('06:00');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.morningAzkarTime, '06:00');
      verify(() => mockRepo.updateMorningAzkarTime('06:00')).called(1);
    });

    test('toggleQadaEnabled updates state and repo', () async {
      bool qadaEnabled = true;
      when(() => mockRepo.isQadaEnabled).thenAnswer((_) => qadaEnabled = !qadaEnabled);
      
      cubit.toggleQadaEnabled();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.isQadaEnabled, false);
      verify(() => mockRepo.toggleQadaEnabled()).called(1);
    });

    group('Smart Master Toggle', () {
      test('toggleSpecificSalahReminder turns ON master switch if it was OFF when enabling a reminder', () async {
        expect(cubit.state.isSalahReminderEnabled, false);

        cubit.toggleSpecificSalahReminder(Salaah.fajr);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.isSalahReminderEnabled, true);
        expect(cubit.state.enabledSalahReminders, contains(Salaah.fajr));
        verify(() => mockRepo.updateSalahReminderEnabled(true)).called(1);
        verify(() => mockRepo.updateEnabledSalahReminders(any())).called(1);
      });
    });
  });
}
