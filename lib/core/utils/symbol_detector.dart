import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SymbolDetectorService {
  final QuranSymbolsRepository _repository;
  Map<String, String>? _symbolMap;

  SymbolDetectorService(this._repository);

  Future<void> _ensureInitialized() async {
    if (_symbolMap != null) return;
    final symbols = await _repository.getCategorizedSymbols();
    final all = [
      ...symbols.waqfSymbols,
      ...symbols.tajweedSymbols,
      ...symbols.structureSymbols
    ];
    _symbolMap = {for (final s in all) s.char: s.id};
  }

  /// Scans the provided ayah text and returns a list of unique symbol IDs found.
  Future<List<String>> detectSymbols(String ayahText) async {
    await _ensureInitialized();
    final Set<String> detectedIds = {};
    
    // Log mapping size for debugging
    print('SymbolDetector: Scanning text length ${ayahText.length}. Map size: ${_symbolMap!.length}');

    for (final rune in ayahText.runes) {
      final character = String.fromCharCode(rune);
      if (_symbolMap!.containsKey(character)) {
        final symbolId = _symbolMap![character]!;
        detectedIds.add(symbolId);
        print('SymbolDetector: Match found! Character: $character (U+${rune.toRadixString(16).padLeft(4, '0')}) -> ID: $symbolId');
      }
    }
    
    if (detectedIds.isEmpty) {
      print('SymbolDetector: No symbols detected in text: "$ayahText"');
    }

    return detectedIds.toList();
  }
}
