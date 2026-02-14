import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../domain/azkar_item.dart';

class AzkarRepository {
  final Box<int> _progressBox;
  List<AzkarItem>? _cachedAzkar;

  AzkarRepository(this._progressBox);

  Future<List<AzkarItem>> getAllAzkar() async {
    // Basic daily reset logic
    final now = DateTime.now();
    final todayKey = 'last_reset_date';
    final lastReset = _progressBox.get(todayKey);
    final currentDayHash = now.year * 10000 + now.month * 100 + now.day;

    if (lastReset != currentDayHash) {
      await _progressBox.clear();
      await _progressBox.put(todayKey, currentDayHash);
      _cachedAzkar = null;
    }

    if (_cachedAzkar != null) return _cachedAzkar!;

    try {
      final String response = await rootBundle.loadString('assets/azkar.json');
      final data = await json.decode(response);
      final List<dynamic>? rows = data['rows'];
      
      if (rows == null) return [];
      
      _cachedAzkar = rows.map((row) {
        final zekr = row.length > 1 ? row[1]?.toString() ?? '' : '';
        final category = row.length > 0 ? row[0]?.toString() ?? '' : '';
        // Composite key for unique identification
        final progressKey = '${category}_${zekr.hashCode}';
        
        return AzkarItem(
          category: category,
          zekr: zekr,
          description: row.length > 2 ? row[2]?.toString() ?? '' : '',
          count: row.length > 3 ? int.tryParse(row[3]?.toString() ?? '1') ?? 1 : 1,
          reference: row.length > 4 ? row[4]?.toString() ?? '' : '',
          currentCount: _progressBox.get(progressKey) ?? 0,
        );
      }).toList();
      
      return _cachedAzkar!;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProgress(AzkarItem item) async {
    final progressKey = '${item.category}_${item.zekr.hashCode}';
    await _progressBox.put(progressKey, item.currentCount);
    
    // Update cache
    if (_cachedAzkar != null) {
      final index = _cachedAzkar!.indexWhere((e) => e.zekr == item.zekr && e.category == item.category);
      if (index != -1) {
        _cachedAzkar![index] = item;
      }
    }
  }

  Future<void> resetCategory(String category) async {
    final azkar = await getAllAzkar();
    for (final item in azkar) {
      if (item.category == category) {
        final progressKey = '${category}_${item.zekr.hashCode}';
        await _progressBox.delete(progressKey);
        
        // Update cache
        final index = _cachedAzkar!.indexOf(item);
        if (index != -1) {
          _cachedAzkar![index] = item.copyWith(currentCount: 0);
        }
      }
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
