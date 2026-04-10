import 'package:flutter/material.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:quran/quran.dart' as quran;

class JuzMarker extends StatelessWidget {
  final int juzNumber;
  final int surahNumber;
  final int firstAyahInJuz;
  final VoidCallback? onTap;

  const JuzMarker({
    super.key,
    required this.juzNumber,
    required this.surahNumber,
    required this.firstAyahInJuz,
    this.onTap,
  });

  static List<JuzMarkerData> getJuzMarkersForSurah(int surahNumber) {
    final markers = <JuzMarkerData>[];
    final totalAyahs = quran.getVerseCount(surahNumber);

    for (int juz = 1; juz <= 30; juz++) {
      final juzData = quran.getSurahAndVersesFromJuz(juz);
      if (juzData.containsKey(surahNumber)) {
        final firstAyah = juzData[surahNumber]!.first;
        if (firstAyah <= totalAyahs) {
          markers.add(JuzMarkerData(
            juzNumber: juz,
            ayahNumber: firstAyah,
          ));
        }
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: theme.dividerColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 14,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '${l10n.juz} $juzNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.go,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: theme.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class JuzMarkerData {
  final int juzNumber;
  final int ayahNumber;

  const JuzMarkerData({
    required this.juzNumber,
    required this.ayahNumber,
  });
}
