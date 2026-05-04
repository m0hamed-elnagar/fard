import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/azkar_reminder.dart';
import '../../domain/prayer_reminder_type.dart';

part 'daily_reminders_state.freezed.dart';

@freezed
sealed class DailyRemindersState with _$DailyRemindersState {
  const factory DailyRemindersState({
    @Default('05:00') String morningAzkarTime,
    @Default('18:00') String eveningAzkarTime,
    @Default(false) bool isAfterSalahAzkarEnabled,
    @Default([]) List<AzkarReminder> reminders,
    @Default(true) bool isQadaEnabled,
    @Default(false) bool isSalahReminderEnabled,
    @Default(15) int salahReminderOffsetMinutes,
    @Default(PrayerReminderType.after) PrayerReminderType prayerReminderType,
    @Default({}) Set<Salaah> enabledSalahReminders,
    @Default(false) bool isWerdReminderEnabled,
    @Default('20:00') String werdReminderTime,
    @Default(false) bool isSalawatReminderEnabled,
    @Default(3) int salawatFrequencyHours,
    @Default('10:00') String salawatStartTime,
    @Default('20:00') String salawatEndTime,
  }) = _DailyRemindersState;
}
