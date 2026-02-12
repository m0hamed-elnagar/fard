part of 'prayer_tracker_bloc.dart';

@freezed
class PrayerTrackerState with _$PrayerTrackerState {
  const factory PrayerTrackerState.loading() = _Loading;
  const factory PrayerTrackerState.loaded({
    required DateTime selectedDate,
    required Set<Salaah> missedToday,
    required Map<Salaah, MissedCounter> qadaStatus,
    required Map<DateTime, DailyRecord> monthRecords,
    required List<DailyRecord> history,
  }) = _Loaded;
  const factory PrayerTrackerState.missedDaysPrompt({
    required List<DateTime> missedDates,
  }) = _MissedDaysPrompt;
}
