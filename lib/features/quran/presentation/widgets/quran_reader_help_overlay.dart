import 'package:flutter/material.dart';
import 'package:fard/features/quran/presentation/pages/symbol_list_screen.dart';
import 'package:fard/features/quran/domain/repositories/quran_symbols_repository.dart';

class QuranReaderHelpOverlay extends StatefulWidget {
  final QuranSymbolsRepository repository;

  const QuranReaderHelpOverlay({super.key, required this.repository});

  @override
  State<QuranReaderHelpOverlay> createState() => _QuranReaderHelpOverlayState();
}

class _QuranReaderHelpOverlayState extends State<QuranReaderHelpOverlay> {
  final OverlayPortalController _controller = OverlayPortalController();
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 8),
            child: Material(
              elevation: 8,
              shadowColor: Colors.black45,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    _buildBody(context),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          );
        },
        child: IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'رموز المصحف',
          onPressed: _controller.toggle,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.pause_circle_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'علامات الوقف السريعة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => _controller.hide(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<CategorizedSymbols>(
      future: widget.repository.getCategorizedSymbols(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final symbols = snapshot.data?.waqfSymbols ?? [];
        
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 350),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            itemCount: symbols.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final s = symbols[index];
              final color = Color(int.parse(s.color.replaceFirst('#', '0xFF')));
              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.char, 
                      style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.arabicName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.brief, 
                          style: TextStyle(
                            fontSize: 11, 
                            height: 1.3,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _controller.hide();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SymbolListScreen(repository: widget.repository),
              ),
            );
          },
          icon: const Icon(Icons.menu_book_rounded, size: 16),
          label: const Text('دليل الرموز الشامل', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }
}
