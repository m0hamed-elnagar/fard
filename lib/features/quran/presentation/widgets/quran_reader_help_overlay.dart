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
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        final RenderBox? buttonBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
        final buttonPosition = buttonBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        final buttonSize = buttonBox?.size ?? Size.zero;

        final screenWidth = MediaQuery.of(context).size.width;
        const tooltipWidth = 280.0;
        final tooltipLeft = (screenWidth - tooltipWidth) / 2;
        
        final arrowCenterX = (buttonPosition.dx + buttonSize.width / 2) - tooltipLeft;
        final topY = buttonPosition.dy + buttonSize.height + 4;

        return Stack(
          children: [
            // Full screen backdrop to close when tapping outside
            GestureDetector(
              onTap: () => _controller.hide(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Positioned(
              top: topY,
              left: tooltipLeft,
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 12,
                shadowColor: Colors.black54,
                shape: _TooltipShape(
                  arrowX: arrowCenterX,
                  borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  arrowWidth: 20,
                  arrowHeight: 12,
                  borderRadius: 16,
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0), // Padding for the arrow height
                  child: SizedBox(
                    width: tooltipWidth,
                    child: FutureBuilder<CategorizedSymbols>(
                      future: widget.repository.getCategorizedSymbols(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 150,
                            width: tooltipWidth,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final data = snapshot.data ?? CategorizedSymbols(waqfSymbols: [], tajweedSymbols: [], structureSymbols: []);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(context, data),
                            _buildBody(context, data),
                            _buildFooter(context),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: IconButton(
        key: _buttonKey,
        icon: const Icon(Icons.info_outline, size: 26),
        tooltip: 'رموز المصحف',
        onPressed: _controller.toggle,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CategorizedSymbols data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.pause_circle_outline_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'علامات الوقف (${data.waqfSymbols.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildBody(BuildContext context, CategorizedSymbols data) {
    final symbols = data.waqfSymbols;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 340),
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 100, // Shorter items
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          final s = symbols[index];
          final color = Color(int.parse(s.color.replaceFirst('#', '0xFF')));
          return Tooltip(
            message: s.brief,
            preferBelow: false,
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, // Larger icon circle
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.4), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      s.char,
                      style: TextStyle(
                        color: color,
                        fontSize: 32, // Larger symbol
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        s.arabicName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
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
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: const Text('دليل الرموز الشامل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }
}

class _TooltipShape extends ShapeBorder {
  final double arrowX;
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final Color borderColor;

  const _TooltipShape({
    required this.arrowX,
    required this.borderColor,
    this.arrowWidth = 20.0,
    this.arrowHeight = 12.0,
    this.borderRadius = 16.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = Rect.fromLTRB(rect.left, rect.top + arrowHeight, rect.right, rect.bottom);
    final path = Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(borderRadius)));

    final double safeArrowX = arrowX.clamp(
      rect.left + borderRadius + arrowWidth / 2, 
      rect.right - borderRadius - arrowWidth / 2
    );

    final arrowPath = Path()
      ..moveTo(safeArrowX - arrowWidth / 2, r.top)
      ..lineTo(safeArrowX, rect.top)
      ..lineTo(safeArrowX + arrowWidth / 2, r.top)
      ..close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
