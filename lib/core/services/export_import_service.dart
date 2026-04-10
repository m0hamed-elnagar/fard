import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@lazySingleton
class ExportImportService {
  final PrayerRepo prayerRepo;
  final WerdRepository werdRepo;

  ExportImportService(this.prayerRepo, this.werdRepo);

  static const int currentBackupVersion = 1;

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

      final backup = AppBackup(
        version: currentBackupVersion,
        appVersion: packageInfo.version,
        timestamp: DateTime.now(),
        prayerRecords: prayerRecords,
        werdGoals: werdGoals,
        werdProgress: werdProgress,
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

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      rethrow;
    }
  }
}
