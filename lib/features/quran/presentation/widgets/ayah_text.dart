import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/entities/reader_settings.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/features/quran/presentation/widgets/sajdah_indicator.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:quran/quran.dart' as quran;

class AyahText extends StatefulWidget {
  final List<Ayah> ayahs;
  final Ayah? highlightedAyah;
  final Ayah? dayStartAyah;
  final Ayah? lastReadAyah;
  final List<Bookmark> bookmarks;
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
    this.dayStartAyah,
    this.lastReadAyah,
    this.bookmarks = const [],
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
  late List<_AyahBlockData> _blocks;

  @override
  void initState() {
    super.initState();
    _calculateBlocks();
  }

  @override
  void didUpdateWidget(AyahText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayahs != widget.ayahs ||
        oldWidget.separator != widget.separator) {
      _calculateBlocks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _blocks
          .map((block) => RepaintBoundary(child: _buildBlock(block)))
          .toList(),
    );
  }

  void _calculateBlocks() {
    _blocks = [];
    if (widget.ayahs.isEmpty) return;

    final sortedAyahs = List<Ayah>.from(widget.ayahs)
      ..sort(
        (a, b) =>
            a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah),
      );

    List<Ayah> currentAyahs = [];
    String? currentLabel;
    const int maxAyahsPerBlock = 20;

    for (int i = 0; i < sortedAyahs.length; i++) {
      final ayah = sortedAyahs[i];
      String? newLabel;

      if (widget.separator != ReaderSeparator.none) {
        if (widget.separator == ReaderSeparator.page) {
          final page = quran.getPageNumber(
            ayah.number.surahNumber,
            ayah.number.ayahNumberInSurah,
          );
          // If this is the first ayah of this page in this surah
          // We need to check if the previous ayah was on a different page
          bool isPageStart = false;
          if (i == 0) {
            isPageStart = true;
          } else {
            final prevPage = quran.getPageNumber(
              sortedAyahs[i - 1].number.surahNumber,
              sortedAyahs[i - 1].number.ayahNumberInSurah,
            );
            if (page != prevPage) isPageStart = true;
          }

          if (isPageStart) {
            newLabel = 'صفحة ${page.toArabicIndic()}';
          }
        } else if (widget.separator == ReaderSeparator.juz) {
          final juz = quran.getJuzNumber(
            ayah.number.surahNumber,
            ayah.number.ayahNumberInSurah,
          );
          final juzData = quran.getSurahAndVersesFromJuz(juz);
          if (juzData.keys.isNotEmpty &&
              juzData.keys.first == ayah.number.surahNumber &&
              juzData.values.first[0] == ayah.number.ayahNumberInSurah) {
            newLabel = 'الجزء ${juz.toArabicIndic()}';
          }
        } else if (widget.separator == ReaderSeparator.hizb) {
          final hizb = QuranHizbProvider.getHizbNumber(
            ayah.number.surahNumber,
            ayah.number.ayahNumberInSurah,
          );
          final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(hizb);
          if (hizbData[ayah.number.surahNumber]?.contains(
                ayah.number.ayahNumberInSurah,
              ) ??
              false) {
            newLabel = 'الحزب ${hizb.toArabicIndic()}';
          }
        } else if (widget.separator == ReaderSeparator.quarter) {
          for (int r = 1; r <= 240; r++) {
            final rubData = QuranHizbProvider.getSurahAndVersesFromRub(r);
            if (rubData[ayah.number.surahNumber]?.contains(
                  ayah.number.ayahNumberInSurah,
                ) ??
                false) {
              final hizb = ((r - 1) / 4).floor() + 1;
              final quarterInHizb = (r - 1) % 4;
              final qNames = [
                'بداية الحزب',
                'الربع الثاني',
                'الربع الثالث',
                'الربع الأخير',
              ];
              newLabel =
                  '${qNames[quarterInHizb]} - الحزب ${hizb.toArabicIndic()}';
              break;
            }
          }
        }
      }

      // Also split if block gets too large to improve layout performance
      bool forceSplit = currentAyahs.length >= maxAyahsPerBlock;

      if ((newLabel != null || forceSplit) && currentAyahs.isNotEmpty) {
        _blocks.add(_AyahBlockData(ayahs: currentAyahs, label: currentLabel));
        currentAyahs = [];
        if (newLabel != null) {
          currentLabel = newLabel;
        } else {
          currentLabel = null;
        }
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
      final isHighlighted = widget.highlightedAyah?.number == ayah.number;
      final isDayStart = widget.dayStartAyah?.number == ayah.number;
      final isLastRead = widget.lastReadAyah?.number == ayah.number;
      final isBookmarked = widget.bookmarks.any(
        (b) => b.ayahNumber == ayah.number,
      );

      final String markerText = quran.getVerseEndSymbol(
        ayah.number.ayahNumberInSurah,
        arabicNumeral: true,
      );
      final String ayahText = ayah.uthmaniText.trim();

      // Calculate length for gesture detection
      // 1. SCROLL ANCHOR (WidgetSpan) = 1
      const int anchorLen = 1;
      // 2. START FLAG (TextSpan space + 🏁 + thin space) = 3 (if exists)
      final int dayStartLen = isDayStart ? 3 : 0;
      // 3. AYAH TEXT (TextSpan) = length
      final int textLen = ayahText.length;
      // 4. MARKER (TextSpan) = thin space (1) + markerText.length
      final int markerLen = 1 + markerText.length;
      // 5. PROGRESS MARKER (TextSpan space + ➤) = 2 (if exists)
      final int lastReadLen = isLastRead ? 2 : 0;
      // 6. BOOKMARK (TextSpan space + 🔖) = 3 (if exists, surrogate pair)
      final int bookmarkLen = isBookmarked ? 3 : 0;
      // 7. SAJDAH (TextSpan space + WidgetSpan) = 2 (if exists)
      final int sajdahLen = (ayah.isSajdah && ayah.sajdahType != null) ? 2 : 0;
      // 8. TRAILING SPACE (TextSpan) = 1
      const int trailingSpaceLen = 1;

      final int totalLen =
          anchorLen +
          dayStartLen +
          textLen +
          markerLen +
          lastReadLen +
          bookmarkLen +
          sajdahLen +
          trailingSpaceLen;

      ranges.add(
        _AyahRange(
          ayah: ayah,
          start: currentOffset,
          end: currentOffset + totalLen,
        ),
      );

      currentOffset += totalLen;

      final double baseFontSize = 28 * widget.textScale;
      const double lineHeight = 2.2;

      spans.add(
        TextSpan(
          style: GoogleFonts.amiri(fontSize: baseFontSize, height: lineHeight),
          children: [
            // 0. SCROLL ANCHOR
            WidgetSpan(
              child: SizedBox(
                key: widget.ayahKeys?[ayah.number.ayahNumberInSurah],
                width: 0,
                height: 0,
              ),
            ),

            // 1. START FLAG (Werd session start)
            if (isDayStart)
              const TextSpan(
                text: ' \u2691\u2009', // Black flag + thin space
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            // 2. AYAH TEXT
            TextSpan(
              text: ayahText,
              style: TextStyle(
                wordSpacing: 4,
                color: isHighlighted
                    ? colorScheme.primary
                    : textTheme.bodyLarge?.color,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                backgroundColor: isHighlighted
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : null,
              ),
            ),

            // 4. MARKER
            TextSpan(
              text: '\u2009$markerText',
              style: TextStyle(
                color: isHighlighted
                    ? colorScheme.primary
                    : textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                backgroundColor: isHighlighted
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : null,
              ),
            ),

            // 5. PROGRESS MARKER
            if (isLastRead)
              const TextSpan(
                text: ' \u27A4', // Arrow
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            // 6. BOOKMARK
            if (isBookmarked)
              const TextSpan(
                text: ' \u{1F516}', // Bookmark emoji
                style: TextStyle(color: Colors.green),
              ),

            if (ayah.isSajdah && ayah.sajdahType != null) ...[
              const TextSpan(text: ' '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  height:
                      baseFontSize *
                      (lineHeight *
                          0.8), // Slightly shorter to avoid overflow but keep alignment
                  alignment: Alignment.center,
                  color: isHighlighted
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : null,
                  child: SajdahIndicator(
                    type: ayah.sajdahType!,
                    scale: widget.textScale,
                  ),
                ),
              ),
            ],
            const TextSpan(text: ' '),
          ],
        ),
      );
    }

    final double baseFontSize = 28 * widget.textScale;
    const double lineHeight = 2.2;

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
                top: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
                bottom: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) => _handleGesture(
                details.localPosition,
                'tap',
                blockKey,
                ranges,
              ),
              onLongPressStart: (details) => _handleGesture(
                details.localPosition,
                'longPress',
                blockKey,
                ranges,
              ),
              onDoubleTapDown: (details) => _handleGesture(
                details.localPosition,
                'doubleTap',
                blockKey,
                ranges,
              ),
              child: Text.rich(
                key: blockKey,
                TextSpan(children: spans),
                textAlign: TextAlign.justify,
                softWrap: true,
                strutStyle: StrutStyle(
                  fontFamily: GoogleFonts.amiri().fontFamily,
                  fontSize: baseFontSize,
                  height: lineHeight,
                  forceStrutHeight: true,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleGesture(
    Offset localOffset,
    String type,
    GlobalKey textKey,
    List<_AyahRange> ranges,
  ) {
    final RenderObject? renderObject = textKey.currentContext
        ?.findRenderObject();
    if (renderObject == null || renderObject is! RenderParagraph) {
      return;
    }

    final RenderParagraph renderParagraph = renderObject;
    final TextPosition position = renderParagraph.getPositionForOffset(
      localOffset,
    );
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
