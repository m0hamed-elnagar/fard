import 'package:fard/features/quran/domain/models/quran_symbol.dart';

class CategorizedSymbols {
  final List<QuranSymbol> waqfSymbols;
  final List<QuranSymbol> tajweedSymbols;
  final List<QuranSymbol> structureSymbols;

  CategorizedSymbols({
    required this.waqfSymbols,
    required this.tajweedSymbols,
    required this.structureSymbols,
  });
}

abstract class QuranSymbolsRepository {
  Future<CategorizedSymbols> getCategorizedSymbols();
  Future<List<QuranSymbol>> getSymbolsByIds(List<String> ids);
}

