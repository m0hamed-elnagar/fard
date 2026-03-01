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
    int currentOffset = 0;

    for (final ayah in sortedAyahs) {
      final isHighlighted = ayah == widget.highlightedAyah;
      
      // We use TextSpans for markers instead of WidgetSpans to ensure perfect RTL flow.
      // The symbol ۝ (U+06DD) is used as the Ayah marker.
      final String markerText = ' ۝${ayah.number.ayahNumberInSurah.toArabicIndic()} ';
      final String ayahText = ayah.uthmaniText.trim();
      
      // Sajdah indicator still needs to be a WidgetSpan
      const int sajdahPlaceholderLen = 2; // Space + WidgetSpan placeholder

      _ayahRanges.add(_AyahRange(
        ayah: ayah,
        start: currentOffset,
        end: currentOffset + ayahText.length + markerText.length + (ayah.isSajdah ? sajdahPlaceholderLen : 0) + 1, // +1 for the extra space between ayahs
      ));
      
      currentOffset += ayahText.length + markerText.length + (ayah.isSajdah ? sajdahPlaceholderLen : 0) + 1;

      // Build Ayah Unit
      spans.add(
        TextSpan(
          children: [
            // Ayah Text
            TextSpan(
              text: ayahText,
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
            
            // Ayah Marker (TextSpan instead of WidgetSpan fixes RTL sequencing)
            TextSpan(
              text: markerText,
              style: GoogleFonts.amiri(
                fontSize: 24 * widget.textScale,
                color: isHighlighted 
                    ? colorScheme.primary 
                    : textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                backgroundColor: isHighlighted 
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : null,
              ),
            ),
            
            if (ayah.isSajdah && ayah.sajdahType != null) ...[
              const TextSpan(text: ' '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SajdahIndicator(
                  type: ayah.sajdahType!,
                  scale: widget.textScale,
                ),
              ),
            ],
            
            // Space between Ayahs
            const TextSpan(text: ' '), 
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
          TextSpan(children: spans),
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
