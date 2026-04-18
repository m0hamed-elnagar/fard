import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fard - Qada Tracker'**
  String get appTitle;

  /// No description provided for @dailyPrayers.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayers'**
  String get dailyPrayers;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fard'**
  String get appName;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Prayers'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Keep a record of your daily prayers and never miss a beat.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Manage Qada'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Easily track and complete your missed prayers over time.'**
  String get onboardingDesc2;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history for this month'**
  String get noHistory;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the record for {date}?'**
  String deleteConfirm(String date);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @missedCount.
  ///
  /// In en, this message translates to:
  /// **'Missed {count}'**
  String missedCount(int count);

  /// No description provided for @addQada.
  ///
  /// In en, this message translates to:
  /// **'Add Qada'**
  String get addQada;

  /// No description provided for @totalQada.
  ///
  /// In en, this message translates to:
  /// **'Total Qada'**
  String get totalQada;

  /// No description provided for @byCount.
  ///
  /// In en, this message translates to:
  /// **'By Count'**
  String get byCount;

  /// No description provided for @byTime.
  ///
  /// In en, this message translates to:
  /// **'By Time'**
  String get byTime;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period to calculate prayers'**
  String get selectPeriod;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'Days Count'**
  String get daysCount;

  /// No description provided for @prayersPerFard.
  ///
  /// In en, this message translates to:
  /// **'Prayers per fard'**
  String get prayersPerFard;

  /// No description provided for @missedDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed Days'**
  String get missedDaysTitle;

  /// No description provided for @missedDaysMessage.
  ///
  /// In en, this message translates to:
  /// **'It looks like you missed {count} days since your last record. Were you praying during this period? If not, they will be added to your remaining prayers.'**
  String missedDaysMessage(int count);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'I was praying'**
  String get skip;

  /// No description provided for @addAll.
  ///
  /// In en, this message translates to:
  /// **'Add to remaining'**
  String get addAll;

  /// No description provided for @saveSelection.
  ///
  /// In en, this message translates to:
  /// **'Save selection'**
  String get saveSelection;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @toggleDates.
  ///
  /// In en, this message translates to:
  /// **'Toggle dates you missed'**
  String get toggleDates;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @editQada.
  ///
  /// In en, this message translates to:
  /// **'Edit Qada'**
  String get editQada;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @duha.
  ///
  /// In en, this message translates to:
  /// **'Duha'**
  String get duha;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @locationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get locationSettings;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @prayerSettings.
  ///
  /// In en, this message translates to:
  /// **'Prayer Settings'**
  String get prayerSettings;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @madhab.
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get madhab;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @locationDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables precise calculation of prayer times based on your current coordinates.'**
  String get locationDesc;

  /// No description provided for @calculationMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the authority used in your region for calculating Fajr and Isha angles.'**
  String get calculationMethodDesc;

  /// No description provided for @madhabDesc.
  ///
  /// In en, this message translates to:
  /// **'Determines the calculation for Asr prayer time (Hanafi vs. other schools).'**
  String get madhabDesc;

  /// No description provided for @shafiMadhab.
  ///
  /// In en, this message translates to:
  /// **'Shafi, Maliki, Hanbali'**
  String get shafiMadhab;

  /// No description provided for @hanafiMadhab.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get hanafiMadhab;

  /// No description provided for @refreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get refreshLocation;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get locationNotSet;

  /// No description provided for @locationDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Disabled'**
  String get locationDisabledTitle;

  /// No description provided for @locationDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services (GPS) to calculate prayer times accurately.'**
  String get locationDisabledDesc;

  /// No description provided for @enableGPS.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get enableGPS;

  /// No description provided for @locationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Denied'**
  String get locationDeniedTitle;

  /// No description provided for @locationDeniedDesc.
  ///
  /// In en, this message translates to:
  /// **'This app needs location permission to calculate prayer times based on your city. Please grant permission to continue.'**
  String get locationDeniedDesc;

  /// No description provided for @locationDeniedForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationDeniedForeverTitle;

  /// No description provided for @locationDeniedForeverDesc.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it from app settings to use this feature.'**
  String get locationDeniedForeverDesc;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Open system settings to manage app notifications and permissions.'**
  String get notificationSettingsDesc;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @azkarSettings.
  ///
  /// In en, this message translates to:
  /// **'Azkar Settings'**
  String get azkarSettings;

  /// No description provided for @morningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Morning Azkar'**
  String get morningAzkar;

  /// No description provided for @eveningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Evening Azkar'**
  String get eveningAzkar;

  /// No description provided for @azkarSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure what time to show morning and evening Azkar reminders.'**
  String get azkarSettingsDesc;

  /// No description provided for @autoAzkarTimes.
  ///
  /// In en, this message translates to:
  /// **'Auto (Follow Prayer Times)'**
  String get autoAzkarTimes;

  /// No description provided for @autoAzkarTimesDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically set Azkar times based on Fajr and Asr prayers.'**
  String get autoAzkarTimesDesc;

  /// No description provided for @timeFor.
  ///
  /// In en, this message translates to:
  /// **'Time for'**
  String get timeFor;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @azkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkar;

  /// No description provided for @loadingAzkar.
  ///
  /// In en, this message translates to:
  /// **'Loading Azkar...'**
  String get loadingAzkar;

  /// No description provided for @errorLoadingAzkar.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Azkar'**
  String get errorLoadingAzkar;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @resetAllProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset All Progress'**
  String get resetAllProgress;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found in this category'**
  String get noItemsFound;

  /// No description provided for @resetItem.
  ///
  /// In en, this message translates to:
  /// **'Reset Item'**
  String get resetItem;

  /// No description provided for @prayerTab.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayerTab;

  /// No description provided for @azkarTab.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkarTab;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get noSearchResults;

  /// No description provided for @searchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search for a category...'**
  String get searchCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @azanSettings.
  ///
  /// In en, this message translates to:
  /// **'Azan & Reminder Settings'**
  String get azanSettings;

  /// No description provided for @azan.
  ///
  /// In en, this message translates to:
  /// **'Azan'**
  String get azan;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(int minutes);

  /// No description provided for @azanVoice.
  ///
  /// In en, this message translates to:
  /// **'Azan Voice'**
  String get azanVoice;

  /// No description provided for @enableAzan.
  ///
  /// In en, this message translates to:
  /// **'Enable Azan'**
  String get enableAzan;

  /// No description provided for @enableReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminder'**
  String get enableReminder;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @afterSalahAzkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar after Salah'**
  String get afterSalahAzkar;

  /// No description provided for @afterSalahAzkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminder to read azkar 15 minutes after azan'**
  String get afterSalahAzkarDesc;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @loadingQuran.
  ///
  /// In en, this message translates to:
  /// **'Loading Quran...'**
  String get loadingQuran;

  /// No description provided for @errorLoadingQuran.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Quran'**
  String get errorLoadingQuran;

  /// No description provided for @searchSurah.
  ///
  /// In en, this message translates to:
  /// **'Search for a Surah...'**
  String get searchSurah;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @quranTab.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTab;

  /// No description provided for @tasbihTab.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihTab;

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @selectDhikrCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Dhikr Category'**
  String get selectDhikrCategory;

  /// No description provided for @tasbihSettings.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Settings'**
  String get tasbihSettings;

  /// No description provided for @customTasbihTarget.
  ///
  /// In en, this message translates to:
  /// **'Custom Target'**
  String get customTasbihTarget;

  /// No description provided for @customTasbihTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Default: {count}'**
  String customTasbihTargetHint(int count);

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show Translation'**
  String get showTranslation;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show Transliteration'**
  String get showTransliteration;

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset Counter?'**
  String get resetCounter;

  /// No description provided for @resetProgressWarning.
  ///
  /// In en, this message translates to:
  /// **'This will reset your current progress to zero.'**
  String get resetProgressWarning;

  /// No description provided for @finishAndReset.
  ///
  /// In en, this message translates to:
  /// **'Finish & Reset'**
  String get finishAndReset;

  /// No description provided for @errorLoadingTasbih.
  ///
  /// In en, this message translates to:
  /// **'Error loading Tasbih data'**
  String get errorLoadingTasbih;

  /// No description provided for @rememberDua.
  ///
  /// In en, this message translates to:
  /// **'Remember this Dua'**
  String get rememberDua;

  /// No description provided for @changeDua.
  ///
  /// In en, this message translates to:
  /// **'Change Dua'**
  String get changeDua;

  /// No description provided for @duaSaved.
  ///
  /// In en, this message translates to:
  /// **'Dua saved for next time'**
  String get duaSaved;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @tasbih_after_salah_name.
  ///
  /// In en, this message translates to:
  /// **'Tasbih after Salah'**
  String get tasbih_after_salah_name;

  /// No description provided for @tasbih_after_salah_desc.
  ///
  /// In en, this message translates to:
  /// **'33x SubhanAllah, Alhamdulillah, Allahu Akbar + Dua'**
  String get tasbih_after_salah_desc;

  /// No description provided for @tasbih_fatimah_name.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Fatimah (Bedtime)'**
  String get tasbih_fatimah_name;

  /// No description provided for @tasbih_fatimah_desc.
  ///
  /// In en, this message translates to:
  /// **'33x SubhanAllah, 33x Alhamdulillah, 34x Allahu Akbar'**
  String get tasbih_fatimah_desc;

  /// No description provided for @four_foundations_name.
  ///
  /// In en, this message translates to:
  /// **'The Four Foundations'**
  String get four_foundations_name;

  /// No description provided for @four_foundations_desc.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah, Alhamdulillah, La ilaha illallah, Allahu Akbar'**
  String get four_foundations_desc;

  /// No description provided for @yunus_dhikr_name.
  ///
  /// In en, this message translates to:
  /// **'Dhikr of Prophet Yunus'**
  String get yunus_dhikr_name;

  /// No description provided for @yunus_dhikr_desc.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illa anta subhanaka...'**
  String get yunus_dhikr_desc;

  /// No description provided for @morning_evening_name.
  ///
  /// In en, this message translates to:
  /// **'Morning & Evening Adhkar'**
  String get morning_evening_name;

  /// No description provided for @morning_evening_desc.
  ///
  /// In en, this message translates to:
  /// **'Daily remembrances for morning and evening'**
  String get morning_evening_desc;

  /// No description provided for @istighfar_name.
  ///
  /// In en, this message translates to:
  /// **'Istighfar'**
  String get istighfar_name;

  /// No description provided for @istighfar_desc.
  ///
  /// In en, this message translates to:
  /// **'Seeking Allah\'s forgiveness'**
  String get istighfar_desc;

  /// No description provided for @salat_ibrahimiyyah_name.
  ///
  /// In en, this message translates to:
  /// **'Salat Ibrahimiyyah'**
  String get salat_ibrahimiyyah_name;

  /// No description provided for @salat_ibrahimiyyah_desc.
  ///
  /// In en, this message translates to:
  /// **'Salutations upon the Prophet (PBUH)'**
  String get salat_ibrahimiyyah_desc;

  /// No description provided for @tahlil_takbir_tahmid_name.
  ///
  /// In en, this message translates to:
  /// **'Tahlil, Takbir & Tahmid'**
  String get tahlil_takbir_tahmid_name;

  /// No description provided for @tahlil_takbir_tahmid_desc.
  ///
  /// In en, this message translates to:
  /// **'Fundamental declarations of faith'**
  String get tahlil_takbir_tahmid_desc;

  /// No description provided for @quran_adhkar_name.
  ///
  /// In en, this message translates to:
  /// **'Adhkar from Quran'**
  String get quran_adhkar_name;

  /// No description provided for @quran_adhkar_desc.
  ///
  /// In en, this message translates to:
  /// **'Supplications directly from the Quran'**
  String get quran_adhkar_desc;

  /// No description provided for @ruqyah_protection_name.
  ///
  /// In en, this message translates to:
  /// **'Ruqyah & Protection'**
  String get ruqyah_protection_name;

  /// No description provided for @ruqyah_protection_desc.
  ///
  /// In en, this message translates to:
  /// **'Supplications for protection from harm'**
  String get ruqyah_protection_desc;

  /// No description provided for @chooseCompletionDua.
  ///
  /// In en, this message translates to:
  /// **'Choose Completion Dua'**
  String get chooseCompletionDua;

  /// No description provided for @locationWarning.
  ///
  /// In en, this message translates to:
  /// **'Prayer times cannot be calculated without your location.'**
  String get locationWarning;

  /// No description provided for @givePermission.
  ///
  /// In en, this message translates to:
  /// **'Give Permission'**
  String get givePermission;

  /// No description provided for @afterSalaahAzkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar al-Salaah'**
  String get afterSalaahAzkar;

  /// No description provided for @minutesAfter.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes after'**
  String minutesAfter(int minutes);

  /// No description provided for @qadaTracker.
  ///
  /// In en, this message translates to:
  /// **'Missed Prayers Tracker'**
  String get qadaTracker;

  /// No description provided for @qadaTrackerDesc.
  ///
  /// In en, this message translates to:
  /// **'Track missed prayers (Qada) and set goals to complete them.'**
  String get qadaTrackerDesc;

  /// No description provided for @qadaOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Qada Tracking'**
  String get qadaOnboardingTitle;

  /// No description provided for @qadaOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Would you like to track your missed prayers (Qada) and set goals to complete them?'**
  String get qadaOnboardingDesc;

  /// No description provided for @enableQada.
  ///
  /// In en, this message translates to:
  /// **'Enable Qada Tracking'**
  String get enableQada;

  /// No description provided for @disableQada.
  ///
  /// In en, this message translates to:
  /// **'Disable for now'**
  String get disableQada;

  /// No description provided for @globalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global Notification Settings'**
  String get globalSettings;

  /// No description provided for @globalSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply these settings to all five prayers at once.'**
  String get globalSettingsDesc;

  /// No description provided for @azanNotifications.
  ///
  /// In en, this message translates to:
  /// **'Azan & Notifications'**
  String get azanNotifications;

  /// No description provided for @azanSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage azan voices, reminders, and after-salah azkar for all prayers.'**
  String get azanSettingsDesc;

  /// No description provided for @individualSettings.
  ///
  /// In en, this message translates to:
  /// **'Individual Prayer Settings'**
  String get individualSettings;

  /// No description provided for @createNewTheme.
  ///
  /// In en, this message translates to:
  /// **'Create New Theme'**
  String get createNewTheme;

  /// No description provided for @savedThemes.
  ///
  /// In en, this message translates to:
  /// **'Saved Themes'**
  String get savedThemes;

  /// No description provided for @editTheme.
  ///
  /// In en, this message translates to:
  /// **'Edit Theme'**
  String get editTheme;

  /// No description provided for @autoDerive.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoDerive;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @updateTheme.
  ///
  /// In en, this message translates to:
  /// **'Update Theme'**
  String get updateTheme;

  /// No description provided for @saveTheme.
  ///
  /// In en, this message translates to:
  /// **'Save Theme'**
  String get saveTheme;

  /// No description provided for @nameYourTheme.
  ///
  /// In en, this message translates to:
  /// **'Name Your Theme'**
  String get nameYourTheme;

  /// No description provided for @themeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Dark Gold'**
  String get themeNameHint;

  /// No description provided for @deleteTheme.
  ///
  /// In en, this message translates to:
  /// **'Delete Theme'**
  String get deleteTheme;

  /// No description provided for @deleteThemeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{themeName}\"? This cannot be undone.'**
  String deleteThemeConfirm(Object themeName);

  /// No description provided for @applyToAll.
  ///
  /// In en, this message translates to:
  /// **'Apply to all'**
  String get applyToAll;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General App Settings'**
  String get generalSettings;

  /// No description provided for @exactAlarmWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning: Azan may not work accurately'**
  String get exactAlarmWarningTitle;

  /// No description provided for @exactAlarmWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enable \"Exact Alarms\" from system settings to ensure Azan works on time.'**
  String get exactAlarmWarningDesc;

  /// No description provided for @editEachPrayer.
  ///
  /// In en, this message translates to:
  /// **'Edit each prayer'**
  String get editEachPrayer;

  /// No description provided for @noRemindersSet.
  ///
  /// In en, this message translates to:
  /// **'No reminders set'**
  String get noRemindersSet;

  /// No description provided for @azanDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to download Azan voice. Ensure the site is accessible or try another voice.'**
  String get azanDownloadError;

  /// No description provided for @testAzan.
  ///
  /// In en, this message translates to:
  /// **'Test Sound'**
  String get testAzan;

  /// No description provided for @testReminder.
  ///
  /// In en, this message translates to:
  /// **'Test Reminder'**
  String get testReminder;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @customTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom Title (Optional)'**
  String get customTitleOptional;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @lowBitrate.
  ///
  /// In en, this message translates to:
  /// **'Low (64k)'**
  String get lowBitrate;

  /// No description provided for @medBitrate.
  ///
  /// In en, this message translates to:
  /// **'Med (128k)'**
  String get medBitrate;

  /// No description provided for @highBitrate.
  ///
  /// In en, this message translates to:
  /// **'High (192k)'**
  String get highBitrate;

  /// No description provided for @defaultVal.
  ///
  /// In en, this message translates to:
  /// **'Phone Notification'**
  String get defaultVal;

  /// No description provided for @pagesDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All pages downloaded successfully'**
  String get pagesDownloadedSuccess;

  /// No description provided for @downloadMushafPages.
  ///
  /// In en, this message translates to:
  /// **'Download Mushaf Pages'**
  String get downloadMushafPages;

  /// No description provided for @cacheClearedReloading.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared and reloading'**
  String get cacheClearedReloading;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @quranReader.
  ///
  /// In en, this message translates to:
  /// **'Quran Reader'**
  String get quranReader;

  /// No description provided for @markAsLastReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marked as last read'**
  String get markAsLastReadSuccess;

  /// No description provided for @reciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// No description provided for @errorReadingCompass.
  ///
  /// In en, this message translates to:
  /// **'Error reading compass: {error}'**
  String errorReadingCompass(Object error);

  /// No description provided for @deviceNoSensors.
  ///
  /// In en, this message translates to:
  /// **'Device does not have sensors!'**
  String get deviceNoSensors;

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettings;

  /// No description provided for @audioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get audioQuality;

  /// No description provided for @selectReciter.
  ///
  /// In en, this message translates to:
  /// **'Select Reciter'**
  String get selectReciter;

  /// No description provided for @scannedMushaf.
  ///
  /// In en, this message translates to:
  /// **'Scanned Mushaf'**
  String get scannedMushaf;

  /// No description provided for @surahWithVal.
  ///
  /// In en, this message translates to:
  /// **'Surah {name}'**
  String surahWithVal(Object name);

  /// No description provided for @juzWithVal.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzWithVal(Object number);

  /// No description provided for @pageWithVal.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageWithVal(Object number);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @textMushaf.
  ///
  /// In en, this message translates to:
  /// **'Text Mushaf'**
  String get textMushaf;

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download All'**
  String get downloadAll;

  /// No description provided for @loadingPage.
  ///
  /// In en, this message translates to:
  /// **'Loading page...'**
  String get loadingPage;

  /// No description provided for @pageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Page {number} not available'**
  String pageNotAvailable(int number);

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @startDownload.
  ///
  /// In en, this message translates to:
  /// **'Start Download'**
  String get startDownload;

  /// No description provided for @downloadMushafDesc.
  ///
  /// In en, this message translates to:
  /// **'604 high-quality pages will be downloaded. Please ensure you are connected to the internet.'**
  String get downloadMushafDesc;

  /// No description provided for @downloadCenter.
  ///
  /// In en, this message translates to:
  /// **'Download Center (Offline Mode)'**
  String get downloadCenter;

  /// No description provided for @downloadCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Download Mushaf content to read and listen without an internet connection.'**
  String get downloadCenterDesc;

  /// No description provided for @mushafImagesPNG.
  ///
  /// In en, this message translates to:
  /// **'Scanned Mushaf (PNG)'**
  String get mushafImagesPNG;

  /// No description provided for @mushafImagesDesc.
  ///
  /// In en, this message translates to:
  /// **'604 high-quality pages (~80 MB)'**
  String get mushafImagesDesc;

  /// No description provided for @quranText.
  ///
  /// In en, this message translates to:
  /// **'Quran Text'**
  String get quranText;

  /// No description provided for @quranTextDesc.
  ///
  /// In en, this message translates to:
  /// **'All Surahs and Ayahs with basic info'**
  String get quranTextDesc;

  /// No description provided for @downloadQuranTextConfirm.
  ///
  /// In en, this message translates to:
  /// **'All Quran text will be downloaded for offline use.'**
  String get downloadQuranTextConfirm;

  /// No description provided for @confirmDownload.
  ///
  /// In en, this message translates to:
  /// **'Confirm Download'**
  String get confirmDownload;

  /// No description provided for @readerSettings.
  ///
  /// In en, this message translates to:
  /// **'Reader Settings'**
  String get readerSettings;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @removeFromBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Remove from Bookmarks'**
  String get removeFromBookmarks;

  /// No description provided for @addToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Add to Bookmarks'**
  String get addToBookmarks;

  /// No description provided for @removedFromBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Removed from Bookmarks'**
  String get removedFromBookmarks;

  /// No description provided for @addedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Added to Bookmarks'**
  String get addedToBookmarks;

  /// No description provided for @markAsLastRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Last Read'**
  String get markAsLastRead;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @selectTafsir.
  ///
  /// In en, this message translates to:
  /// **'Select Tafsir'**
  String get selectTafsir;

  /// No description provided for @tafsirWithVal.
  ///
  /// In en, this message translates to:
  /// **'Tafsir: {name}'**
  String tafsirWithVal(Object name);

  /// No description provided for @errorLoadingTafsir.
  ///
  /// In en, this message translates to:
  /// **'Error loading Tafsir: {error}'**
  String errorLoadingTafsir(Object error);

  /// No description provided for @noTafsirAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tafsir available'**
  String get noTafsirAvailable;

  /// No description provided for @errorPlayingAudio.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {error}'**
  String errorPlayingAudio(Object error);

  /// No description provided for @quranRecitation.
  ///
  /// In en, this message translates to:
  /// **'Quran Recitation'**
  String get quranRecitation;

  /// No description provided for @ayahBtn.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayahBtn;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playSurah.
  ///
  /// In en, this message translates to:
  /// **'Play Surah'**
  String get playSurah;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @compassNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Compass is not supported on this platform'**
  String get compassNotSupported;

  /// No description provided for @useMobileForQibla.
  ///
  /// In en, this message translates to:
  /// **'Please use the mobile app for Qibla direction'**
  String get useMobileForQibla;

  /// No description provided for @qiblaDirectionWithVal.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction: {direction}°'**
  String qiblaDirectionWithVal(Object direction);

  /// No description provided for @rotatePhoneForQibla.
  ///
  /// In en, this message translates to:
  /// **'Rotate phone until the arrow points up'**
  String get rotatePhoneForQibla;

  /// No description provided for @previousSurah.
  ///
  /// In en, this message translates to:
  /// **'Previous Surah'**
  String get previousSurah;

  /// No description provided for @nextSurah.
  ///
  /// In en, this message translates to:
  /// **'Next Surah'**
  String get nextSurah;

  /// No description provided for @completionDoaa.
  ///
  /// In en, this message translates to:
  /// **'Completion Doaa'**
  String get completionDoaa;

  /// No description provided for @completionDoaaArabic.
  ///
  /// In en, this message translates to:
  /// **'دعاء ختم القرآن'**
  String get completionDoaaArabic;

  /// No description provided for @cycleCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Completion'**
  String get cycleCompletionTitle;

  /// No description provided for @cycleCompletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed reading the entire Quran'**
  String get cycleCompletionSubtitle;

  /// No description provided for @cycleCompletionReadDoaa.
  ///
  /// In en, this message translates to:
  /// **'Read completion doaa'**
  String get cycleCompletionReadDoaa;

  /// No description provided for @cycleCompletionReadDoaaDesc.
  ///
  /// In en, this message translates to:
  /// **'Navigate to completion supplications'**
  String get cycleCompletionReadDoaaDesc;

  /// No description provided for @cycleCompletionRestart.
  ///
  /// In en, this message translates to:
  /// **'Start new cycle'**
  String get cycleCompletionRestart;

  /// No description provided for @cycleCompletionRestartDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset to Surah Al-Fatihah (Ayah 1)'**
  String get cycleCompletionRestartDesc;

  /// No description provided for @cycleCompletionStay.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get cycleCompletionStay;

  /// No description provided for @cycleCompletionStayDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep current position at Surah An-Nas'**
  String get cycleCompletionStayDesc;

  /// No description provided for @downloadCenterBtn.
  ///
  /// In en, this message translates to:
  /// **'Download Center'**
  String get downloadCenterBtn;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @ayahsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Ayahs'**
  String ayahsCount(String count);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pauseSurah.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseSurah;

  /// No description provided for @playSurahBtn.
  ///
  /// In en, this message translates to:
  /// **'Play Surah'**
  String get playSurahBtn;

  /// No description provided for @surahsTab.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahsTab;

  /// No description provided for @juzTab.
  ///
  /// In en, this message translates to:
  /// **'Juzs'**
  String get juzTab;

  /// No description provided for @hizbTab.
  ///
  /// In en, this message translates to:
  /// **'Hizbs'**
  String get hizbTab;

  /// No description provided for @bookmarksTab.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTab;

  /// No description provided for @separators.
  ///
  /// In en, this message translates to:
  /// **'Separators'**
  String get separators;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarter;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @ayahNumberWithVal.
  ///
  /// In en, this message translates to:
  /// **'Ayah Number: {number}'**
  String ayahNumberWithVal(Object number);

  /// No description provided for @useAddQadaToNewPrayers.
  ///
  /// In en, this message translates to:
  /// **'Use \"Add Qada\" at the top to add new missed prayers'**
  String get useAddQadaToNewPrayers;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @resetSectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset this section?'**
  String get resetSectionConfirm;

  /// No description provided for @resetSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Reset successful'**
  String get resetSuccessful;

  /// No description provided for @resetAzkarProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all azkar progress?'**
  String get resetAzkarProgressConfirm;

  /// No description provided for @addAlarm.
  ///
  /// In en, this message translates to:
  /// **'Add Alarm'**
  String get addAlarm;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @alarmAdded.
  ///
  /// In en, this message translates to:
  /// **'Alarm added'**
  String get alarmAdded;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get readyToPlay;

  /// No description provided for @surahWithAyah.
  ///
  /// In en, this message translates to:
  /// **'Surah {surah}, Ayah {ayah}'**
  String surahWithAyah(Object ayah, Object surah);

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri Adjustment'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust the Hijri date if it differs from your local sighting (e.g., -1 or +1 day).'**
  String get hijriAdjustmentDesc;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get remainingTime;

  /// No description provided for @hijriCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get hijriCalendar;

  /// No description provided for @gregorianCalendar.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get gregorianCalendar;

  /// No description provided for @muslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get muslimWorldLeague;

  /// No description provided for @egyptianGeneralAuthority.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get egyptianGeneralAuthority;

  /// No description provided for @universityOfIslamicSciencesKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get universityOfIslamicSciencesKarachi;

  /// No description provided for @ummAlQuraUniversityMakkah.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura University, Makkah'**
  String get ummAlQuraUniversityMakkah;

  /// No description provided for @dubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get dubai;

  /// No description provided for @moonsightingCommittee.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get moonsightingCommittee;

  /// No description provided for @qatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get qatar;

  /// No description provided for @kuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get kuwait;

  /// No description provided for @singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get singapore;

  /// No description provided for @turkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get turkey;

  /// No description provided for @instituteOfGeophysicsTehran.
  ///
  /// In en, this message translates to:
  /// **'Institute of Geophysics, University of Tehran'**
  String get instituteOfGeophysicsTehran;

  /// No description provided for @isnaNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get isnaNorthAmerica;

  /// No description provided for @jumpConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Significant Jump'**
  String get jumpConfirmTitle;

  /// No description provided for @jumpConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Did you really finish from {start} to {end} ({pages} pages)?'**
  String jumpConfirmMessage(String start, String end, String pages);

  /// No description provided for @jumpDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Significant Jump Detected'**
  String get jumpDialogTitle;

  /// No description provided for @jumpFrom.
  ///
  /// In en, this message translates to:
  /// **'Current position'**
  String get jumpFrom;

  /// No description provided for @jumpTo.
  ///
  /// In en, this message translates to:
  /// **'You tapped'**
  String get jumpTo;

  /// No description provided for @jumpGapInfo.
  ///
  /// In en, this message translates to:
  /// **'Gap: {gap} ayahs ({pages} pages)'**
  String jumpGapInfo(String gap, String pages);

  /// No description provided for @jumpWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get jumpWhatToDo;

  /// No description provided for @jumpOptionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get jumpOptionDismiss;

  /// No description provided for @jumpDismissDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t mark anything as read, keep your current progress unchanged'**
  String get jumpDismissDesc;

  /// No description provided for @jumpOptionNewSession.
  ///
  /// In en, this message translates to:
  /// **'Start new session'**
  String get jumpOptionNewSession;

  /// No description provided for @jumpNewSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark only this ayah as read (+1 ayah, total today: {current} → {newTotal})'**
  String jumpNewSessionDesc(String current, String newTotal);

  /// No description provided for @jumpOptionMarkAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get jumpOptionMarkAll;

  /// No description provided for @jumpMarkAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark ALL {gap} ayahs ({pages} pages) from your last position to here as read'**
  String jumpMarkAllDesc(String gap, String pages);

  /// No description provided for @jumpTotalToday.
  ///
  /// In en, this message translates to:
  /// **'Total today: {count} ayahs'**
  String jumpTotalToday(String count);

  /// No description provided for @goToPlayingAyah.
  ///
  /// In en, this message translates to:
  /// **'Go to playing Ayah'**
  String get goToPlayingAyah;

  /// No description provided for @repeatAyah.
  ///
  /// In en, this message translates to:
  /// **'Repeat Ayah'**
  String get repeatAyah;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get dataBackup;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @exportBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your history and goals to a JSON file.'**
  String get exportBackupDesc;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @importBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore your data from a previously exported JSON file.'**
  String get importBackupDesc;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully'**
  String get backupImportSuccess;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup error'**
  String get backupError;

  /// No description provided for @importWarning.
  ///
  /// In en, this message translates to:
  /// **'This will override your current data. Are you sure?'**
  String get importWarning;

  /// No description provided for @backupVersionError.
  ///
  /// In en, this message translates to:
  /// **'Backup version is newer than app version. Please update the app.'**
  String get backupVersionError;

  /// No description provided for @offlineAudio.
  ///
  /// In en, this message translates to:
  /// **'Offline Audio'**
  String get offlineAudio;

  /// No description provided for @errorLoadingReciters.
  ///
  /// In en, this message translates to:
  /// **'Error loading reciters: {error}'**
  String errorLoadingReciters(Object error);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteAllDownloads.
  ///
  /// In en, this message translates to:
  /// **'Delete All Downloads?'**
  String get deleteAllDownloads;

  /// No description provided for @deleteReciterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all downloaded audio for {name}?'**
  String deleteReciterConfirm(Object name);

  /// No description provided for @manageOfflineAudio.
  ///
  /// In en, this message translates to:
  /// **'Manage Offline Audio'**
  String get manageOfflineAudio;

  /// No description provided for @downloadSurahsDesc.
  ///
  /// In en, this message translates to:
  /// **'Download Surahs to listen without internet.'**
  String get downloadSurahsDesc;

  /// No description provided for @stopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get stopAll;

  /// No description provided for @approx.
  ///
  /// In en, this message translates to:
  /// **'Approx'**
  String get approx;

  /// No description provided for @deleteSurahAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete Surah Audio?'**
  String get deleteSurahAudio;

  /// No description provided for @deleteSurahConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the downloaded audio for {name}?'**
  String deleteSurahConfirm(Object name);

  /// No description provided for @quranAudio.
  ///
  /// In en, this message translates to:
  /// **'Quran Audio'**
  String get quranAudio;

  /// No description provided for @manageRecitersDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage and download reciters for offline playback'**
  String get manageRecitersDesc;

  /// No description provided for @manageDownloads.
  ///
  /// In en, this message translates to:
  /// **'Manage Downloads'**
  String get manageDownloads;

  /// No description provided for @downloadRecitersOffline.
  ///
  /// In en, this message translates to:
  /// **'Download reciters for offline playback'**
  String get downloadRecitersOffline;

  /// No description provided for @downloadingSurah.
  ///
  /// In en, this message translates to:
  /// **'Downloading Surah {number}'**
  String downloadingSurah(Object number);

  /// No description provided for @downloadingReciter.
  ///
  /// In en, this message translates to:
  /// **'Downloading Reciter {id}'**
  String downloadingReciter(Object id);

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @filesCount.
  ///
  /// In en, this message translates to:
  /// **'{downloaded} / {total} files'**
  String filesCount(Object downloaded, Object total);

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download Error'**
  String get downloadError;

  /// No description provided for @downloadsChannelName.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsChannelName;

  /// No description provided for @downloadsChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Ongoing file downloads'**
  String get downloadsChannelDesc;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping...'**
  String get stopping;

  /// No description provided for @werdEditDialog.
  ///
  /// In en, this message translates to:
  /// **'Edit Reading'**
  String get werdEditDialog;

  /// No description provided for @werdTodayReading.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reading'**
  String get werdTodayReading;

  /// No description provided for @werdNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No reading sessions today'**
  String get werdNoSessions;

  /// No description provided for @werdSession.
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String werdSession(int number);

  /// No description provided for @werdFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get werdFrom;

  /// No description provided for @werdTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get werdTo;

  /// No description provided for @werdEditSegment.
  ///
  /// In en, this message translates to:
  /// **'Edit Segment'**
  String get werdEditSegment;

  /// No description provided for @werdAddRange.
  ///
  /// In en, this message translates to:
  /// **'Add Reading Range'**
  String get werdAddRange;

  /// No description provided for @werdRangePreview.
  ///
  /// In en, this message translates to:
  /// **'From: {fromSurah} {fromAyah}\nTo: {toSurah} {toAyah}'**
  String werdRangePreview(
    String fromSurah,
    int fromAyah,
    String toSurah,
    int toAyah,
  );

  /// No description provided for @werdWillAdd.
  ///
  /// In en, this message translates to:
  /// **'Will add: {count} ayahs'**
  String werdWillAdd(int count);

  /// No description provided for @werdUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get werdUpdate;

  /// No description provided for @werdDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get werdDelete;

  /// No description provided for @werdClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get werdClose;

  /// No description provided for @werdCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get werdCancel;

  /// No description provided for @werdAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get werdAdd;

  /// No description provided for @werdSame.
  ///
  /// In en, this message translates to:
  /// **'same'**
  String get werdSame;

  /// No description provided for @werdAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String werdAyahs(int count);

  /// No description provided for @werdRangeCorrected.
  ///
  /// In en, this message translates to:
  /// **'Range automatically corrected'**
  String get werdRangeCorrected;

  /// No description provided for @werdUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo Last Read?'**
  String get werdUndoTitle;

  /// No description provided for @werdUndoMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the last reading session ({count} ayahs from {fromSurah} to {toSurah})'**
  String werdUndoMessage(int count, String fromSurah, String toSurah);

  /// No description provided for @werdUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get werdUndo;

  /// No description provided for @werdNothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo'**
  String get werdNothingToUndo;

  /// No description provided for @werdNoSessionToRemove.
  ///
  /// In en, this message translates to:
  /// **'No reading session to remove'**
  String get werdNoSessionToRemove;

  /// No description provided for @jumpToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jump to Ayah'**
  String get jumpToAyah;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahs;

  /// No description provided for @scrollToTop.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get scrollToTop;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @emeraldTheme.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get emeraldTheme;

  /// No description provided for @parchmentTheme.
  ///
  /// In en, this message translates to:
  /// **'Parchment'**
  String get parchmentTheme;

  /// No description provided for @roseTheme.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get roseTheme;

  /// No description provided for @midnightTheme.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnightTheme;

  /// No description provided for @customTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customTheme;

  /// No description provided for @pickPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Pick Primary Color'**
  String get pickPrimaryColor;

  /// No description provided for @pickAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Pick Accent Color'**
  String get pickAccentColor;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @applyTheme.
  ///
  /// In en, this message translates to:
  /// **'Apply Theme'**
  String get applyTheme;

  /// No description provided for @tapToCustomize.
  ///
  /// In en, this message translates to:
  /// **'Tap to customize'**
  String get tapToCustomize;

  /// No description provided for @werdHistory.
  ///
  /// In en, this message translates to:
  /// **'Werd History'**
  String get werdHistory;

  /// No description provided for @werdNoHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get werdNoHistoryYet;

  /// No description provided for @werdNoReadingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No reading this month'**
  String get werdNoReadingThisMonth;

  /// No description provided for @werdStartReading.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get werdStartReading;

  /// No description provided for @werdStartReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Start reading Quran to track your progress here'**
  String get werdStartReadingDesc;

  /// No description provided for @werdDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get werdDetails;

  /// No description provided for @werdDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get werdDays;

  /// No description provided for @werdMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get werdMissed;

  /// No description provided for @werdCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get werdCurrent;

  /// No description provided for @werdMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get werdMonthlySummary;

  /// No description provided for @werdAyahsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get werdAyahsLabel;

  /// No description provided for @werdPagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get werdPagesLabel;

  /// No description provided for @werdJuzLabel.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get werdJuzLabel;

  /// No description provided for @werdDailyAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily Avg'**
  String get werdDailyAvg;

  /// No description provided for @werdSessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get werdSessionDetails;

  /// No description provided for @werdSameAyah.
  ///
  /// In en, this message translates to:
  /// **'Same ayah'**
  String get werdSameAyah;

  /// No description provided for @werdSessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String werdSessionNumber(int number);

  /// No description provided for @werdMinSuffix.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get werdMinSuffix;

  /// No description provided for @werdOlderEntryNote.
  ///
  /// In en, this message translates to:
  /// **'Session details not available for this day (older entry)'**
  String get werdOlderEntryNote;

  /// No description provided for @werdToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get werdToday;

  /// No description provided for @werdSummaryRead.
  ///
  /// In en, this message translates to:
  /// **'Read {ayahs} ayahs ({pages} pages) from {startSurah} {startAyah} to {endSurah} {endAyah}'**
  String werdSummaryRead(
    String ayahs,
    String pages,
    String startSurah,
    String startAyah,
    String endSurah,
    String endAyah,
  );

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @prayerAndAzan.
  ///
  /// In en, this message translates to:
  /// **'Prayer & Azan'**
  String get prayerAndAzan;

  /// No description provided for @azkarSection.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkarSection;

  /// No description provided for @dataAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Data & Location'**
  String get dataAndLocation;

  /// No description provided for @widgetThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Widget Theme'**
  String get widgetThemeMode;

  /// No description provided for @widgetThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get widgetThemeDark;

  /// No description provided for @widgetThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get widgetThemeLight;

  /// No description provided for @widgetThemeFollowApp.
  ///
  /// In en, this message translates to:
  /// **'Follow App'**
  String get widgetThemeFollowApp;

  /// No description provided for @showSavedThemes.
  ///
  /// In en, this message translates to:
  /// **'Show saved themes ({count})'**
  String showSavedThemes(Object count);

  /// No description provided for @hideSavedThemes.
  ///
  /// In en, this message translates to:
  /// **'Hide saved themes'**
  String get hideSavedThemes;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between English and Arabic'**
  String get languageDesc;

  /// No description provided for @widgetPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget Preview'**
  String get widgetPreviewTitle;

  /// No description provided for @prayerSchedule.
  ///
  /// In en, this message translates to:
  /// **'Prayer Schedule'**
  String get prayerSchedule;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @widgetColorsIndependent.
  ///
  /// In en, this message translates to:
  /// **'Widget Colors (Independent from App Theme)'**
  String get widgetColorsIndependent;

  /// No description provided for @widgetPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get widgetPrimaryColor;

  /// No description provided for @widgetAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get widgetAccentColor;

  /// No description provided for @widgetBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get widgetBackgroundColor;

  /// No description provided for @widgetTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get widgetTextColor;

  /// No description provided for @widgetSecondaryTextColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Text Color'**
  String get widgetSecondaryTextColor;

  /// No description provided for @widgetThemeApplied.
  ///
  /// In en, this message translates to:
  /// **'Widget theme applied!'**
  String get widgetThemeApplied;

  /// No description provided for @widgetThemeApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply widget theme: {error}'**
  String widgetThemeApplyFailed(String error);

  /// No description provided for @applyToWidget.
  ///
  /// In en, this message translates to:
  /// **'Apply to Widget'**
  String get applyToWidget;

  /// No description provided for @pickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick {label} Color'**
  String pickColorTitle(String label);

  /// No description provided for @presetColors.
  ///
  /// In en, this message translates to:
  /// **'Preset Colors'**
  String get presetColors;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @customColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom {label}'**
  String customColorTitle(String label);

  /// No description provided for @hexColor.
  ///
  /// In en, this message translates to:
  /// **'Hex Color'**
  String get hexColor;

  /// No description provided for @pickAColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color:'**
  String get pickAColor;

  /// No description provided for @widgetPreviewDate.
  ///
  /// In en, this message translates to:
  /// **'Tuesday, Apr 14, 2026'**
  String get widgetPreviewDate;

  /// No description provided for @widgetPreviewHijriDate.
  ///
  /// In en, this message translates to:
  /// **'26 Shawwal 1447'**
  String get widgetPreviewHijriDate;

  /// No description provided for @widgetPreviewCountdown.
  ///
  /// In en, this message translates to:
  /// **'3h 45m'**
  String get widgetPreviewCountdown;

  /// No description provided for @widgetStartFromPreset.
  ///
  /// In en, this message translates to:
  /// **'Start from a theme preset:'**
  String get widgetStartFromPreset;

  /// No description provided for @widgetCustomization.
  ///
  /// In en, this message translates to:
  /// **'Color Customization'**
  String get widgetCustomization;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
