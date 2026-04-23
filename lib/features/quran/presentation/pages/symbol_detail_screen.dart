import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/models/quran_symbol.dart';
import 'package:google_fonts/google_fonts.dart';

class SymbolDetailScreen extends StatefulWidget {
  final QuranSymbol symbol;

  const SymbolDetailScreen({super.key, required this.symbol});

  @override
  State<SymbolDetailScreen> createState() => _SymbolDetailScreenState();
}

class _SymbolDetailScreenState extends State<SymbolDetailScreen> {
  late String selectedSourceId;

  @override
  void initState() {
    super.initState();
    selectedSourceId = widget.symbol.sources.isNotEmpty 
        ? widget.symbol.sources.first.name 
        : 'default';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(int.parse(widget.symbol.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol.arabicName, style: GoogleFonts.amiri()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Big Symbol Header
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Text(
                widget.symbol.char,
                style: TextStyle(fontSize: 64, color: color),
              ),
            ),
            const SizedBox(height: 24),
            
            // Brief
            Text(
              widget.symbol.brief,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Rule Summary Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gavel_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('القاعدة العامة', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.symbol.ruleSummary,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sources Section
            if (widget.symbol.sources.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'شرح مفصل من المصادر:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: widget.symbol.sources.map((s) => ButtonSegment(
                  value: s.name,
                  label: Text(s.name, style: const TextStyle(fontSize: 12)),
                  icon: Icon(_getSourceIcon(s.sourceType), size: 16),
                )).toList(),
                selected: {selectedSourceId},
                onSelectionChanged: (newVal) {
                  setState(() => selectedSourceId = newVal.first);
                },
              ),
              const SizedBox(height: 16),
              _buildSourceContent(context),
            ],
            
            const SizedBox(height: 32),
            
            // Examples Section
            if (widget.symbol.examples.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'أمثلة من القرآن الكريم:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              ...widget.symbol.examples.map((ex) => _buildExampleTile(context, ex)),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSourceIcon(String type) {
    switch (type) {
      case 'book': return Icons.menu_book_rounded;
      case 'website': return Icons.language_rounded;
      case 'video': return Icons.play_circle_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Widget _buildSourceContent(BuildContext context) {
    final source = widget.symbol.sources.firstWhere((s) => s.name == selectedSourceId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Text(
        source.content,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildExampleTile(BuildContext context, SymbolExample ex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: ex.context != null 
          ? Text(ex.context!, 
              textAlign: TextAlign.right, 
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold))
          : null,
        subtitle: Text(
          'سورة ${ex.surah}، آية ${ex.ayah}',
          textAlign: TextAlign.right,
        ),
        leading: const Icon(Icons.format_quote_rounded, color: Colors.grey),
      ),
    );
  }
}
