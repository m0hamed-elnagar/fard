import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class MigrationService {
  static Future<void> migrateAssets() async {
    final supportDir = await getApplicationSupportDirectory();
    final docsDir = await getApplicationDocumentsDirectory();

    final assetsToMigrate = [
      'mushaf_pages',
      'audio',
    ];

    for (final asset in assetsToMigrate) {
      final oldDir = Directory('${supportDir.path}/$asset');
      final newDir = Directory('${docsDir.path}/$asset');

      if (await oldDir.exists()) {
        debugPrint('Migrating $asset from ${oldDir.path} to ${newDir.path}');
        
        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }

        final List<FileSystemEntity> entities = await oldDir.list().toList();
        for (final entity in entities) {
          final newPath = '${newDir.path}/${entity.uri.pathSegments.last}';
          await entity.rename(newPath);
        }
        
        // Remove old directory
        await oldDir.delete(recursive: true);
      }
    }
  }
}
