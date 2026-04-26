import 'package:fard/core/constants/settings_keys.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fard/features/settings/data/repositories/settings_storage.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSettingsStorage extends Mock implements SettingsStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSettingsStorage mockStorage;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockStorage = MockSettingsStorage();
    mockPrefs = MockSharedPreferences();
    when(() => mockStorage.prefs).thenReturn(mockPrefs);
    
    // Default mock behavior for storage
    when(() => mockStorage.readBool(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((invocation) => invocation.namedArguments[#defaultValue] ?? false);
    when(() => mockStorage.readString(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((invocation) => invocation.namedArguments[#defaultValue]);
    when(() => mockStorage.readInt(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((invocation) => invocation.namedArguments[#defaultValue] ?? 0);
        
    when(() => mockStorage.writeBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockStorage.writeString(any(), any())).thenAnswer((_) async => true);
    when(() => mockStorage.writeInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockStorage.writeJsonList<SalaahSettings>(any(), any(), any())).thenAnswer((_) async => true);
  });

  group('SettingsRepositoryImpl Migration', () {
    test('performs migration when isSalahReminderEnabled is missing', () async {
      // 1. Setup old settings
      final oldSalaahSettings = [
        SalaahSettings(salaah: Salaah.fajr, isAzanEnabled: true),
        SalaahSettings(salaah: Salaah.dhuhr, isAzanEnabled: false, isReminderEnabled: true),
        SalaahSettings(salaah: Salaah.asr, isAzanEnabled: false, isReminderEnabled: false),
      ];

      when(() => mockStorage.readJsonList<SalaahSettings>(SettingsKeys.salaahSettings, any()))
          .thenReturn(oldSalaahSettings);
      
      // key is missing
      when(() => mockPrefs.containsKey(SettingsKeys.isSalahReminderEnabled)).thenReturn(false);
      when(() => mockStorage.readBool('azan_settings_migration_v1_done')).thenReturn(false);

      // 2. Initialize repository (triggers migration)
      SettingsRepositoryImpl(mockStorage);

      // 3. Verify migration happened
      // We need to wait a bit because migration is async in constructor
      await Future.delayed(const Duration(milliseconds: 100));

      // Should enable global reminder
      verify(() => mockStorage.writeBool(SettingsKeys.isSalahReminderEnabled, true)).called(1);
      
      // Should enable Fajr (isAzanEnabled) and Dhuhr (isReminderEnabled), but NOT Asr
      verify(() => mockStorage.writeString(
        SettingsKeys.enabledSalahReminders,
        any(that: allOf(
          contains('fajr'),
          contains('dhuhr'),
          isNot(contains('asr')),
        )),
      )).called(1);

      // Should mark migration as done
      verify(() => mockStorage.writeBool('azan_settings_migration_v1_done', true)).called(1);
    });

    test('does not perform migration if already done', () async {
      when(() => mockStorage.readBool('azan_settings_migration_v1_done')).thenReturn(true);

      SettingsRepositoryImpl(mockStorage);
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => mockStorage.writeBool(SettingsKeys.isSalahReminderEnabled, any()));
    });

    test('does not perform migration if isSalahReminderEnabled already exists', () async {
      when(() => mockStorage.readBool('azan_settings_migration_v1_done')).thenReturn(false);
      when(() => mockPrefs.containsKey(SettingsKeys.isSalahReminderEnabled)).thenReturn(true);

      SettingsRepositoryImpl(mockStorage);
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => mockStorage.writeBool(SettingsKeys.isSalahReminderEnabled, any()));
      // But still marks migration as done to avoid checking again
      verify(() => mockStorage.writeBool('azan_settings_migration_v1_done', true)).called(1);
    });
  });
}
