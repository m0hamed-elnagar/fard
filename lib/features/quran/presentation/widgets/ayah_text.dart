import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/reader_settings.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/quran/presentation/widgets/sajdah_indicator.dart';
import 'package:quran/quran.dart' as quran;

class AyahText extends StatefulWidget {
  final List<Ayah> ayahs;
  final Ayah? highlightedAyah;
  final ValueChanged<Ayah> onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;
  final ValueChanged<Ayah>? onAyahDoubleTap;
  final double textScale;
  final Map<int, GlobalKey>? ayahKeys;
  final ReaderSeparator separator;

  const AyahText({
    super.key,
    required this.ayahs,
    this.highlightedAyah,
    required this.onAyahTap,
    this.onAyahLongPress,
    this.onAyahDoubleTap,
    this.textScale = 1.0,
    this.ayahKeys,
    this.separator = ReaderSeparator.none,
  });

  @override
  State<AyahText> createState() => _AyahTextState();
}

class _AyahTextState extends State<AyahText> {
  final List<_AyahBlockData> _blocks = [];

  @override
  Widget build(BuildContext context) {
    _calculateBlocks();

    return Column(
      children: _blocks.map((block) => _buildBlock(block)).toList(),
    );
  }

  void _calculateBlocks() {
    _blocks.clear();
    if (widget.ayahs.isEmpty) return;

    final sortedAyahs = List<Ayah>.from(widget.ayahs)
      ..sort((a, b) => a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah));

    List<Ayah> currentAyahs = [];
    String? currentLabel;

    for (int i = 0; i < sortedAyahs.length; i++) {
      final ayah = sortedAyahs[i];
      String? newLabel;

      if (widget.separator != ReaderSeparator.none) {
        if (widget.separator == ReaderSeparator.juz) {
          final juz = quran.getJuzNumber(ayah.number.surahNumber, ayah.number.ayahNumberInSurah);
          final juzData = quran.getSurahAndVersesFromJuz(juz);
          if (juzData.keys.first == ayah.number.surahNumber && juzData.values.first[0] == ayah.number.ayahNumberInSurah) {
            newLabel = 'الجزء ${juz.toArabicIndic()}';
          }
        } else if (widget.separator == ReaderSeparator.hizb) {
          final hizb = QuranHizbProvider.getHizbNumber(ayah.number.surahNumber, ayah.number.ayahNumberInSurah);
          final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(hizb);
          if (hizbData[ayah.number.surahNumber]?.contains(ayah.number.ayahNumberInSurah) ?? false) {
            newLabel = 'الحزب ${hizb.toArabicIndic()}';
          }
        } else if (widget.separator == ReaderSeparator.quarter) {
          for (int r = 1; r <= 240; r++) {
            final rubData = QuranHizbProvider.getSurahAndVersesFromRub(r);
            if (rubData[ayah.number.surahNumber]?.contains(ayah.number.ayahNumberInSurah) ?? false) {
              final hizb = ((r - 1) / 4).floor() + 1;
              final quarterInHizb = (r - 1) % 4;
              final qNames = ['بداية الحزب', 'الربع الثاني', 'الربع الثالث', 'الربع الأخير'];
              newLabel = '${qNames[quarterInHizb]} - الحزب ${hizb.toArabicIndic()}';
              break;
            }
          }
        }
      }

      if (newLabel != null && currentAyahs.isNotEmpty) {
        _blocks.add(_AyahBlockData(ayahs: currentAyahs, label: currentLabel));
        currentAyahs = [];
        currentLabel = newLabel;
      } else if (newLabel != null) {
        currentLabel = newLabel;
      }

      currentAyahs.add(ayah);
    }

    if (currentAyahs.isNotEmpty) {
      _blocks.add(_AyahBlockData(ayahs: currentAyahs, label: currentLabel));
    }
  }

  Widget _buildBlock(_AyahBlockData block) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final GlobalKey blockKey = GlobalKey();
    final List<_AyahRange> ranges = [];
    final List<InlineSpan> spans = [];
    int currentOffset = 0;

    for (final ayah in block.ayahs) {
      final isHighlighted = ayah == widget.highlightedAyah;
      final String markerText = ' ۝${ayah.number.ayahNumberInSurah.toArabicIndic()} ';
      final String ayahText = ayah.uthmaniText.trim();
      
      // Calculate length for gesture detection
      // Note: WidgetSpan for anchor is 1 character inRichText offset terms
      const int anchorLen = 1;
      final int sajdahLen = ayah.isSajdah ? 2 : 0;
      final int totalLen = anchorLen + ayahText.length + markerText.length + sajdahLen + 1;

      ranges.add(_AyahRange(
        ayah: ayah,
        start: currentOffset,
        end: currentOffset + totalLen,
      ));
      
      currentOffset += totalLen;

      spans.add(
        TextSpan(
          children: [
            // SCROLL ANCHOR: A 0x0 WidgetSpan that provides the context for ensureVisible
            WidgetSpan(
              child: SizedBox(
                key: widget.ayahKeys?[ayah.number.ayahNumberInSurah],
                width: 0,
                height: 0,
              ),
            ),
            
            TextSpan(
              text: ayahText,
              style: GoogleFonts.amiri(
                fontSize: 28 * widget.textScale,
                height: 2.2,
                wordSpacing: 4,
                color: isHighlighted ? colorScheme.primary : textTheme.bodyLarge?.color,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                backgroundColor: isHighlighted ? colorScheme.primary.withValues(alpha: 0.1) : null,
              ),
            ),
            TextSpan(
              text: markerText,
              style: GoogleFonts.amiri(
                fontSize: 24 * widget.textScale,
                color: isHighlighted ? colorScheme.primary : textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                backgroundColor: isHighlighted ? colorScheme.primary.withValues(alpha: 0.1) : null,
              ),
            ),
            if (ayah.isSajdah && ayah.sajdahType != null) ...[
              const TextSpan(text: ' '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SajdahIndicator(type: ayah.sajdahType!, scale: widget.textScale),
              ),
            ],
            const TextSpan(text: ' '), 
          ],
        ),
      );
    }

    return Column(
      children: [
        if (block.label != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              border: Border(
                top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
                bottom: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Text(
              block.label!,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onTapUp: (details) => _handleGesture(details.localPosition, 'tap', blockKey, ranges),
            onLongPressStart: (details) => _handleGesture(details.localPosition, 'longPress', blockKey, ranges),
            onDoubleTapDown: (details) => _handleGesture(details.localPosition, 'doubleTap', blockKey, ranges),
            child: Text.rich(
              key: blockKey,
              TextSpan(children: spans),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  void _handleGesture(Offset localOffset, String type, GlobalKey textKey, List<_AyahRange> ranges) {
    final RenderObject? renderObject = textKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderParagraph) return;

    final RenderParagraph renderParagraph = renderObject;
    final TextPosition position = renderParagraph.getPositionForOffset(localOffset);
    final int offset = position.offset;

    for (final range in ranges) {
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

class _AyahBlockData {
  final List<Ayah> ayahs;
  final String? label;
  _AyahBlockData({required this.ayahs, this.label});
}

class _AyahRange {
  final Ayah ayah;
  final int start;
  final int end;
  _AyahRange({required this.ayah, required this.start, required this.end});
}
