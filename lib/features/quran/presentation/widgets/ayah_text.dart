import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_number_marker.dart';
import 'package:fard/features/quran/presentation/widgets/sajdah_indicator.dart';

class AyahText extends StatelessWidget {
  final List<Ayah> ayahs;
  final Ayah? highlightedAyah;
  final ValueChanged<Ayah> onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;
  final double textScale;

  const AyahText({
    super.key,
    required this.ayahs,
    this.highlightedAyah,
    required this.onAyahTap,
    this.onAyahLongPress,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          children: ayahs.expand((ayah) {
            final isHighlighted = ayah == highlightedAyah;
            final recognizer = _CombinedGestureRecognizer(
              onTap: () => onAyahTap(ayah),
              onDoubleTap: () => onAyahLongPress?.call(ayah),
              onLongPress: () => onAyahLongPress?.call(ayah),
            );
            
            final highlightStyle = GoogleFonts.amiri(
              fontSize: 28 * textScale,
              height: 1.8,
              wordSpacing: -2, // Reduce space between words
              backgroundColor: isHighlighted 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : null,
              color: isHighlighted 
                  ? Theme.of(context).colorScheme.primary 
                  : textTheme.bodyLarge?.color,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            );
            
            return [
              TextSpan(
                text: ayah.uthmaniText.trim(), // Trim to control spaces manually
                style: highlightStyle,
                recognizer: recognizer,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onAyahTap(ayah),
                  onDoubleTap: () => onAyahLongPress?.call(ayah),
                  onLongPress: () => onAyahLongPress?.call(ayah),
                  child: Container(
                    color: isHighlighted 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                        : null,
                    padding: const EdgeInsets.symmetric(horizontal: 6.0), // Space between marker and words
                    child: AyahNumberMarker(
                      number: ayah.number.ayahNumberInSurah,
                      size: 24 * textScale,
                      color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ),
              ),
              if (ayah.isSajdah && ayah.sajdahType != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onAyahTap(ayah),
                    onDoubleTap: () => onAyahLongPress?.call(ayah),
                    onLongPress: () => onAyahLongPress?.call(ayah),
                    child: Container(
                      color: isHighlighted 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SajdahIndicator(type: ayah.sajdahType!),
                    ),
                  ),
                ),
            ];
          }).toList(),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CombinedGestureRecognizer extends GestureRecognizer {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  _CombinedGestureRecognizer({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  late final TapGestureRecognizer _tapRecognizer = TapGestureRecognizer()
    ..onTap = onTap;
  late final DoubleTapGestureRecognizer _doubleTapRecognizer = DoubleTapGestureRecognizer()
    ..onDoubleTap = onDoubleTap;
  late final LongPressGestureRecognizer _longPressRecognizer = LongPressGestureRecognizer()
    ..onLongPress = onLongPress;

  @override
  void addPointer(PointerDownEvent event) {
    _tapRecognizer.addPointer(event);
    _doubleTapRecognizer.addPointer(event);
    _longPressRecognizer.addPointer(event);
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    _doubleTapRecognizer.dispose();
    _longPressRecognizer.dispose();
    super.dispose();
  }

  @override
  String get debugDescription => 'CombinedGestureRecognizer';

  @override
  void rejectGesture(int pointer) {
    _tapRecognizer.rejectGesture(pointer);
    _doubleTapRecognizer.rejectGesture(pointer);
    _longPressRecognizer.rejectGesture(pointer);
  }

  @override
  void acceptGesture(int pointer) {
    // This is tricky, but let the individual recognizers handle their acceptance
  }
}
