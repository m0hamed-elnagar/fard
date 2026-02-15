// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فرض - Qada Tracker';

  @override
  String get dailyPrayers => 'صلوات اليوم';

  @override
  String get remaining => 'المتبقي';

  @override
  String get appName => 'فرض';

  @override
  String get errorOccurred => 'حدث خطأ ما';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get onboardingTitle1 => 'تتبع صلواتك';

  @override
  String get onboardingDesc1 => 'احتفظ بسجل لصلواتك اليومية ولا تفوت أي صلاة.';

  @override
  String get onboardingTitle2 => 'إدارة القضاء';

  @override
  String get onboardingDesc2 =>
      'تتبع وأكمل صلواتك الفائتة بسهولة مع مرور الوقت.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get helloWorld => 'أهلاً بالعالم!';

  @override
  String get calendar => 'التقويم';

  @override
  String get history => 'سجل الشهر';

  @override
  String get noHistory => 'لا يوجد سجل لهذا الشهر';

  @override
  String get deleteRecord => 'حذف السجل';

  @override
  String deleteConfirm(String date) {
    return 'هل أنت متأكد من حذف سجل يوم $date؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String missedCount(int count) {
    return 'فاتت $count';
  }

  @override
  String get addQada => 'إضافة قضاء';

  @override
  String get byCount => 'بالعدد';

  @override
  String get byTime => 'بالوقت';

  @override
  String get add => 'إضافة';

  @override
  String get selectPeriod => 'حدد الفترة لحساب عدد الصلوات';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get selectDate => 'اختر تاريخ';

  @override
  String get daysCount => 'عدد الأيام';

  @override
  String get prayersPerFard => 'صلاة لكل فرض';

  @override
  String get missedDaysTitle => 'أيام فائتة';

  @override
  String missedDaysMessage(int count) {
    return 'يبدو أنك فوت $count أيام منذ آخر سجل. هل كنت تصلي خلال هذه الفترة؟ إذا لم تكن كذلك، فسيتم إضافتها إلى صلواتك المتبقية.';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get skip => 'كنت أصلي';

  @override
  String get addAll => 'إضافة للمتبقي';

  @override
  String get edit => 'تعديل';

  @override
  String get update => 'تحديث';

  @override
  String get editQada => 'تعديل القضاء';

  @override
  String get next => 'التالي';

  @override
  String get fajr => 'فجر';

  @override
  String get dhuhr => 'ظهر';

  @override
  String get asr => 'عصر';

  @override
  String get maghrib => 'مغرب';

  @override
  String get isha => 'عشاء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get locationSettings => 'إعدادات الموقع';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get prayerSettings => 'إعدادات الصلاة';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get madhab => 'المذهب';

  @override
  String get language => 'اللغة';

  @override
  String get locationDesc =>
      'تفعيل الحساب الدقيق لمواقيت الصلاة بناءً على إحداثيات موقعك الحالي.';

  @override
  String get calculationMethodDesc =>
      'اختر الجهة المعتمدة في منطقتك لحساب زوايا الفجر والعشاء.';

  @override
  String get madhabDesc =>
      'يحدد طريقة حساب وقت صلاة العصر (الحنفي مقابل المذاهب الأخرى).';

  @override
  String get shafiMadhab => 'شافعي، مالكي، حنبلي';

  @override
  String get hanafiMadhab => 'حنفي';

  @override
  String get refreshLocation => 'تحديث الموقع';

  @override
  String get locationNotSet => 'الموقع غير محدد';

  @override
  String get azkarSettings => 'إعدادات الأذكار';

  @override
  String get morningAzkar => 'أذكار الصباح';

  @override
  String get eveningAzkar => 'أذكار المساء';

  @override
  String get azkarSettingsDesc =>
      'قم بتكوين الوقت المناسب لعرض تذكيرات أذكار الصباح والمساء.';

  @override
  String get autoAzkarTimes => 'تلقائي (حسب مواقيت الصلاة)';

  @override
  String get autoAzkarTimesDesc =>
      'تحديد مواعيد الأذكار تلقائياً بناءً على صلاتي الفجر والعصر.';

  @override
  String get timeFor => 'حان وقت';

  @override
  String get recommended => 'مقترح';

  @override
  String get azkar => 'الأذكار';

  @override
  String get loadingAzkar => 'جاري تحميل الأذكار...';

  @override
  String get errorLoadingAzkar => 'خطأ في تحميل الأذكار';

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';

  @override
  String get refreshData => 'تحديث البيانات';

  @override
  String get resetAllProgress => 'إعادة تعيين التقدم';

  @override
  String get noItemsFound => 'لم يتم العثور على عناصر في هذه الفئة';

  @override
  String get resetItem => 'إعادة تعيين العنصر';

  @override
  String get prayerTab => 'الصلاة';

  @override
  String get azkarTab => 'الأذكار';

  @override
  String get search => 'بحث...';

  @override
  String get noSearchResults => 'لم يتم العثور على نتائج للبحث';

  @override
  String get searchCategory => 'ابحث عن فئة...';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get azanSettings => 'إعدادات الأذان والتنبيهات';

  @override
  String get azan => 'الأذان';

  @override
  String get reminder => 'التنبيه';

  @override
  String minutesBefore(int minutes) {
    return 'قبل $minutes دقائق';
  }

  @override
  String get azanVoice => 'صوت الأذان';

  @override
  String get enableAzan => 'تفعيل الأذان';

  @override
  String get enableReminder => 'تفعيل التنبيه';
}
