part of 'prayer_tracker_bloc.dart';

@freezed
class PrayerTrackerEvent with _$PrayerTrackerEvent {
  const factory PrayerTrackerEvent.load(DateTime date) = _Load;
  const factory PrayerTrackerEvent.togglePrayer(Salaah prayer) = _TogglePrayer;
  const factory PrayerTrackerEvent.addQada(Salaah prayer) = _AddQada;
  const factory PrayerTrackerEvent.removeQada(Salaah prayer) = _RemoveQada;
  const factory PrayerTrackerEvent.save() = _Save;
  const factory PrayerTrackerEvent.loadMonth(int year, int month) = _LoadMonth;
  const factory PrayerTrackerEvent.checkMissedDays() = _CheckMissedDays;
  const factory PrayerTrackerEvent.acknowledgeMissedDays({
    required List<DateTime> selectedDates,
  }) = _AcknowledgeMissedDays;
  const factory PrayerTrackerEvent.bulkAddQada(Map<Salaah, int> counts) =
      _BulkAddQada;
  const factory PrayerTrackerEvent.updateQada(Map<Salaah, int> counts) =
      _UpdateQada;
  const factory PrayerTrackerEvent.deleteRecord(DateTime date) = _DeleteRecord;
}
