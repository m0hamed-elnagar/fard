import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MigrationService {
  static const String _migrationKey = 'assets_migration_v1_done';

  static Future<void> migrateAssets() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) ?? false) {
      return;
    }

    debugPrint('[MIGRATION] Starting asset migration...');
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
            // Attempt directory-level rename (instant)
            await oldDir.rename(newDir.path);
          } else {
            // Merge files if target exists
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

    await prefs.setBool(_migrationKey, true);
    debugPrint('[MIGRATION] Migration completed and flag set.');
  }
}
