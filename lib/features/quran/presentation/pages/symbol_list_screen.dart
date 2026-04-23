import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';

import 'package:fard/features/quran/presentation/pages/symbol_detail_screen.dart';

class SymbolListScreen extends StatelessWidget {
  final QuranSymbolsRepository repository;

  const SymbolListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل رموز المصحف'),
        centerTitle: true,
      ),
      body: FutureBuilder<CategorizedSymbols>(
        future: repository.getCategorizedSymbols(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('فشل تحميل الرموز: ${snapshot.error}'),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          if (data.waqfSymbols.isEmpty && data.tajweedSymbols.isEmpty && data.structureSymbols.isEmpty) {
            return const Center(child: Text('لا توجد رموز متاحة حالياً.'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (data.waqfSymbols.isNotEmpty)
                _buildCategorySection(context, 'علامات الوقف', data.waqfSymbols),
              if (data.tajweedSymbols.isNotEmpty)
                _buildCategorySection(context, 'علامات التجويد', data.tajweedSymbols),
              if (data.structureSymbols.isNotEmpty)
                _buildCategorySection(context, 'رموز المصحف', data.structureSymbols),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<QuranSymbol> symbols) {
    // Sort by difficulty (ascending)
    final sortedSymbols = List<QuranSymbol>.from(symbols)
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
    
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: sortedSymbols.map((symbol) {
        final color = Color(int.parse(symbol.color.replaceFirst('#', '0xFF')));
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              symbol.char, 
              style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(symbol.arabicName, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(symbol.brief, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SymbolDetailScreen(symbol: symbol),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
