import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class HizbList extends StatelessWidget {
  final String searchQuery;

  const HizbList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hizbIndices = List.generate(60, (index) => index + 1);

    final filteredHizb = hizbIndices.where((hizbNum) {
      if (searchQuery.isEmpty) return true;
      final hizbTitle = 'الحزب $hizbNum';
      final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(hizbNum);
      final firstSurahNum = hizbData.keys.first;
      final surahName = quran.getSurahNameArabic(firstSurahNum);
      return hizbTitle.contains(searchQuery) ||
          hizbNum.toString().contains(searchQuery) ||
          surahName.contains(searchQuery);
    }).toList();

    if (filteredHizb.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noSearchResults, style: GoogleFonts.amiri(fontSize: 20)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHizb.length,
      itemBuilder: (context, index) {
        final hizbNum = filteredHizb[index];
        final hizbData = QuranHizbProvider.getSurahAndVersesFromHizb(hizbNum);
        final firstSurahNum = hizbData.keys.first;
        final firstAyahNum = hizbData[firstSurahNum]![0];
        final surahName = quran.getSurahNameArabic(firstSurahNum);
        final pageNum = quran.getPageNumber(firstSurahNum, firstAyahNum);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  hizbNum.toArabicIndic(),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              title: Text(
                'الحزب ${hizbNum.toArabicIndic()}',
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'يبدأ من $surahName (ص ${pageNum.toArabicIndic()})',
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                ...List.generate(4, (qIndex) {
                  final rubNum = ((hizbNum - 1) * 4) + qIndex + 1;
                  final rubData = QuranHizbProvider.getSurahAndVersesFromRub(
                    rubNum,
                  );
                  final rSurah = rubData.keys.first;
                  final rAyah = rubData[rSurah]![0];
                  final rSurahName = quran.getSurahNameArabic(rSurah);
                  final rPage = quran.getPageNumber(rSurah, rAyah);

                  final quarterNames = [
                    'الربع الأول',
                    'الربع الثاني',
                    'الربع الثالث',
                    'الربع الأخير',
                  ];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      quarterNames[qIndex],
                      style: GoogleFonts.amiri(fontSize: 16),
                    ),
                    subtitle: Text(
                      'سورة $rSurahName، آية ${rAyah.toArabicIndic()} (ص ${rPage.toArabicIndic()})',
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_left, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        QuranReaderPage.route(
                          surahNumber: rSurah,
                          ayahNumber: rAyah,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
