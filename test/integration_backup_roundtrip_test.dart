import 'dart:convert';
import 'dart:ui';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:fard/features/tasbih/domain/tasbih_models.dart';
import 'package:fard/features/azkar/data/azkar_source.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWerdRepository implements WerdRepository {
  List<WerdGoal> goals = [];
  List<WerdProgress> progress = [];

  @override
  Future<Result<List<WerdGoal>>> getAllGoals() async => Result.success(goals);

  @override
  Future<Result<List<WerdProgress>>> getAllProgress() async =>
      Result.success(progress);

  @override
  Future<Result<void>> importGoals(List<WerdGoal> goals) async {
    this.goals = List.from(goals);
    return Result.success(null);
  }

  @override
  Future<Result<void>> importProgress(List<WerdProgress> progress) async {
    this.progress = List.from(progress);
    return Result.success(null);
  }

  @override
  Future<Result<WerdGoal?>> getGoal({String id = 'default'}) async =>
      Result.success(null);
  @override
  Future<Result<void>> setGoal(WerdGoal goal) async => Result.success(null);
  @override
  Future<Result<WerdProgress>> getProgress({String goalId = 'default'}) async =>
      throw UnimplementedError();
  @override
  Stream<Result<WerdProgress>> watchProgress({String goalId = 'default'}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> updateProgress(WerdProgress progress) async =>
      Result.success(null);
  @override
  void dispose() {}
}

class FakePrayerRepo implements PrayerRepo {
  List<DailyRecord> db = [];

  @override
  Future<List<DailyRecord>> loadAllRecords() async => db;

  @override
  Future<void> importAllRecords(List<DailyRecord> records) async {
    db = List.from(records);
  }

  @override
  Future<void> saveToday(DailyRecord record) async {}
  @override
  Future<void> deleteRecord(DateTime date) async {}
  @override
  Future<DailyRecord?> loadRecord(DateTime date) async => null;
  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async => {};
  @override
  Future<Map<Salaah, int>> calculateRemaining(
    DateTime from,
    DateTime to,
  ) async => {};
  @override
  Future<DailyRecord?> loadLastSavedRecord() async => null;
  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async => null;
}

class FakeSettingsRepository implements SettingsRepository {
  Map<String, dynamic> settings = {};

  @override
  Map<String, dynamic> getAllSettings() => settings;

  @override
  Future<void> importSettings(Map<String, dynamic> settings) async {
    this.settings = Map.from(settings);
  }

  @override
  Locale get locale => const Locale('ar');
  @override
  double? get latitude => null;
  @override
  double? get longitude => null;
  @override
  String? get cityName => null;
  @override
  String get calculationMethod => 'muslim_league';
  @override
  String get madhab => 'shafi';
  @override
  String get morningAzkarTime => '05:00';
  @override
  String get eveningAzkarTime => '18:00';
  @override
  bool get isAfterSalahAzkarEnabled => false;
  @override
  List<SalaahSettings> get salaahSettings => [];
  @override
  List<AzkarReminder> get reminders => [];
  @override
  bool get isQadaEnabled => true;
  @override
  int get hijriAdjustment => 0;
  @override
  String get themePresetId => 'emerald';
  @override
  Map<String, String>? get customThemeColors => null;
  @override
  List<CustomTheme> get savedCustomThemes => [];
  @override
  String? get activeCustomThemeId => null;
  @override
  AudioQuality get audioQuality => AudioQuality.low64;
  @override
  bool get isAudioPlayerExpanded => false;
  @override
  bool get isSalahReminderEnabled => false;
  @override
  int get salahReminderOffsetMinutes => 15;
  @override
  PrayerReminderType get prayerReminderType => PrayerReminderType.after;
  @override
  Set<Salaah> get enabledSalahReminders => {};
  @override
  bool get isWerdReminderEnabled => false;
  @override
  String get werdReminderTime => '20:00';
  @override
  bool get isSalawatReminderEnabled => false;
  @override
  int get salawatFrequencyHours => 3;
  @override
  String get salawatStartTime => '10:00';
  @override
  String get salawatEndTime => '20:00';

  @override
  Future<void> updateLocale(Locale locale) async {}
  @override
  Future<void> updateLocation(
      {double? latitude, double? longitude, String? cityName}) async {}
  @override
  Future<void> updateCalculationMethod(String method) async {}
  @override
  Future<void> updateMadhab(String madhab) async {}
  @override
  Future<void> updateMorningAzkarTime(String time) async {}
  @override
  Future<void> updateEveningAzkarTime(String time) async {}
  @override
  Future<void> updateAfterSalahAzkarEnabled(bool enabled) async {}
  @override
  Future<void> updateSalaahSettings(List<SalaahSettings> settings) async {}
  @override
  Future<void> toggleQadaEnabled() async {}
  @override
  Future<void> updateHijriAdjustment(int adjustment) async {}
  @override
  Future<void> addReminder(AzkarReminder reminder) async {}
  @override
  Future<void> removeReminder(int index) async {}
  @override
  Future<void> updateReminder(int index, AzkarReminder reminder) async {}
  @override
  Future<void> toggleReminder(int index) async {}
  @override
  Future<void> updateAllAzanEnabled(bool enabled) async {}
  @override
  Future<void> updateAllReminderEnabled(bool enabled) async {}
  @override
  Future<void> updateAllAzanSound(String? sound) async {}
  @override
  Future<void> updateAllReminderMinutes(int minutes) async {}
  @override
  Future<void> updateAllAfterSalahMinutes(int minutes) async {}
  @override
  Future<void> updateThemePreset(String presetId) async {}
  @override
  Future<void> saveCustomTheme(Map<String, String> colors) async {}
  @override
  Future<void> addCustomTheme(CustomTheme theme) async {}
  @override
  Future<void> updateCustomTheme(
      String themeId, Map<String, String> colors) async {}
  @override
  Future<void> deleteCustomTheme(String themeId) async {}
  @override
  Future<void> setActiveCustomTheme(String? themeId) async {}
  @override
  Future<void> updateAudioQuality(AudioQuality quality) async {}
  @override
  Future<void> updateAudioPlayerExpanded(bool expanded) async {}
  @override
  Future<void> updateSalahReminderEnabled(bool enabled) async {}
  @override
  Future<void> updateSalahReminderOffset(int minutes) async {}
  @override
  Future<void> updatePrayerReminderType(PrayerReminderType type) async {}
  @override
  Future<void> updateEnabledSalahReminders(Set<Salaah> enabledSalahs) async {}
  @override
  Future<void> updateWerdReminderEnabled(bool enabled) async {}
  @override
  Future<void> updateWerdReminderTime(String time) async {}
  @override
  Future<void> updateSalawatReminderEnabled(bool enabled) async {}
  @override
  Future<void> updateSalawatFrequency(int hours) async {}
  @override
  Future<void> updateSalawatStartTime(String time) async {}
  @override
  Future<void> updateSalawatEndTime(String time) async {}
}

class FakeTasbihRepository implements TasbihRepository {
  Map<String, int> progress = {};
  Map<String, int> history = {};
  Map<String, String> preferredDuas = {};

  @override
  Future<Map<String, int>> getAllProgress() async => progress;
  @override
  Future<Map<String, int>> getHistory() async => history;
  @override
  Future<Map<String, String>> getAllPreferredDuas() async => preferredDuas;

  @override
  Future<void> importData({
    required Map<String, int> progress,
    required Map<String, int> history,
    required Map<String, String> preferredDuas,
  }) async {
    this.progress = Map.from(progress);
    this.history = Map.from(history);
    this.preferredDuas = Map.from(preferredDuas);
  }

  @override
  Future<TasbihData> getTasbihData() async => throw UnimplementedError();
  @override
  Future<void> saveSettings(TasbihSettings settings) async {}
  @override
  Future<int> getSessionProgress(String categoryId) async => 0;
  @override
  Future<void> saveSessionProgress(String categoryId, int progress) async {}
  @override
  Future<void> incrementHistory(String dhikrId) async {}
  @override
  Future<String?> getPreferredCompletionDuaId(String categoryId) async => null;
  @override
  Future<void> savePreferredCompletionDuaId(
      String categoryId, String duaId) async {}
}

class FakeBookmarkRepository implements BookmarkRepository {
  List<Bookmark> bookmarks = [];

  @override
  Future<Result<List<Bookmark>>> getBookmarks() async =>
      Result.success(bookmarks);

  @override
  Future<Result<void>> importBookmarks(List<Bookmark> bookmarks) async {
    this.bookmarks = List.from(bookmarks);
    return Result.success(null);
  }

  @override
  Stream<Result<List<Bookmark>>> watchBookmarks() => throw UnimplementedError();
  @override
  Future<Result<void>> addBookmark(Bookmark bookmark) async =>
      Result.success(null);
  @override
  Future<Result<void>> removeBookmark(AyahNumber ayahNumber) async =>
      Result.success(null);
  @override
  Future<Result<void>> clearAllBookmarks() async => Result.success(null);
  @override
  Future<Result<bool>> isBookmarked(AyahNumber ayahNumber) async =>
      Result.success(false);
}

class FakeAzkarSource implements IAzkarSource {
  Map<String, int> progress = {};

  @override
  Future<Map<String, int>> getAllProgress() async => progress;

  @override
  Future<void> importProgress(Map<String, int> progress) async {
    this.progress = Map.from(progress);
  }

  @override
  Future<List<AzkarItem>> getAllAzkar() async => [];
  @override
  Future<void> saveProgress(AzkarItem item) async {}
  @override
  Future<void> resetCategory(String category) async {}
  @override
  Future<void> resetAll() async {}
  @override
  Future<List<String>> getCategories() async => [];
  @override
  Future<List<AzkarItem>> getAzkarByCategory(String category) async => [];
}

void main() {
  late FakeWerdRepository werdRepo;
  late FakePrayerRepo prayerRepo;
  late FakeSettingsRepository settingsRepo;
  late FakeTasbihRepository tasbihRepo;
  late FakeBookmarkRepository bookmarkRepo;
  late FakeAzkarSource azkarRepo;

  setUp(() {
    werdRepo = FakeWerdRepository();
    prayerRepo = FakePrayerRepo();
    settingsRepo = FakeSettingsRepository();
    tasbihRepo = FakeTasbihRepository();
    bookmarkRepo = FakeBookmarkRepository();
    azkarRepo = FakeAzkarSource();
  });

  test(
    'Full System Round-trip: Data should be identical after export and import',
    () async {
      // 1. Seed Initial Data
      prayerRepo.db = [
        DailyRecord(
          id: '1',
          date: DateTime(2024, 1, 1),
          missedToday: {Salaah.fajr},
          completedToday: {},
          qada: {Salaah.fajr: const MissedCounter(1)},
        ),
      ];

      werdRepo.goals = [
        WerdGoal(
          id: 'g1',
          type: WerdGoalType.fixedAmount,
          value: 5,
          startDate: DateTime(2024, 1, 1),
        ),
      ];

      werdRepo.progress = [
        WerdProgress(
          goalId: 'g1',
          totalAmountReadToday: 2,
          lastUpdated: DateTime(2024, 1, 1),
          streak: 1,
        ),
      ];

      settingsRepo.settings = {
        'calculation_method': 'umm_al_qura',
        'madhab': 'hanafi',
      };

      tasbihRepo.progress = {'cat1': 33};
      tasbihRepo.history = {'dhikr1': 100};
      tasbihRepo.preferredDuas = {'cat1': 'dua1'};

      azkarRepo.progress = {'azkar1': 5};

      bookmarkRepo.bookmarks = [
        Bookmark(
          id: 'b1',
          ayahNumber: AyahNumber.create(
            surahNumber: 2,
            ayahNumberInSurah: 255,
          ).data!,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      // 2. Simulate Export Action
      final exportedBackup = AppBackup(
        version: 2,
        appVersion: '1.0.0',
        timestamp: DateTime.now(),
        prayerRecords: await prayerRepo.loadAllRecords(),
        werdGoals: (await werdRepo.getAllGoals()).fold((l) => [], (r) => r),
        werdProgress: (await werdRepo.getAllProgress()).fold(
          (l) => [],
          (r) => r,
        ),
        preferences: settingsRepo.getAllSettings(),
        tasbihHistory: await tasbihRepo.getHistory(),
        tasbihProgress: await tasbihRepo.getAllProgress(),
        tasbihPreferredDuas: await tasbihRepo.getAllPreferredDuas(),
        azkarProgress: await azkarRepo.getAllProgress(),
        bookmarks: (await bookmarkRepo.getBookmarks()).fold((l) => [], (r) => r),
      );

      final jsonString = jsonEncode(exportedBackup.toJson());

      // 3. Clear System (Simulate app reinstall)
      prayerRepo.db = [];
      werdRepo.goals = [];
      werdRepo.progress = [];
      settingsRepo.settings = {};
      tasbihRepo.progress = {};
      tasbihRepo.history = {};
      tasbihRepo.preferredDuas = {};
      azkarRepo.progress = {};
      bookmarkRepo.bookmarks = [];

      // 4. Simulate Import Action
      final decodedJson = jsonDecode(jsonString);
      final importedBackup = AppBackup.fromJson(decodedJson);

      await prayerRepo.importAllRecords(importedBackup.prayerRecords);
      await werdRepo.importGoals(importedBackup.werdGoals);
      await werdRepo.importProgress(importedBackup.werdProgress);
      await settingsRepo.importSettings(importedBackup.preferences);
      await tasbihRepo.importData(
        progress: importedBackup.tasbihProgress,
        history: importedBackup.tasbihHistory,
        preferredDuas: importedBackup.tasbihPreferredDuas,
      );
      await azkarRepo.importProgress(importedBackup.azkarProgress);
      await bookmarkRepo.importBookmarks(importedBackup.bookmarks);

      // 5. Final Verification
      expect(prayerRepo.db.length, 1);
      expect(prayerRepo.db.first.missedToday, {Salaah.fajr});
      expect(werdRepo.goals.length, 1);
      expect(werdRepo.goals.first.id, 'g1');
      expect(werdRepo.progress.length, 1);
      expect(werdRepo.progress.first.streak, 1);
      expect(settingsRepo.settings['calculation_method'], 'umm_al_qura');
      expect(tasbihRepo.progress['cat1'], 33);
      expect(tasbihRepo.history['dhikr1'], 100);
      expect(tasbihRepo.preferredDuas['cat1'], 'dua1');
      expect(azkarRepo.progress['azkar1'], 5);
      expect(bookmarkRepo.bookmarks.length, 1);
      expect(bookmarkRepo.bookmarks.first.ayahNumber.surahNumber, 2);
    },
  );
}
