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
  final Map<int, GlobalKey>? ayahKeys;

  const AyahText({
    super.key,
    required this.ayahs,
    this.highlightedAyah,
    required this.onAyahTap,
    this.onAyahLongPress,
    this.textScale = 1.0,
    this.ayahKeys,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 16,
        children: ayahs.map((ayah) {
          final isHighlighted = ayah == highlightedAyah;
          final key = ayahKeys?[ayah.number.ayahNumberInSurah];
          
          return GestureDetector(
            onTap: () => onAyahTap(ayah),
            onLongPress: () => onAyahLongPress?.call(ayah),
            child: Text.rich(
              key: key,
              TextSpan(
                children: [
                  TextSpan(
                    text: ayah.uthmaniText.trim(),
                    style: GoogleFonts.amiri(
                      fontSize: 28 * textScale,
                      height: 2.2,
                      wordSpacing: 4,
                      backgroundColor: isHighlighted 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                          : null,
                      color: isHighlighted 
                          ? Theme.of(context).colorScheme.primary 
                          : textTheme.bodyLarge?.color,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      color: isHighlighted 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: AyahNumberMarker(
                        number: ayah.number.ayahNumberInSurah,
                        size: 24 * textScale,
                        color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ),
                  if (ayah.isSajdah && ayah.sajdahType != null)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Container(
                        color: isHighlighted 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SajdahIndicator(type: ayah.sajdahType!),
                      ),
                    ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }
}
