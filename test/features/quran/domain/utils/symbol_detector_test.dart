import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';
import 'package:fard/core/utils/symbol_detector.dart';

class MockQuranSymbolsRepository implements QuranSymbolsRepository {
  final List<QuranSymbol> symbols;
  MockQuranSymbolsRepository(this.symbols);

  @override
  Future<CategorizedSymbols> getCategorizedSymbols() async {
    return CategorizedSymbols(
      waqfSymbols: symbols.where((s) => s.id.startsWith('waqf_')).toList(),
      tajweedSymbols: symbols.where((s) => s.id.startsWith('tajweed_')).toList(),
      structureSymbols: symbols.where((s) => s.id.startsWith('structure_')).toList(),
    );
  }

  @override
  Future<List<QuranSymbol>> getSymbolsByIds(List<String> ids) async {
    return symbols.where((s) => ids.contains(s.id)).toList();
  }
}

void main() {
  group('SymbolDetectorService Tests', () {
    final mockSymbols = [
      const QuranSymbol(
        id: 'waqf_lazim',
        char: 'ۖ',
        arabicName: 'الوقف اللازم',
        brief: 'test brief',
        ruleSummary: 'test rule',
        difficulty: 1,
        color: '#000000',
        sources: [],
      ),
      const QuranSymbol(
        id: 'waqf_mamnu',
        char: 'ۗ',
        arabicName: 'الوقف الممنوع',
        brief: 'test brief',
        ruleSummary: 'test rule',
        difficulty: 2,
        color: '#000000',
        sources: [],
      ),
    ];

    test('should detect symbols present in ayah text', () async {
      final repository = MockQuranSymbolsRepository(mockSymbols);
      final detector = SymbolDetectorService(repository);
      final ayah = 'إِلَى ٱلتَّهْلُكَةِ ۖ وَأَحْسِنُوٓا۟ ۗ';
      
      final detectedIds = await detector.detectSymbols(ayah);
      
      expect(detectedIds, contains('waqf_lazim'));
      expect(detectedIds, contains('waqf_mamnu'));
      expect(detectedIds.length, 2);
    });

    test('should return empty list if no symbols found', () async {
      final repository = MockQuranSymbolsRepository(mockSymbols);
      final detector = SymbolDetectorService(repository);
      final ayah = 'بسم الله الرحمن الرحيم';
      
      final detectedIds = await detector.detectSymbols(ayah);
      
      expect(detectedIds, isEmpty);
    });
  });
}
