import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/azkar/data/azkar_source.dart';
import '../../features/azkar/domain/azkar_item.dart';

class BackgroundAzkarSource implements IAzkarSource {
  @override
  Future<List<AzkarItem>> getAllAzkar() async {
    try {
      final String response = await rootBundle.loadString('assets/azkar.json');
      final data = await json.decode(response);
      final List<dynamic>? rows = data['rows'];

      if (rows == null) return [];

      return rows.map((row) {
        final zekr = row.length > 1 ? row[1]?.toString() ?? '' : '';
        final category = row.length > 0 ? row[0]?.toString() ?? '' : '';

        return AzkarItem(
          category: category,
          zekr: zekr,
          description: row.length > 2 ? row[2]?.toString() ?? '' : '',
          count: row.length > 3 ? int.tryParse(row[3]?.toString() ?? '1') ?? 1 : 1,
          reference: row.length > 4 ? row[4]?.toString() ?? '' : '',
          currentCount: 0, // No progress tracking in background
        );
      }).toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}
