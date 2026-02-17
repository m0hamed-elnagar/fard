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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

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
