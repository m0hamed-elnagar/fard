part of 'prayer_tracker_bloc.dart';

@freezed
class PrayerTrackerState with _$PrayerTrackerState {
  const factory PrayerTrackerState.loading() = _Loading;
  const factory PrayerTrackerState.loaded({
    required DateTime selectedDate,
    required Set<Salaah> missedToday,
    @Default({}) Set<Salaah> completedToday,
    required Map<Salaah, MissedCounter> qadaStatus,
    required Map<DateTime, DailyRecord> monthRecords,
    required List<DailyRecord> history,
  }) = _Loaded;
  const factory PrayerTrackerState.missedDaysPrompt({
    required List<DateTime> missedDates,
  }) = _MissedDaysPrompt;
  const factory PrayerTrackerState.error({required String message}) = _Error;
}
