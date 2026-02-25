import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/quran/presentation/widgets/sajdah_indicator.dart';

class AyahText extends StatefulWidget {
  final List<Ayah> ayahs;
  final Ayah? highlightedAyah;
  final ValueChanged<Ayah> onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;
  final ValueChanged<Ayah>? onAyahDoubleTap;
  final double textScale;
  final Map<int, GlobalKey>? ayahKeys;

  const AyahText({
    super.key,
    required this.ayahs,
    this.highlightedAyah,
    required this.onAyahTap,
    this.onAyahLongPress,
    this.onAyahDoubleTap,
    this.textScale = 1.0,
    this.ayahKeys,
  });

  @override
  State<AyahText> createState() => _AyahTextState();
}

class _AyahTextState extends State<AyahText> {
  final GlobalKey _textKey = GlobalKey();
  final List<_AyahRange> _ayahRanges = [];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // 1. Natural ascending order (1, 2, 3...)
    final sortedAyahs = List<Ayah>.from(widget.ayahs)
      ..sort((a, b) => a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah));

    _ayahRanges.clear();
    final List<InlineSpan> spans = [];
    int currentOffset = 1; // Account for the initial '\u202B'

    for (final ayah in sortedAyahs) {
      final isHighlighted = ayah == widget.highlightedAyah;
      final key = widget.ayahKeys?[ayah.number.ayahNumberInSurah];

      // Calculate the text for this ayah to track its range
      String ayahFullText = '\u2068'; // FSI
      ayahFullText += ayah.uthmaniText.trim();
      ayahFullText += '\u2009'; // Thin space
      ayahFullText += ' '; // WidgetSpan (AyahNumberMarker placeholder)
      
      if (ayah.isSajdah && ayah.sajdahType != null) {
        ayahFullText += '\u2009'; // Thin space
        ayahFullText += ' '; // WidgetSpan (SajdahIndicator placeholder)
      }
      
      ayahFullText += '\u2069'; // PDI
      ayahFullText += '\u2003'; // Em space
      
      _ayahRanges.add(_AyahRange(
        ayah: ayah,
        start: currentOffset,
        end: currentOffset + ayahFullText.length,
      ));
      
      currentOffset += ayahFullText.length;

      // 2. Build each Ayah Unit as an atomic span
      spans.add(
        TextSpan(
          children: [
            // Start of isolated unit (FSI - First Strong Isolate)
            const TextSpan(text: '\u2068'), 
            
            // Ayah text
            TextSpan(
              text: ayah.uthmaniText.trim(),
              style: GoogleFonts.amiri(
                fontSize: 28 * widget.textScale,
                height: 2.2,
                wordSpacing: 4,
                color: isHighlighted 
                    ? colorScheme.primary 
                    : textTheme.bodyLarge?.color,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                backgroundColor: isHighlighted 
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : null,
              ),
            ),
            
            const TextSpan(text: '\u2009'), // Thin space
            
            // Number marker unit
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                key: key,
                child: Text(
                  '۝${ayah.number.ayahNumberInSurah.toArabicIndic()}',
                  style: GoogleFonts.amiri(
                    fontSize: 24 * widget.textScale,
                    color: isHighlighted ? colorScheme.primary : textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            
            if (ayah.isSajdah && ayah.sajdahType != null) ...[
              const TextSpan(text: '\u2009'),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SajdahIndicator(
                  type: ayah.sajdahType!,
                  scale: widget.textScale,
                ),
              ),
            ],
            
            // End of isolated unit (PDI - Pop Directional Isolate)
            const TextSpan(text: '\u2069'),
            
            // Fixed spacing between units (Em space)
            const TextSpan(text: '\u2003'), 
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTapUp: (details) => _handleGesture(details.localPosition, 'tap'),
        onLongPressStart: (details) => _handleGesture(details.localPosition, 'longPress'),
        onDoubleTapDown: (details) => _handleGesture(details.localPosition, 'doubleTap'),
        child: Text.rich(
          key: _textKey,
          TextSpan(
            // Anchor the paragraph with RLE (Right-to-Left Embedding)
            text: '\u202B', 
            children: spans,
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
          softWrap: true,
        ),
      ),
    );
  }

  void _handleGesture(Offset localOffset, String type) {
    final RenderObject? renderObject = _textKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderParagraph) return;

    final RenderParagraph renderParagraph = renderObject;
    final TextPosition position = renderParagraph.getPositionForOffset(localOffset);
    final int offset = position.offset;

    for (final range in _ayahRanges) {
      if (offset >= range.start && offset < range.end) {
        switch (type) {
          case 'tap':
            widget.onAyahTap(range.ayah);
            break;
          case 'longPress':
            widget.onAyahLongPress?.call(range.ayah);
            break;
          case 'doubleTap':
            if (widget.onAyahDoubleTap != null) {
              widget.onAyahDoubleTap!(range.ayah);
            } else {
              // Fallback to long press if double tap is not provided
              widget.onAyahLongPress?.call(range.ayah);
            }
            break;
        }
        break;
      }
    }
  }
}

class _AyahRange {
  final Ayah ayah;
  final int start;
  final int end;

  _AyahRange({required this.ayah, required this.start, required this.end});
}

