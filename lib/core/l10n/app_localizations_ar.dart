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
  String get totalQada => 'إجمالي القضاء';

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
  String get noCategoriesFound => 'لم يتم العور على فئات';

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

  @override
  String get qibla => 'القبلة';

  @override
  String get afterSalahAzkar => 'الأذكار بعد الصلاة';

  @override
  String get afterSalahAzkarDesc =>
      'تنبيه لقراءة الأذكار بعد 15 دقيقة من الأذان';

  @override
  String get quran => 'القرآن الكريم';

  @override
  String get loadingQuran => 'جاري تحميل القرآن...';

  @override
  String get errorLoadingQuran => 'خطأ في تحميل القرآن';

  @override
  String get searchSurah => 'البحث عن سورة...';

  @override
  String get ayah => 'آية';

  @override
  String get surah => 'سورة';

  @override
  String get quranTab => 'القرآن';

  @override
  String get tasbihTab => 'تسبيح';

  @override
  String get tasbih => 'المسبحة';

  @override
  String get selectDhikrCategory => 'اختر فئة الذكر';

  @override
  String get tasbihSettings => 'إعدادات المسبحة';

  @override
  String get customTasbihTarget => 'هدف مخصص';

  @override
  String customTasbihTargetHint(int count) {
    return 'الافتراضي: $count';
  }

  @override
  String get hapticFeedback => 'الاهتزاز عند اللمس';

  @override
  String get showTranslation => 'إظهار الترجمة';

  @override
  String get showTransliteration => 'إظهار النطق';

  @override
  String get resetCounter => 'إعادة تعيين العداد؟';

  @override
  String get resetProgressWarning =>
      'سيؤدي هذا إلى إعادة ضبط تقدمك الحالي إلى الصفر.';

  @override
  String get finishAndReset => 'إنهاء وإعادة تعيين';

  @override
  String get errorLoadingTasbih => 'خطأ في تحميل بيانات المسبحة';

  @override
  String get rememberDua => 'تذكر هذا الدعاء';

  @override
  String get changeDua => 'تغيير الدعاء';

  @override
  String get duaSaved => 'تم حفظ الدعاء للمرات القادمة';

  @override
  String get finish => 'إنهاء';

  @override
  String get tasbih_after_salah_name => 'الأذكار بعد الصلاة';

  @override
  String get tasbih_after_salah_desc =>
      '33 مرة: سبحان الله، الحمد لله، الله أكبر + الدعاء';

  @override
  String get tasbih_fatimah_name => 'تسبيح الزهراء (عند النوم)';

  @override
  String get tasbih_fatimah_desc =>
      '33 مرة: سبحان الله، الحمد لله، و34 مرة: الله أكبر';

  @override
  String get four_foundations_name => 'الباقيات الصالحات';

  @override
  String get four_foundations_desc =>
      'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر';

  @override
  String get yunus_dhikr_name => 'دعاء ذي النون';

  @override
  String get yunus_dhikr_desc => 'لا إله إلا أنت سبحانك إني كنت من الظالمين';

  @override
  String get morning_evening_name => 'أذكار الصباح والمساء';

  @override
  String get morning_evening_desc => 'الأذكار اليومية للمسلم';

  @override
  String get istighfar_name => 'الاستغفار';

  @override
  String get istighfar_desc => 'طلب المغفرة من الله عز وجل';

  @override
  String get salat_ibrahimiyyah_name => 'الصلاة الإبراهيمية';

  @override
  String get salat_ibrahimiyyah_desc => 'الصلاة على النبي صلى الله عليه وسلم';

  @override
  String get tahlil_takbir_tahmid_name => 'التهليل والتكبير والتحميد';

  @override
  String get tahlil_takbir_tahmid_desc => 'إعلان التوحيد والتمجيد لله';

  @override
  String get quran_adhkar_name => 'أذكار من القرآن الكريم';

  @override
  String get quran_adhkar_desc => 'أدعية من كتاب الله عز وجل';

  @override
  String get ruqyah_protection_name => 'الرقية والتحصين';

  @override
  String get ruqyah_protection_desc => 'أدعية الحماية والتحصين من الشرور';

  @override
  String get chooseCompletionDua => 'اختر دعاء الختام';

  @override
  String get locationWarning =>
      'لا يمكن معرفة مواقيت الصلاة بدون تحديد الموقع.';

  @override
  String get givePermission => 'تفعيل الموقع';

  @override
  String get afterSalaahAzkar => 'أذكار بعد الصلاة';

  @override
  String minutesAfter(int minutes) {
    return 'بعد $minutes دقائق';
  }

  @override
  String get qadaTracker => 'تتبع الصلوات الفائتة (القضاء)';

  @override
  String get qadaTrackerDesc =>
      'تتبع الصلوات التي فاتتك وحدد أهدافاً لإتمامها.';

  @override
  String get qadaOnboardingTitle => 'تتبع القضاء';

  @override
  String get qadaOnboardingDesc =>
      'هل تود تتبع صلواتك الفائتة (القضاء) وتحديد أهداف لإتمامها؟';

  @override
  String get enableQada => 'تفعيل تتبع القضاء';

  @override
  String get disableQada => 'تعطيل الآن';

  @override
  String get globalSettings => 'إعدادات التنبيهات للكل';

  @override
  String get globalSettingsDesc =>
      'تطبيق هذه الإعدادات على جميع الصلوات الخمس معاً.';

  @override
  String get individualSettings => 'إعدادات كل صلاة على حدة';

  @override
  String get applyToAll => 'تطبيق على الكل';

  @override
  String get generalSettings => 'إعدادات التطبيق العامة';
}
