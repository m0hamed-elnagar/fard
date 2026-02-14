import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/azkar_item.dart';

class AzkarRepository {
  List<AzkarItem>? _cachedAzkar;

  Future<List<AzkarItem>> getAllAzkar() async {
    if (_cachedAzkar != null) return _cachedAzkar!;

    try {
      final String response = await rootBundle.loadString('assets/azkar.json');
      final data = await json.decode(response);
      
      // The JSON structure has a 'rows' field, not 'data'
      final List<dynamic>? rows = data['rows'];
      
      if (rows == null) {
        print('AzkarRepository error: "rows" field is null');
        return [];
      }
      
      _cachedAzkar = rows.map((row) {
        // row is a List of values: [category, zekr, description, count, reference, search]
        return AzkarItem(
          category: row.length > 0 ? row[0]?.toString() ?? '' : '',
          zekr: row.length > 1 ? row[1]?.toString() ?? '' : '',
          description: row.length > 2 ? row[2]?.toString() ?? '' : '',
          count: row.length > 3 ? int.tryParse(row[3]?.toString() ?? '1') ?? 1 : 1,
          reference: row.length > 4 ? row[4]?.toString() ?? '' : '',
        );
      }).toList();
      
      return _cachedAzkar!;
    } catch (e) {
      print('AzkarRepository error: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    final azkar = await getAllAzkar();
    return azkar.map((e) => e.category).where((c) => c.isNotEmpty).toSet().toList();
  }

  Future<List<AzkarItem>> getAzkarByCategory(String category) async {
    final azkar = await getAllAzkar();
    return azkar.where((e) => e.category == category).toList();
  }
}
