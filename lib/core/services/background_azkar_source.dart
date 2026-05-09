import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../features/azkar/data/azkar_source.dart';
import '../../features/azkar/domain/azkar_item.dart';

class BackgroundAzkarSource implements IAzkarSource {
  @override
  Future<List<AzkarItem>> getAllAzkar() async {
    try {
      final String response = await rootBundle.loadString('assets/azkar.json');
      return compute(_parseAzkarJson, response);
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  static List<AzkarItem> _parseAzkarJson(String jsonStr) {
    final data = json.decode(jsonStr);
    final List<dynamic>? rows = data['rows'];

    if (rows == null) return [];

    return rows.map((row) {
      final zekr = row.length > 1 ? row[1]?.toString() ?? '' : '';
      final category = row.length > 0 ? row[0]?.toString() ?? '' : '';

      return AzkarItem(
        category: category,
        zekr: zekr,
        description: row.length > 2 ? row[2]?.toString() ?? '' : '',
        count: row.length > 3
            ? int.tryParse(row[3]?.toString() ?? '1') ?? 1
            : 1,
        reference: row.length > 4 ? row[4]?.toString() ?? '' : '',
        currentCount: 0, // No progress tracking in background
      );
    }).toList();
  }

  @override
  Future<void> saveProgress(AzkarItem item) async {}

  @override
  Future<void> resetCategory(String category) async {}

  @override
  Future<void> resetAll() async {}

  @override
  Future<List<String>> getCategories() async {
    final azkar = await getAllAzkar();
    return azkar
        .map((e) => e.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Future<List<AzkarItem>> getAzkarByCategory(String category) async {
    final azkar = await getAllAzkar();
    return azkar.where((e) => e.category == category).toList();
  }

  // ==================== BACKUP / RESTORE ====================

  @override
  Future<Map<String, int>> getAllProgress() async => {};

  @override
  Future<void> importProgress(Map<String, int> progress) async {}
}
