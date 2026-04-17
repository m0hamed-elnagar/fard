import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MigrationService {
  static const String _migrationV1Key = 'assets_migration_v1_done';
  static const String _migrationV2Key = 'assets_migration_v2_done';

  /// V1: Moves assets from Support to Documents (Old logic, kept for legacy compatibility)
  static Future<void> migrateAssets() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationV1Key) ?? false) {
      return;
    }

    debugPrint('[MIGRATION] Starting asset migration v1 (Support -> Documents)...');
    final supportDir = await getApplicationSupportDirectory();
    final docsDir = await getApplicationDocumentsDirectory();

    final assetsToMigrate = ['mushaf_pages', 'audio'];

    for (final asset in assetsToMigrate) {
      final oldDir = Directory('${supportDir.path}/$asset');
      final newDir = Directory('${docsDir.path}/$asset');

      if (await oldDir.exists()) {
        debugPrint('[MIGRATION] Migrating $asset...');
        try {
          if (!await newDir.exists()) {
            await oldDir.rename(newDir.path);
          } else {
            final List<FileSystemEntity> entities = await oldDir.list().toList();
            for (final entity in entities) {
              final newPath = '${newDir.path}/${entity.uri.pathSegments.last}';
              await entity.rename(newPath);
            }
            await oldDir.delete(recursive: true);
          }
        } catch (e) {
          debugPrint('[MIGRATION] Failed to migrate $asset: $e');
        }
      }
    }

    await prefs.setBool(_migrationV1Key, true);
    debugPrint('[MIGRATION] Migration v1 completed.');
  }

  /// V2: Moves assets from Documents back to Support (Correct placement to avoid cloud backups)
  static Future<void> migrateToSupport() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationV2Key) ?? false) {
      return;
    }

    debugPrint('[MIGRATION] Starting asset migration v2 (Documents -> Support)...');
    final supportDir = await getApplicationSupportDirectory();
    final docsDir = await getApplicationDocumentsDirectory();

    final assetsToMigrate = ['mushaf_pages', 'audio'];

    for (final asset in assetsToMigrate) {
      final oldDir = Directory('${docsDir.path}/$asset');
      final newDir = Directory('${supportDir.path}/$asset');

      if (await oldDir.exists()) {
        debugPrint('[MIGRATION] Moving $asset back to Support directory...');
        try {
          if (!await newDir.exists()) {
            await newDir.create(recursive: true);
          }

          // Use recursive list to catch all sub-directories (like reciter folders)
          final entities = await oldDir.list(recursive: true).toList();
          
          // Filter only files to move them individually (safer than renaming the whole dir if target exists)
          for (final entity in entities) {
            if (entity is File) {
              final relativePath = entity.path.replaceFirst(oldDir.path, '');
              final targetFile = File('${newDir.path}$relativePath');
              
              if (!await targetFile.parent.exists()) {
                await targetFile.parent.create(recursive: true);
              }
              
              if (await targetFile.exists()) {
                await targetFile.delete();
              }
              await entity.rename(targetFile.path);
            }
          }

          // Clean up old directory if empty
          if (await oldDir.exists()) {
            await oldDir.delete(recursive: true);
          }
          debugPrint('[MIGRATION] Successfully moved $asset to Support.');
        } catch (e) {
          debugPrint('[MIGRATION] Failed to move $asset to Support: $e');
        }
      }
    }

    await prefs.setBool(_migrationV2Key, true);
    debugPrint('[MIGRATION] Migration v2 completed.');
  }
}
