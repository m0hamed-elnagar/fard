import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:intl/intl.dart';

import 'package:fard/core/extensions/number_extension.dart';

class BookmarkList extends StatelessWidget {
  final String searchQuery;

  const BookmarkList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    context.read<QuranBloc>().add(const QuranEvent.loadBookmarks());

    return BlocBuilder<QuranBloc, QuranState>(
      builder: (context, state) {
        final bookmarks = state.bookmarks.where((b) {
          if (searchQuery.isEmpty) return true;
          final surahName = quran.getSurahNameArabic(b.ayahNumber.surahNumber);
          return surahName.contains(searchQuery) || 
                 b.ayahNumber.ayahNumberInSurah.toString().contains(searchQuery);
        }).toList();

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إشارات مرجعية',
                  style: GoogleFonts.amiri(fontSize: 20),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            final surahName = quran.getSurahNameArabic(bookmark.ayahNumber.surahNumber);
            final page = quran.getPageNumber(
              bookmark.ayahNumber.surahNumber, 
              bookmark.ayahNumber.ayahNumberInSurah
            );

            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_rounded, color: Colors.amber),
              ),
              title: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'سورة $surahName',
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    wordSpacing: 2,
                  ),
                ),
              ),
              subtitle: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الآية ${bookmark.ayahNumber.ayahNumberInSurah.toArabicIndic()} | صفحة ${page.toArabicIndic()}',
                      style: GoogleFonts.amiri(
                        fontSize: 14, 
                        color: Colors.grey[600],
                        height: 1.4,
                        wordSpacing: 2,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(bookmark.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  QuranReaderPage.route(
                    surahNumber: bookmark.ayahNumber.surahNumber,
                    ayahNumber: bookmark.ayahNumber.ayahNumberInSurah,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
