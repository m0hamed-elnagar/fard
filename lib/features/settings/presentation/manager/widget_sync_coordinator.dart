import 'dart:async';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:injectable/injectable.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/location_prayer_cubit.dart';
import '../blocs/adhan_cubit.dart';
import '../blocs/daily_reminders_cubit.dart';

@singleton
class WidgetSyncCoordinator {
  final WidgetUpdateService _widgetUpdateService;
  final ThemeCubit _themeCubit;
  final LocationPrayerCubit _locationPrayerCubit;
  final AdhanCubit _adhanCubit;
  final DailyRemindersCubit _dailyRemindersCubit;

  StreamSubscription? _themeSubscription;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _adhanSubscription;
  StreamSubscription? _remindersSubscription;

  WidgetSyncCoordinator(
    this._widgetUpdateService,
    this._themeCubit,
    this._locationPrayerCubit,
    this._adhanCubit,
    this._dailyRemindersCubit,
  );

  void init() {
    // Listen to Theme changes
    _themeSubscription = _themeCubit.stream.listen((state) {
      // Re-update widget when theme or locale changes
      _widgetUpdateService.updateWidget();
    });

    // Listen to Location/Calculation changes
    _locationSubscription = _locationPrayerCubit.stream.listen((state) {
      // Re-update widget when location or calculation settings change
      _widgetUpdateService.updateWidget();
    });

    // Adhan settings change
    _adhanSubscription = _adhanCubit.stream.listen((state) {
      // Some native components might need to know about Azan status changes
      _widgetUpdateService.updateWidget();
    });
    
    // Daily Reminders changes
    _remindersSubscription = _dailyRemindersCubit.stream.listen((state) {
      // Reminders might affect some widget data in the future
      _widgetUpdateService.updateWidget();
    });
  }

  void dispose() {
    _themeSubscription?.cancel();
    _locationSubscription?.cancel();
    _adhanSubscription?.cancel();
    _remindersSubscription?.cancel();
  }
}
