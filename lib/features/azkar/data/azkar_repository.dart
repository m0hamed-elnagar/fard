import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/azkar_item.dart';

class AzkarRepository {
  Future<List<AzkarItem>> getAllAzkar() async {
    final String response = await rootBundle.loadString('assets/azkar.json');
    final data = await json.decode(response);
    final List<dynamic> rows = data['data'];
    
    return rows.map((row) => AzkarItem(
      category: row[0].toString(),
      zekr: row[1].toString(),
      description: row[2].toString(),
      count: int.tryParse(row[3].toString()) ?? 1,
      reference: row[4].toString(),
    )).toList();
  }

  Future<List<String>> getCategories() async {
    final azkar = await getAllAzkar();
    return azkar.map((e) => e.category).toSet().toList();
  }

  Future<List<AzkarItem>> getAzkarByCategory(String category) async {
    final azkar = await getAllAzkar();
    return azkar.where((e) => e.category == category).toList();
  }
}
