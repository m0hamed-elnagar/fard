import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive_ce.dart';
import '../domain/azkar_item.dart';

class AzkarRepository {
  final Box<int> _progressBox;
  List<AzkarItem>? _cachedAzkar;
  Completer<List<AzkarItem>>? _loadingCompleter;

  AzkarRepository(this._progressBox);

  Future<List<AzkarItem>> getAllAzkar() async {
    // If cache is ready, return it immediately
    if (_cachedAzkar != null && _cachedAzkar!.isNotEmpty) {
      return _cachedAzkar!;
    }

    // If already loading, wait for that
    if (_loadingCompleter != null) {
      return _loadingCompleter!.future;
    }

    _loadingCompleter = Completer<List<AzkarItem>>();

    try {
      // Basic daily reset logic
      final now = DateTime.now();
      const todayKey = 'last_reset_date';
      final lastReset = _progressBox.get(todayKey);
      final currentDayHash = now.year * 10000 + now.month * 100 + now.day;

      if (lastReset != currentDayHash) {
        await _progressBox.clear();
        await _progressBox.put(todayKey, currentDayHash);
        _cachedAzkar = null;
      }

      if (_cachedAzkar != null && _cachedAzkar!.isNotEmpty) {
        _loadingCompleter!.complete(_cachedAzkar!);
        return _cachedAzkar!;
      }

      String response;
      try {
        response = await rootBundle
            .loadString('assets/azkar.json')
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Failed to load assets/azkar.json: $e');
        _cachedAzkar = [];
        _loadingCompleter!.complete([]);
        return [];
      }
      
      final data = await json.decode(response);
      final List<dynamic>? rows = data['rows'];
      
      if (rows == null) {
        _cachedAzkar = [];
        _loadingCompleter!.complete([]);
        return [];
      }
      
      _cachedAzkar = rows.map((row) {
      final zekr = row.length > 1 ? row[1]?.toString() ?? '' : '';
      final category = row.length > 0 ? row[0]?.toString() ?? '' : '';
      final progressKey = _getStableKey(category, zekr);
        
        return AzkarItem(
          category: category,
          zekr: zekr,
          description: row.length > 2 ? row[2]?.toString() ?? '' : '',
          count: row.length > 3 ? int.tryParse(row[3]?.toString() ?? '1') ?? 1 : 1,
          reference: row.length > 4 ? row[4]?.toString() ?? '' : '',
          currentCount: _progressBox.get(progressKey) ?? 0,
        );
      }).toList();
      
      _loadingCompleter!.complete(_cachedAzkar!);
      return _cachedAzkar!;
    } catch (e, stack) {
      _loadingCompleter!.completeError(e, stack);
      rethrow;
    } finally {
      _loadingCompleter = null;
    }
  }

  Future<void> saveProgress(AzkarItem item) async {
    final progressKey = _getStableKey(item.category, item.zekr);
    await _progressBox.put(progressKey, item.currentCount);
    
    // Update cache in place
    if (_cachedAzkar != null) {
      final index = _cachedAzkar!.indexWhere((e) => e.zekr == item.zekr && e.category == item.category);
      if (index != -1) {
        _cachedAzkar![index] = item;
      }
    }
  }

  Future<void> resetCategory(String category) async {
    // Ensure data is loaded
    await getAllAzkar();
    
    final keysToDelete = <String>[];
    if (_cachedAzkar != null) {
      for (int i = 0; i < _cachedAzkar!.length; i++) {
        final item = _cachedAzkar![i];
        if (item.category == category) {
          final progressKey = _getStableKey(category, item.zekr);
          keysToDelete.add(progressKey);
          _cachedAzkar![i] = item.copyWith(currentCount: 0);
        }
      }
    }
    
    if (keysToDelete.isNotEmpty) {
      await _progressBox.deleteAll(keysToDelete);
    }
  }

  Future<void> resetAll() async {
    const todayKey = 'last_reset_date';
    final lastReset = _progressBox.get(todayKey);
    
    await _progressBox.clear();
    
    if (lastReset != null) {
      await _progressBox.put(todayKey, lastReset);
    }
    
    _cachedAzkar = null; // Reset cache so next load gets fresh data
  }

  Future<List<String>> getCategories() async {
    final azkar = await getAllAzkar();
    return azkar.map((e) => e.category).where((c) => c.isNotEmpty).toSet().toList();
  }

  Future<List<AzkarItem>> getAzkarByCategory(String category) async {
    final azkar = await getAllAzkar();
    return azkar.where((e) => e.category == category).toList();
  }

  String _getStableKey(String category, String zekr) {
    // Stable hash for persistence
    int hash = 0;
    for (var i = 0; i < zekr.length; i++) {
      hash = 31 * hash + zekr.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return '${category}_$hash';
  }
}
