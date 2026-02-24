// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fard - Qada Tracker';

  @override
  String get dailyPrayers => 'Daily Prayers';

  @override
  String get remaining => 'Remaining';

  @override
  String get appName => 'Fard';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get onboardingTitle1 => 'Track Your Prayers';

  @override
  String get onboardingDesc1 =>
      'Keep a record of your daily prayers and never miss a beat.';

  @override
  String get onboardingTitle2 => 'Manage Qada';

  @override
  String get onboardingDesc2 =>
      'Easily track and complete your missed prayers over time.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get calendar => 'Calendar';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history for this month';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String deleteConfirm(String date) {
    return 'Are you sure you want to delete the record for $date?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String missedCount(int count) {
    return 'Missed $count';
  }

  @override
  String get addQada => 'Add Qada';

  @override
  String get totalQada => 'Total Qada';

  @override
  String get byCount => 'By Count';

  @override
  String get byTime => 'By Time';

  @override
  String get add => 'Add';

  @override
  String get selectPeriod => 'Select period to calculate prayers';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get selectDate => 'Select Date';

  @override
  String get daysCount => 'Days Count';

  @override
  String get prayersPerFard => 'Prayers per fard';

  @override
  String get missedDaysTitle => 'Missed Days';

  @override
  String missedDaysMessage(int count) {
    return 'It looks like you missed $count days since your last record. Were you praying during this period? If not, they will be added to your remaining prayers.';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get skip => 'I was praying';

  @override
  String get addAll => 'Add to remaining';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get editQada => 'Edit Qada';

  @override
  String get next => 'Next';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get settings => 'Settings';

  @override
  String get locationSettings => 'Location Settings';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get prayerSettings => 'Prayer Settings';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get madhab => 'Madhab';

  @override
  String get language => 'Language';

  @override
  String get locationDesc =>
      'Enables precise calculation of prayer times based on your current coordinates.';

  @override
  String get calculationMethodDesc =>
      'Select the authority used in your region for calculating Fajr and Isha angles.';

  @override
  String get madhabDesc =>
      'Determines the calculation for Asr prayer time (Hanafi vs. other schools).';

  @override
  String get shafiMadhab => 'Shafi, Maliki, Hanbali';

  @override
  String get hanafiMadhab => 'Hanafi';

  @override
  String get refreshLocation => 'Refresh Location';

  @override
  String get locationNotSet => 'Location not set';

  @override
  String get azkarSettings => 'Azkar Settings';

  @override
  String get morningAzkar => 'Morning Azkar';

  @override
  String get eveningAzkar => 'Evening Azkar';

  @override
  String get azkarSettingsDesc =>
      'Configure what time to show morning and evening Azkar reminders.';

  @override
  String get autoAzkarTimes => 'Auto (Follow Prayer Times)';

  @override
  String get autoAzkarTimesDesc =>
      'Automatically set Azkar times based on Fajr and Asr prayers.';

  @override
  String get timeFor => 'Time for';

  @override
  String get recommended => 'Recommended';

  @override
  String get azkar => 'Azkar';

  @override
  String get loadingAzkar => 'Loading Azkar...';

  @override
  String get errorLoadingAzkar => 'Error Loading Azkar';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get resetAllProgress => 'Reset All Progress';

  @override
  String get noItemsFound => 'No items found in this category';

  @override
  String get resetItem => 'Reset Item';

  @override
  String get prayerTab => 'Prayer';

  @override
  String get azkarTab => 'Azkar';

  @override
  String get search => 'Search...';

  @override
  String get noSearchResults => 'No search results found';

  @override
  String get searchCategory => 'Search for a category...';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get azanSettings => 'Azan & Reminder Settings';

  @override
  String get azan => 'Azan';

  @override
  String get reminder => 'Reminder';

  @override
  String minutesBefore(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String get azanVoice => 'Azan Voice';

  @override
  String get enableAzan => 'Enable Azan';

  @override
  String get enableReminder => 'Enable Reminder';

  @override
  String get qibla => 'Qibla';

  @override
  String get afterSalahAzkar => 'Azkar after Salah';

  @override
  String get afterSalahAzkarDesc =>
      'Reminder to read azkar 15 minutes after azan';

  @override
  String get quran => 'Quran';

  @override
  String get loadingQuran => 'Loading Quran...';

  @override
  String get errorLoadingQuran => 'Error Loading Quran';

  @override
  String get searchSurah => 'Search for a Surah...';

  @override
  String get ayah => 'Ayah';

  @override
  String get surah => 'Surah';

  @override
  String get quranTab => 'Quran';

  @override
  String get tasbihTab => 'Tasbih';

  @override
  String get tasbih => 'Tasbih';

  @override
  String get selectDhikrCategory => 'Select Dhikr Category';

  @override
  String get tasbihSettings => 'Tasbih Settings';

  @override
  String get customTasbihTarget => 'Custom Target';

  @override
  String customTasbihTargetHint(int count) {
    return 'Default: $count';
  }

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get showTranslation => 'Show Translation';

  @override
  String get showTransliteration => 'Show Transliteration';

  @override
  String get resetCounter => 'Reset Counter?';

  @override
  String get resetProgressWarning =>
      'This will reset your current progress to zero.';

  @override
  String get finishAndReset => 'Finish & Reset';

  @override
  String get errorLoadingTasbih => 'Error loading Tasbih data';

  @override
  String get rememberDua => 'Remember this Dua';

  @override
  String get changeDua => 'Change Dua';

  @override
  String get duaSaved => 'Dua saved for next time';

  @override
  String get finish => 'Finish';

  @override
  String get tasbih_after_salah_name => 'Tasbih after Salah';

  @override
  String get tasbih_after_salah_desc =>
      '33x SubhanAllah, Alhamdulillah, Allahu Akbar + Dua';

  @override
  String get tasbih_fatimah_name => 'Tasbih Fatimah (Bedtime)';

  @override
  String get tasbih_fatimah_desc =>
      '33x SubhanAllah, 33x Alhamdulillah, 34x Allahu Akbar';

  @override
  String get four_foundations_name => 'The Four Foundations';

  @override
  String get four_foundations_desc =>
      'SubhanAllah, Alhamdulillah, La ilaha illallah, Allahu Akbar';

  @override
  String get yunus_dhikr_name => 'Dhikr of Prophet Yunus';

  @override
  String get yunus_dhikr_desc => 'La ilaha illa anta subhanaka...';

  @override
  String get morning_evening_name => 'Morning & Evening Adhkar';

  @override
  String get morning_evening_desc =>
      'Daily remembrances for morning and evening';

  @override
  String get istighfar_name => 'Istighfar';

  @override
  String get istighfar_desc => 'Seeking Allah\'s forgiveness';

  @override
  String get salat_ibrahimiyyah_name => 'Salat Ibrahimiyyah';

  @override
  String get salat_ibrahimiyyah_desc => 'Salutations upon the Prophet (PBUH)';

  @override
  String get tahlil_takbir_tahmid_name => 'Tahlil, Takbir & Tahmid';

  @override
  String get tahlil_takbir_tahmid_desc => 'Fundamental declarations of faith';

  @override
  String get quran_adhkar_name => 'Adhkar from Quran';

  @override
  String get quran_adhkar_desc => 'Supplications directly from the Quran';

  @override
  String get ruqyah_protection_name => 'Ruqyah & Protection';

  @override
  String get ruqyah_protection_desc => 'Supplications for protection from harm';

  @override
  String get chooseCompletionDua => 'Choose Completion Dua';

  @override
  String get locationWarning =>
      'Prayer times cannot be calculated without your location.';

  @override
  String get givePermission => 'Give Permission';

  @override
  String get afterSalaahAzkar => 'Azkar al-Salaah';

  @override
  String minutesAfter(int minutes) {
    return '$minutes minutes after';
  }

  @override
  String get qadaTracker => 'Missed Prayers Tracker';

  @override
  String get qadaTrackerDesc =>
      'Track missed prayers (Qada) and set goals to complete them.';

  @override
  String get qadaOnboardingTitle => 'Qada Tracking';

  @override
  String get qadaOnboardingDesc =>
      'Would you like to track your missed prayers (Qada) and set goals to complete them?';

  @override
  String get enableQada => 'Enable Qada Tracking';

  @override
  String get disableQada => 'Disable for now';

  @override
  String get globalSettings => 'Global Notification Settings';

  @override
  String get globalSettingsDesc =>
      'Apply these settings to all five prayers at once.';

  @override
  String get individualSettings => 'Individual Prayer Settings';

  @override
  String get applyToAll => 'Apply to all';

  @override
  String get generalSettings => 'General App Settings';
}
