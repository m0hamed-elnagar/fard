import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockSyncNotificationSchedule extends Mock implements SyncNotificationSchedule {}

void main() {
  late AdhanCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockSyncNotificationSchedule mockSyncNotif;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockSyncNotif = MockSyncNotificationSchedule();

    final initialSalaahSettings = Salaah.values.map((s) => SalaahSettings(salaah: s)).toList();
    when(() => mockRepo.salaahSettings).thenReturn(initialSalaahSettings);
    when(() => mockRepo.audioQuality).thenReturn(AudioQuality.low64);
    when(() => mockRepo.isAudioPlayerExpanded).thenReturn(false);

    when(() => mockRepo.updateSalaahSettings(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAudioQuality(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAudioPlayerExpanded(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAllAzanEnabled(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateAllAzanSound(any())).thenAnswer((_) async {});
    when(() => mockSyncNotif.execute()).thenAnswer((_) async {});

    cubit = AdhanCubit(
      mockRepo,
      mockSyncNotif,
    );
  });

  setUpAll(() {
    registerFallbackValue(AudioQuality.low64);
  });

  group('AdhanCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.audioQuality, AudioQuality.low64);
      expect(cubit.state.salaahSettings, isNotEmpty);
    });

    test('updateSalaahSettings updates state, saves to repo and syncs notifications', () async {
      final target = cubit.state.salaahSettings.first;
      final updatedItem = target.copyWith(isAzanEnabled: false);

      cubit.updateSalaahSettings(updatedItem);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.salaahSettings.first.isAzanEnabled, false);
      verify(() => mockRepo.updateSalaahSettings(any())).called(1);
      verify(() => mockSyncNotif.execute()).called(1);
    });

    test('updateAudioQuality updates state and repo', () async {
      cubit.updateAudioQuality(AudioQuality.high192);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.audioQuality, AudioQuality.high192);
      verify(() => mockRepo.updateAudioQuality(AudioQuality.high192)).called(1);
    });

    test('updateAllAzanEnabled updates repo and state', () async {
      final updatedSettings = Salaah.values
          .map((s) => SalaahSettings(salaah: s, isAzanEnabled: false))
          .toList();
      when(() => mockRepo.salaahSettings).thenReturn(updatedSettings);

      cubit.updateAllAzanEnabled(false);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.salaahSettings.every((s) => !s.isAzanEnabled), true);
      verify(() => mockRepo.updateAllAzanEnabled(false)).called(1);
    });
  });
}
