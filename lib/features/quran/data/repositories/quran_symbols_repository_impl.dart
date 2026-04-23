import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';

@LazySingleton(as: QuranSymbolsRepository)
class QuranSymbolsRepositoryImpl implements QuranSymbolsRepository {
  List<QuranSymbol>? _cachedSymbols;

  @override
  Future<CategorizedSymbols> getCategorizedSymbols() async {
    try {
      final symbols = await _loadAll();
      return CategorizedSymbols(
        waqfSymbols: symbols.where((s) => s.id.startsWith('waqf_') || s.id.startsWith('wasl_')).toList(),
        tajweedSymbols: symbols.where((s) => s.id.startsWith('ham_') || s.id.startsWith('madd_') || s.id.startsWith('small_')).toList(),
        structureSymbols: symbols.where((s) => ['verse_end', 'rub_hizb', 'sajdah'].contains(s.id)).toList(),
      );
    } catch (e, stack) {
      print('Error in getCategorizedSymbols: $e\n$stack');
      return CategorizedSymbols(waqfSymbols: [], tajweedSymbols: [], structureSymbols: []);
    }
  }

  @override
  Future<List<QuranSymbol>> getSymbolsByIds(List<String> ids) async {
    try {
      final symbols = await _loadAll();
      return symbols.where((s) => ids.contains(s.id)).toList();
    } catch (e) {
      print('Error in getSymbolsByIds: $e');
      return [];
    }
  }

  Future<List<QuranSymbol>> _loadAll() async {
    if (_cachedSymbols != null) return _cachedSymbols!;

    try {
      final data = await rootBundle.loadString('assets/quran_symbols/quran_symbols_separated.json');
      final json = jsonDecode(data);
      
      final List<QuranSymbol> all = [];
      
      if (json['waqf_symbols'] != null) {
        for (var item in json['waqf_symbols']) {
          all.add(QuranSymbol.fromJson(item));
        }
      }
      if (json['structure_symbols'] != null) {
        for (var item in json['structure_symbols']) {
          all.add(QuranSymbol.fromJson(item));
        }
      }
      if (json['tajweed_symbols'] != null) {
        for (var item in json['tajweed_symbols']) {
          all.add(QuranSymbol.fromJson(item));
        }
      }
      
      _cachedSymbols = all;
      print('QuranSymbolsRepository: Loaded ${all.length} symbols successfully');
      return all;
    } catch (e, stack) {
      print('QuranSymbolsRepository: Failed to load JSON: $e\n$stack');
      rethrow;
    }
  }
}
