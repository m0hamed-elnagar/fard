import 'package:flutter/material.dart';
import 'package:fard/core/utils/symbol_detector.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';

import 'package:fard/features/quran/presentation/pages/symbol_detail_screen.dart';

class AyahInfoSheet extends StatefulWidget {
  final String ayahText;
  final QuranSymbolsRepository repository;
  final SymbolDetectorService detector;

  const AyahInfoSheet({
    super.key, 
    required this.ayahText, 
    required this.repository,
    required this.detector,
  });

  @override
  State<AyahInfoSheet> createState() => _AyahInfoSheetState();
}

class _AyahInfoSheetState extends State<AyahInfoSheet> {
  late Future<List<QuranSymbol>> _symbolsFuture;

  @override
  void initState() {
    super.initState();
    _symbolsFuture = _loadSymbols();
  }

  Future<List<QuranSymbol>> _loadSymbols() async {
    final ids = await widget.detector.detectSymbols(widget.ayahText);
    return widget.repository.getSymbolsByIds(ids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranSymbol>>(
      future: _symbolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "لم يتم اكتشاف رموز خاصة (وقف أو تجويد) في هذه الآية.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final symbols = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: symbols.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final symbol = symbols[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(int.parse(symbol.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  symbol.char,
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(int.parse(symbol.color.replaceFirst('#', '0xFF'))),
                  ),
                ),
              ),
              title: Text(
                symbol.arabicName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(symbol.brief),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SymbolDetailScreen(symbol: symbol),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
