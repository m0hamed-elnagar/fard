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
  String get today => 'TODAY';

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
  String get saveSelection => 'Save selection';

  @override
  String get edit => 'Edit';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get toggleDates => 'Toggle dates you missed';

  @override
  String get update => 'Update';

  @override
  String get editQada => 'Edit Qada';

  @override
  String get next => 'Next';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get duha => 'Duha';

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
  String get locationDisabledTitle => 'Location Disabled';

  @override
  String get locationDisabledDesc =>
      'Please enable location services (GPS) to calculate prayer times accurately.';

  @override
  String get enableGPS => 'Enable GPS';

  @override
  String get locationDeniedTitle => 'Location Permission Denied';

  @override
  String get locationDeniedDesc =>
      'This app needs location permission to calculate prayer times based on your city. Please grant permission to continue.';

  @override
  String get locationDeniedForeverTitle => 'Location Permission Required';

  @override
  String get locationDeniedForeverDesc =>
      'Location permission is permanently denied. Please enable it from app settings to use this feature.';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDesc =>
      'Open system settings to manage app notifications and permissions.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get later => 'Later';

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
  String get azanNotifications => 'Azan & Notifications';

  @override
  String get azanSettingsDesc =>
      'Manage azan voices, reminders, and after-salah azkar for all prayers.';

  @override
  String get individualSettings => 'Individual Prayer Settings';

  @override
  String get createNewTheme => 'Create New Theme';

  @override
  String get savedThemes => 'Saved Themes';

  @override
  String get editTheme => 'Edit Theme';

  @override
  String get autoDerive => 'Auto';

  @override
  String get select => 'Select';

  @override
  String get updateTheme => 'Update Theme';

  @override
  String get saveTheme => 'Save Theme';

  @override
  String get nameYourTheme => 'Name Your Theme';

  @override
  String get themeNameHint => 'e.g. My Dark Gold';

  @override
  String get deleteTheme => 'Delete Theme';

  @override
  String deleteThemeConfirm(Object themeName) {
    return 'Are you sure you want to delete \"$themeName\"? This cannot be undone.';
  }

  @override
  String get applyToAll => 'Apply to all';

  @override
  String get generalSettings => 'General App Settings';

  @override
  String get exactAlarmWarningTitle => 'Warning: Azan may not work accurately';

  @override
  String get exactAlarmWarningDesc =>
      'Please enable \"Exact Alarms\" from system settings to ensure Azan works on time.';

  @override
  String get editEachPrayer => 'Edit each prayer';

  @override
  String get noRemindersSet => 'No reminders set';

  @override
  String get azanDownloadError =>
      'Failed to download Azan voice. Ensure the site is accessible or try another voice.';

  @override
  String get testAzan => 'Test Sound';

  @override
  String get testReminder => 'Test Reminder';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get category => 'Category';

  @override
  String get customTitleOptional => 'Custom Title (Optional)';

  @override
  String get time => 'Time';

  @override
  String get lowBitrate => 'Low (64k)';

  @override
  String get medBitrate => 'Med (128k)';

  @override
  String get highBitrate => 'High (192k)';

  @override
  String get defaultVal => 'Phone Notification';

  @override
  String get pagesDownloadedSuccess => 'All pages downloaded successfully';

  @override
  String get downloadMushafPages => 'Download Mushaf Pages';

  @override
  String get cacheClearedReloading => 'Cache cleared and reloading';

  @override
  String get close => 'Close';

  @override
  String get textSize => 'Text Size';

  @override
  String get quranReader => 'Quran Reader';

  @override
  String get markAsLastReadSuccess => 'Marked as last read';

  @override
  String get reciter => 'Reciter';

  @override
  String errorReadingCompass(Object error) {
    return 'Error reading compass: $error';
  }

  @override
  String get deviceNoSensors => 'Device does not have sensors!';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get audioQuality => 'Audio Quality';

  @override
  String get selectReciter => 'Select Reciter';

  @override
  String get scannedMushaf => 'Scanned Mushaf';

  @override
  String surahWithVal(Object name) {
    return 'Surah $name';
  }

  @override
  String juzWithVal(Object number) {
    return 'Juz $number';
  }

  @override
  String pageWithVal(Object number) {
    return 'Page $number';
  }

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get textMushaf => 'Text Mushaf';

  @override
  String get downloadAll => 'Download All';

  @override
  String get loadingPage => 'Loading page...';

  @override
  String pageNotAvailable(int number) {
    return 'Page $number not available';
  }

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get startDownload => 'Start Download';

  @override
  String get downloadMushafDesc =>
      '604 high-quality pages will be downloaded. Please ensure you are connected to the internet.';

  @override
  String get downloadCenter => 'Download Center (Offline Mode)';

  @override
  String get downloadCenterDesc =>
      'Download Mushaf content to read and listen without an internet connection.';

  @override
  String get mushafImagesPNG => 'Scanned Mushaf (PNG)';

  @override
  String get mushafImagesDesc => '604 high-quality pages (~80 MB)';

  @override
  String get quranText => 'Quran Text';

  @override
  String get quranTextDesc => 'All Surahs and Ayahs with basic info';

  @override
  String get downloadQuranTextConfirm =>
      'All Quran text will be downloaded for offline use.';

  @override
  String get confirmDownload => 'Confirm Download';

  @override
  String get readerSettings => 'Reader Settings';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get removeFromBookmarks => 'Remove from Bookmarks';

  @override
  String get addToBookmarks => 'Add to Bookmarks';

  @override
  String get removedFromBookmarks => 'Removed from Bookmarks';

  @override
  String get addedToBookmarks => 'Added to Bookmarks';

  @override
  String get markAsLastRead => 'Mark as Last Read';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get audio => 'Audio';

  @override
  String get selectTafsir => 'Select Tafsir';

  @override
  String tafsirWithVal(Object name) {
    return 'Tafsir: $name';
  }

  @override
  String errorLoadingTafsir(Object error) {
    return 'Error loading Tafsir: $error';
  }

  @override
  String get noTafsirAvailable => 'No tafsir available';

  @override
  String errorPlayingAudio(Object error) {
    return 'Error playing audio: $error';
  }

  @override
  String get quranRecitation => 'Quran Recitation';

  @override
  String get ayahBtn => 'Ayah';

  @override
  String get pause => 'Pause';

  @override
  String get playSurah => 'Play Surah';

  @override
  String get stop => 'Stop';

  @override
  String get compassNotSupported => 'Compass is not supported on this platform';

  @override
  String get useMobileForQibla =>
      'Please use the mobile app for Qibla direction';

  @override
  String qiblaDirectionWithVal(Object direction) {
    return 'Qibla Direction: $direction°';
  }

  @override
  String get rotatePhoneForQibla => 'Rotate phone until the arrow points up';

  @override
  String get previousSurah => 'Previous Surah';

  @override
  String get nextSurah => 'Next Surah';

  @override
  String get completionDoaa => 'Completion Doaa';

  @override
  String get completionDoaaArabic => 'دعاء ختم القرآن';

  @override
  String get cycleCompletionTitle => 'Quran Completion';

  @override
  String get cycleCompletionSubtitle =>
      'You\'ve completed reading the entire Quran';

  @override
  String get cycleCompletionReadDoaa => 'Read completion doaa';

  @override
  String get cycleCompletionReadDoaaDesc =>
      'Navigate to completion supplications';

  @override
  String get cycleCompletionRestart => 'Start new cycle';

  @override
  String get cycleCompletionRestartDesc => 'Reset to Surah Al-Fatihah (Ayah 1)';

  @override
  String get cycleCompletionStay => 'Stay here';

  @override
  String get cycleCompletionStayDesc => 'Keep current position at Surah An-Nas';

  @override
  String get downloadCenterBtn => 'Download Center';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String ayahsCount(String count) {
    return '$count Ayahs';
  }

  @override
  String get play => 'Play';

  @override
  String get pauseSurah => 'Pause';

  @override
  String get playSurahBtn => 'Play Surah';

  @override
  String get surahsTab => 'Surahs';

  @override
  String get juzTab => 'Juzs';

  @override
  String get hizbTab => 'Hizbs';

  @override
  String get bookmarksTab => 'Bookmarks';

  @override
  String get separators => 'Separators';

  @override
  String get none => 'None';

  @override
  String get page => 'Page';

  @override
  String get quarter => 'Quarter';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String ayahNumberWithVal(Object number) {
    return 'Ayah Number: $number';
  }

  @override
  String get useAddQadaToNewPrayers =>
      'Use \"Add Qada\" at the top to add new missed prayers';

  @override
  String get done => 'Done';

  @override
  String get resetSectionConfirm => 'Do you want to reset this section?';

  @override
  String get resetSuccessful => 'Reset successful';

  @override
  String get resetAzkarProgressConfirm =>
      'Are you sure you want to reset all azkar progress?';

  @override
  String get addAlarm => 'Add Alarm';

  @override
  String get title => 'Title';

  @override
  String get alarmAdded => 'Alarm added';

  @override
  String get readyToPlay => 'Ready to play';

  @override
  String surahWithAyah(Object ayah, Object surah) {
    return 'Surah $surah, Ayah $ayah';
  }

  @override
  String get hijriAdjustment => 'Hijri Adjustment';

  @override
  String get hijriAdjustmentDesc =>
      'Adjust the Hijri date if it differs from your local sighting (e.g., -1 or +1 day).';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get remainingTime => 'Remaining Time';

  @override
  String get hijriCalendar => 'Hijri';

  @override
  String get gregorianCalendar => 'Gregorian';

  @override
  String get muslimWorldLeague => 'Muslim World League';

  @override
  String get egyptianGeneralAuthority => 'Egyptian General Authority';

  @override
  String get universityOfIslamicSciencesKarachi =>
      'University of Islamic Sciences, Karachi';

  @override
  String get ummAlQuraUniversityMakkah => 'Umm al-Qura University, Makkah';

  @override
  String get dubai => 'Dubai';

  @override
  String get moonsightingCommittee => 'Moonsighting Committee';

  @override
  String get qatar => 'Qatar';

  @override
  String get kuwait => 'Kuwait';

  @override
  String get singapore => 'Singapore';

  @override
  String get turkey => 'Turkey';

  @override
  String get instituteOfGeophysicsTehran =>
      'Institute of Geophysics, University of Tehran';

  @override
  String get isnaNorthAmerica => 'ISNA (North America)';

  @override
  String get jumpConfirmTitle => 'Significant Jump';

  @override
  String jumpConfirmMessage(String start, String end, String pages) {
    return 'Did you really finish from $start to $end ($pages pages)?';
  }

  @override
  String get jumpDialogTitle => 'Significant Jump Detected';

  @override
  String get jumpFrom => 'Current position';

  @override
  String get jumpTo => 'You tapped';

  @override
  String jumpGapInfo(String gap, String pages) {
    return 'Gap: $gap ayahs ($pages pages)';
  }

  @override
  String get jumpWhatToDo => 'What would you like to do?';

  @override
  String get jumpOptionDismiss => 'Dismiss';

  @override
  String get jumpDismissDesc =>
      'Don\'t mark anything as read, keep your current progress unchanged';

  @override
  String get jumpOptionNewSession => 'Start new session';

  @override
  String jumpNewSessionDesc(String current, String newTotal) {
    return 'Mark only this ayah as read (+1 ayah, total today: $current → $newTotal)';
  }

  @override
  String get jumpOptionMarkAll => 'Mark all as read';

  @override
  String jumpMarkAllDesc(String gap, String pages) {
    return 'Mark ALL $gap ayahs ($pages pages) from your last position to here as read';
  }

  @override
  String jumpTotalToday(String count) {
    return 'Total today: $count ayahs';
  }

  @override
  String get goToPlayingAyah => 'Go to playing Ayah';

  @override
  String get repeatAyah => 'Repeat Ayah';

  @override
  String get dataBackup => 'Data & Backup';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get exportBackupDesc =>
      'Export your history and goals to a JSON file.';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importBackupDesc =>
      'Restore your data from a previously exported JSON file.';

  @override
  String get backupExportSuccess => 'Backup exported successfully';

  @override
  String get backupImportSuccess => 'Backup imported successfully';

  @override
  String get backupError => 'Backup error';

  @override
  String get importWarning =>
      'This will override your current data. Are you sure?';

  @override
  String get backupVersionError =>
      'Backup version is newer than app version. Please update the app.';

  @override
  String get offlineAudio => 'Offline Audio';

  @override
  String errorLoadingReciters(Object error) {
    return 'Error loading reciters: $error';
  }

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteAllDownloads => 'Delete All Downloads?';

  @override
  String deleteReciterConfirm(Object name) {
    return 'Are you sure you want to delete all downloaded audio for $name?';
  }

  @override
  String get manageOfflineAudio => 'Manage Offline Audio';

  @override
  String get downloadSurahsDesc =>
      'Download Surahs to listen without internet.';

  @override
  String get stopAll => 'Stop All';

  @override
  String get approx => 'Approx';

  @override
  String get deleteSurahAudio => 'Delete Surah Audio?';

  @override
  String deleteSurahConfirm(Object name) {
    return 'Are you sure you want to delete the downloaded audio for $name?';
  }

  @override
  String get quranAudio => 'Quran Audio';

  @override
  String get manageRecitersDesc =>
      'Manage and download reciters for offline playback';

  @override
  String get manageDownloads => 'Manage Downloads';

  @override
  String get downloadRecitersOffline =>
      'Download reciters for offline playback';

  @override
  String downloadingSurah(Object number) {
    return 'Downloading Surah $number';
  }

  @override
  String downloadingReciter(Object id) {
    return 'Downloading Reciter $id';
  }

  @override
  String get downloadComplete => 'Download complete';

  @override
  String filesCount(Object downloaded, Object total) {
    return '$downloaded / $total files';
  }

  @override
  String get downloadError => 'Download Error';

  @override
  String get downloadsChannelName => 'Downloads';

  @override
  String get downloadsChannelDesc => 'Ongoing file downloads';

  @override
  String get starting => 'Starting...';

  @override
  String get stopping => 'Stopping...';

  @override
  String get werdEditDialog => 'Edit Reading';

  @override
  String get werdTodayReading => 'Today\'s Reading';

  @override
  String get werdNoSessions => 'No reading sessions today';

  @override
  String werdSession(int number) {
    return 'Session $number';
  }

  @override
  String get werdFrom => 'From';

  @override
  String get werdTo => 'To';

  @override
  String get werdEditSegment => 'Edit Segment';

  @override
  String get werdAddRange => 'Add Reading Range';

  @override
  String werdRangePreview(
    String fromSurah,
    int fromAyah,
    String toSurah,
    int toAyah,
  ) {
    return 'From: $fromSurah $fromAyah\nTo: $toSurah $toAyah';
  }

  @override
  String werdWillAdd(int count) {
    return 'Will add: $count ayahs';
  }

  @override
  String get werdUpdate => 'Update';

  @override
  String get werdDelete => 'Delete';

  @override
  String get werdClose => 'Close';

  @override
  String get werdCancel => 'Cancel';

  @override
  String get werdAdd => 'Add';

  @override
  String get werdSame => 'same';

  @override
  String werdAyahs(int count) {
    return '$count ayahs';
  }

  @override
  String get werdRangeCorrected => 'Range automatically corrected';

  @override
  String get werdUndoTitle => 'Undo Last Read?';

  @override
  String werdUndoMessage(int count, String fromSurah, String toSurah) {
    return 'This will remove the last reading session ($count ayahs from $fromSurah to $toSurah)';
  }

  @override
  String get werdUndo => 'Undo';

  @override
  String get werdNothingToUndo => 'Nothing to undo';

  @override
  String get werdNoSessionToRemove => 'No reading session to remove';

  @override
  String get jumpToAyah => 'Jump to Ayah';

  @override
  String get quickSelect => 'Quick Select';

  @override
  String get go => 'Go';

  @override
  String get ayahs => 'Ayahs';

  @override
  String get scrollToTop => 'Scroll to Top';

  @override
  String get juz => 'Juz';

  @override
  String get theme => 'Theme';

  @override
  String get emeraldTheme => 'Emerald';

  @override
  String get parchmentTheme => 'Parchment';

  @override
  String get roseTheme => 'Rose';

  @override
  String get midnightTheme => 'Midnight';

  @override
  String get customTheme => 'Custom';

  @override
  String get pickPrimaryColor => 'Pick Primary Color';

  @override
  String get pickAccentColor => 'Pick Accent Color';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get applyTheme => 'Apply Theme';

  @override
  String get tapToCustomize => 'Tap to customize';

  @override
  String get werdHistory => 'Werd History';

  @override
  String get werdNoHistoryYet => 'No history yet';

  @override
  String get werdNoReadingThisMonth => 'No reading this month';

  @override
  String get werdStartReading => 'Start Reading';

  @override
  String get werdStartReadingDesc =>
      'Start reading Quran to track your progress here';

  @override
  String get werdDetails => 'Details';

  @override
  String get werdDays => 'days';

  @override
  String get werdMissed => 'Missed';

  @override
  String get werdCurrent => 'Current';

  @override
  String get werdMonthlySummary => 'Monthly Summary';

  @override
  String get werdAyahsLabel => 'Ayahs';

  @override
  String get werdPagesLabel => 'Pages';

  @override
  String get werdJuzLabel => 'Juz';

  @override
  String get werdDailyAvg => 'Daily Avg';

  @override
  String get werdSessionDetails => 'Session Details';

  @override
  String get werdSameAyah => 'Same ayah';

  @override
  String werdSessionNumber(int number) {
    return 'Session $number';
  }

  @override
  String get werdMinSuffix => ' min';

  @override
  String get werdOlderEntryNote =>
      'Session details not available for this day (older entry)';

  @override
  String get werdToday => 'Today';

  @override
  String werdSummaryRead(
    String ayahs,
    String pages,
    String startSurah,
    String startAyah,
    String endSurah,
    String endAyah,
  ) {
    return 'Read $ayahs ayahs ($pages pages) from $startSurah $startAyah to $endSurah $endAyah';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get prayerAndAzan => 'Prayer & Azan';

  @override
  String get azkarSection => 'Azkar';

  @override
  String get dataAndLocation => 'Data & Location';

  @override
  String get widgetThemeMode => 'Widget Theme';

  @override
  String get widgetThemeDark => 'Dark';

  @override
  String get widgetThemeLight => 'Light';

  @override
  String get widgetThemeFollowApp => 'Follow App';

  @override
  String showSavedThemes(Object count) {
    return 'Show saved themes ($count)';
  }

  @override
  String get hideSavedThemes => 'Hide saved themes';

  @override
  String get languageDesc => 'Switch between English and Arabic';

  @override
  String get widgetPreviewTitle => 'Widget Preview';

  @override
  String get prayerSchedule => 'Prayer Schedule';

  @override
  String get countdown => 'Countdown';

  @override
  String get widgetColorsIndependent =>
      'Widget Colors (Independent from App Theme)';

  @override
  String get widgetPrimaryColor => 'Primary Color';

  @override
  String get widgetAccentColor => 'Accent Color';

  @override
  String get widgetBackgroundColor => 'Background Color';

  @override
  String get widgetTextColor => 'Text Color';

  @override
  String get widgetSecondaryTextColor => 'Secondary Text Color';

  @override
  String get widgetThemeApplied => 'Widget theme applied!';

  @override
  String widgetThemeApplyFailed(String error) {
    return 'Failed to apply widget theme: $error';
  }

  @override
  String get applyToWidget => 'Apply to Widget';

  @override
  String pickColorTitle(String label) {
    return 'Pick $label Color';
  }

  @override
  String get presetColors => 'Preset Colors';

  @override
  String get customColor => 'Custom Color';

  @override
  String customColorTitle(String label) {
    return 'Custom $label';
  }

  @override
  String get hexColor => 'Hex Color';

  @override
  String get pickAColor => 'Pick a color:';

  @override
  String get widgetPreviewDate => 'Tuesday, Apr 14, 2026';

  @override
  String get widgetPreviewHijriDate => '26 Shawwal 1447';

  @override
  String get widgetPreviewCountdown => '3h 45m';

  @override
  String get widgetStartFromPreset => 'Start from a theme preset:';

  @override
  String get widgetCustomization => 'Color Customization';
}
