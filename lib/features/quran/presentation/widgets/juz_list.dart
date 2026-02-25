import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/extensions/number_extension.dart';

class JuzList extends StatelessWidget {
  final String searchQuery;

  const JuzList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // There are 30 Juz in the Quran
    final juzIndices = List.generate(30, (index) => index + 1);
    
    final filteredJuz = juzIndices.where((juzNum) {
      if (searchQuery.isEmpty) return true;
      final juzTitle = 'الجزء $juzNum';
      final firstSurahNum = quran.getSurahAndVersesFromJuz(juzNum).keys.first;
      final surahName = quran.getSurahNameArabic(firstSurahNum);
      return juzTitle.contains(searchQuery) || 
             juzNum.toString().contains(searchQuery) ||
             surahName.contains(searchQuery);
    }).toList();

    if (filteredJuz.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: GoogleFonts.amiri(fontSize: 20),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final padding = isWide ? 24.0 : 16.0;

        return ListView.separated(
          padding: EdgeInsets.all(padding),
          itemCount: filteredJuz.length,
          separatorBuilder: (context, index) => SizedBox(height: isWide ? 16 : 12),
          itemBuilder: (context, index) {
            final juzNum = filteredJuz[index];
            final juzData = quran.getSurahAndVersesFromJuz(juzNum);
            final firstSurahNum = juzData.keys.first;
            final firstAyahNum = juzData[firstSurahNum]![0];
            final surahName = quran.getSurahNameArabic(firstSurahNum);
            final pageNum = quran.getPageNumber(firstSurahNum, firstAyahNum);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    QuranReaderPage.route(
                      surahNumber: firstSurahNum,
                      ayahNumber: firstAyahNum,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 20.0 : 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: isWide ? 60 : 50,
                        height: isWide ? 60 : 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          juzNum.toArabicIndic(),
                          style: GoogleFonts.outfit(
                            fontSize: isWide ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: isWide ? 24 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الجزء ${juzNum.toArabicIndic()}',
                              style: GoogleFonts.amiri(
                                fontSize: isWide ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                                wordSpacing: 2,
                              ),
                            ),
                            Text(
                              'يبدأ من سورة $surahName (صفحة ${pageNum.toArabicIndic()})',
                              style: GoogleFonts.amiri(
                                fontSize: isWide ? 16 : 14,
                                color: Colors.grey[600],
                                height: 1.4,
                                wordSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
