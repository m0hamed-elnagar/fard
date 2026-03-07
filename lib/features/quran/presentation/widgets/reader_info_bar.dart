import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

class ReaderInfoBar extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final VoidCallback? onJumpToStart;
  final VoidCallback? onJumpToLastRead;
  final VoidCallback? onJumpToBookmark;
  final List<int>? bookmarkAbsolutes;

  const ReaderInfoBar({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    this.onJumpToStart,
    this.onJumpToLastRead,
    this.onJumpToBookmark,
    this.bookmarkAbsolutes,
  });

  @override
  Widget build(BuildContext context) {
    final juz = quran.getJuzNumber(surahNumber, ayahNumber);
    final hizb = QuranHizbProvider.getHizbNumber(surahNumber, ayahNumber);
    final page = quran.getPageNumber(surahNumber, ayahNumber);
    final hasBookmarks = bookmarkAbsolutes != null && bookmarkAbsolutes!.isNotEmpty;

    return BlocBuilder<WerdBloc, WerdState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onJumpToStart != null && state.progress?.sessionStartAbsolute != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: InkWell(
                      onTap: onJumpToStart,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flag_rounded, 
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(state.progress!.sessionStartAbsolute!);
                                return Text(
                                  pos[1].toArabicIndic(),
                                  style: GoogleFonts.amiri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (onJumpToStart != null && state.progress?.sessionStartAbsolute != null)
                  const _VerticalDivider(),

                if (onJumpToLastRead != null && state.progress?.lastReadAbsolute != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: InkWell(
                      onTap: onJumpToLastRead,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward_rounded, 
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(state.progress!.lastReadAbsolute!);
                                return Text(
                                  pos[1].toArabicIndic(),
                                  style: GoogleFonts.amiri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                if (onJumpToLastRead != null && state.progress?.lastReadAbsolute != null)
                  const _VerticalDivider(),

                if (onJumpToBookmark != null && hasBookmarks)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: InkWell(
                      onTap: onJumpToBookmark,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark_rounded, 
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                // Logic: Find the first bookmark that is after current ayah, or wrap to first
                                final currentAbs = QuranHizbProvider.getAbsoluteAyahNumber(surahNumber, ayahNumber);
                                final nextBookmarkAbs = bookmarkAbsolutes!.firstWhere(
                                  (abs) => abs > currentAbs,
                                  orElse: () => bookmarkAbsolutes!.first,
                                );
                                final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(nextBookmarkAbs);
                                return Text(
                                  pos[1].toArabicIndic(),
                                  style: GoogleFonts.amiri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (onJumpToBookmark != null && hasBookmarks)
                  const _VerticalDivider(),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showDetails(context, state, juz, hizb, page),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InfoItem(label: 'جزء', value: juz.toArabicIndic()),
                        const _VerticalDivider(),
                        _InfoItem(label: 'حزب', value: hizb.toArabicIndic()),
                        const _VerticalDivider(),
                        _InfoItem(label: 'صفحة', value: page.toArabicIndic()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, WerdState state, int juz, int hizb, int page) {
    String todayStartInfo = 'غير محدد';
    String nextStartInfo = 'غير محدد';

    if (state.progress?.sessionStartAbsolute != null) {
      final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(state.progress!.sessionStartAbsolute!);
      final surahName = quran.getSurahNameArabic(pos[0]);
      todayStartInfo = '$surahName، آية ${pos[1].toArabicIndic()}';
    }

    final nextAbs = (state.progress?.lastReadAbsolute ?? 0) + 1;
    final nextPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(nextAbs);
    final nextSurahName = quran.getSurahNameArabic(nextPos[0]);
    nextStartInfo = '$nextSurahName، آية ${nextPos[1].toArabicIndic()}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'معلومات القراءة',
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('الجزء: ${juz.toArabicIndic()}', style: GoogleFonts.amiri(fontSize: 18)),
            Text('الحزب: ${hizb.toArabicIndic()}', style: GoogleFonts.amiri(fontSize: 18)),
            Text('الصفحة: ${page.toArabicIndic()}', style: GoogleFonts.amiri(fontSize: 18)),
            const Divider(),
            Text(
              'بداية ورد اليوم:',
              style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            Text(
              todayStartInfo,
              style: GoogleFonts.amiri(fontSize: 16, color: Colors.green),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              'بداية الورد القادمة:',
              style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            Text(
              nextStartInfo,
              style: GoogleFonts.amiri(fontSize: 16, color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.amiri(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
