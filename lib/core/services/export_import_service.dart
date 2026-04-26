import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:fard/features/azkar/data/azkar_source.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@lazySingleton
class ExportImportService {
  final PrayerRepo prayerRepo;
  final WerdRepository werdRepo;
  final SettingsRepository settingsRepo;
  final TasbihRepository tasbihRepo;
  final IAzkarSource azkarRepo;
  final BookmarkRepository bookmarkRepo;
  final QuranRepository quranRepo;

  ExportImportService(
    this.prayerRepo,
    this.werdRepo,
    this.settingsRepo,
    this.tasbihRepo,
    this.azkarRepo,
    this.bookmarkRepo,
    this.quranRepo,
  );

  static const int currentBackupVersion = 2;

  Future<void> exportData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final prayerRecords = await prayerRepo.loadAllRecords();

      final goalsResult = await werdRepo.getAllGoals();
      final progressResult = await werdRepo.getAllProgress();

      final werdGoals = goalsResult.fold((l) => <WerdGoal>[], (r) => r);
      final werdProgress = progressResult.fold(
        (l) => <WerdProgress>[],
        (r) => r,
      );

      final preferences = settingsRepo.getAllSettings();
      final tasbihHistory = await tasbihRepo.getHistory();
      final tasbihProgress = await tasbihRepo.getAllProgress();
      final tasbihPreferredDuas = await tasbihRepo.getAllPreferredDuas();
      final azkarProgress = await azkarRepo.getAllProgress();
      final bookmarksResult = await bookmarkRepo.getBookmarks();
      final List<Bookmark> bookmarks =
          bookmarksResult.fold((l) => <Bookmark>[], (r) => r);

      final backup = AppBackup(
        version: currentBackupVersion,
        appVersion: packageInfo.version,
        timestamp: DateTime.now(),
        prayerRecords: prayerRecords,
        werdGoals: werdGoals,
        werdProgress: werdProgress,
        preferences: preferences,
        tasbihHistory: tasbihHistory,
        tasbihProgress: tasbihProgress,
        tasbihPreferredDuas: tasbihPreferredDuas,
        azkarProgress: azkarProgress,
        bookmarks: bookmarks,
      );

      // Perform serialization in an isolate to keep UI responsive
      final jsonString = await compute(
        (backup) => json.encode(backup.toJson()),
        backup,
      );

      final directory = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final file = File('${directory.path}/fard_backup_$dateStr.json');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Fard App Backup - $dateStr',
        ),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }

  Future<bool> importData() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Parse in an isolate
      final Map<String, dynamic> jsonData = await compute(
        (s) => json.decode(s),
        jsonString,
      );

      final backup = AppBackup.fromJson(jsonData);

      if (backup.version > currentBackupVersion) {
        throw Exception(
          'Backup version is newer than app version. Please update the app.',
        );
      }

      // Atomic-like import: Validate first, then import
      // (In this case, we trust our factory constructors for validation)

      await prayerRepo.importAllRecords(backup.prayerRecords);
      await werdRepo.importGoals(backup.werdGoals);
      await werdRepo.importProgress(backup.werdProgress);
      await settingsRepo.importSettings(backup.preferences);
      await tasbihRepo.importData(
        progress: backup.tasbihProgress,
        history: backup.tasbihHistory,
        preferredDuas: backup.tasbihPreferredDuas,
      );
      await azkarRepo.importProgress(backup.azkarProgress);
      await bookmarkRepo.importBookmarks(backup.bookmarks);

      // Reset Quran state to avoid hangs with stale/inconsistent data
      await quranRepo.clearCache();
      quranRepo.refresh();

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      rethrow;
    }
  }
}
