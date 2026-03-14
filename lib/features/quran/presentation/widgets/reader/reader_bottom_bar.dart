import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/controllers/reader_scroll_controller.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart'; // For navigation (route)
import 'package:fard/features/quran/presentation/widgets/reader_info_bar.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuranReaderBottomBar extends StatelessWidget {
  final int surahNumber;
  final ReaderScrollController scrollController;

  const QuranReaderBottomBar({
    super.key,
    required this.surahNumber,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return state.maybeMap(
          loaded: (s) {
            return ValueListenableBuilder<int?>(
              valueListenable: scrollController.currentVisibleAyah,
              builder: (context, visibleAyah, _) {
                final currentAyahNum = visibleAyah ?? (s.highlightedAyah ?? s.lastReadAyah ?? s.surah.ayahs.firstOrNull)?.number.ayahNumberInSurah;
                
                // If we can't determine current ayah, just show player
                if (currentAyahNum == null) return const AudioPlayerBar();
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReaderInfoBar(
                      surahNumber: surahNumber,
                      ayahNumber: currentAyahNum,
                      onJumpToStart: () {
                        final werdState = context.read<WerdBloc>().state;
                        final startAbs = werdState.progress?.sessionStartAbsolute;
                        if (startAbs == null) return;

                        final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
                        if (pos[0] == surahNumber) {
                          try {
                            final ayah = s.surah.ayahs.firstWhere(
                              (a) => a.number.ayahNumberInSurah == pos[1],
                            );
                            context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                          } catch (_) {}
                          scrollController.scrollToAyah(pos[1]);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            QuranReaderPage.route(surahNumber: pos[0], ayahNumber: pos[1]),
                          );
                        }
                      },
                      onJumpToLastRead: () {
                        final werdState = context.read<WerdBloc>().state;
                        final lastAbs = werdState.progress?.lastReadAbsolute;
                        if (lastAbs == null) return;

                        final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(lastAbs);
                        if (pos[0] == surahNumber) {
                          try {
                            final ayah = s.surah.ayahs.firstWhere(
                              (a) => a.number.ayahNumberInSurah == pos[1],
                            );
                            context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                          } catch (_) {}
                          scrollController.scrollToAyah(pos[1]);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            QuranReaderPage.route(surahNumber: pos[0], ayahNumber: pos[1]),
                          );
                        }
                      },
                      bookmarkAbsolutes: s.bookmarks
                        .where((b) => b.ayahNumber.surahNumber == surahNumber)
                        .map((b) => 
                          QuranHizbProvider.getAbsoluteAyahNumber(
                            b.ayahNumber.surahNumber, 
                            b.ayahNumber.ayahNumberInSurah
                          )
                        ).toList()
                        ..sort(),
                      onJumpToBookmark: () {
                        final surahBookmarks = s.bookmarks
                            .where((b) => b.ayahNumber.surahNumber == surahNumber)
                            .toList()
                            ..sort((a, b) => a.ayahNumber.ayahNumberInSurah.compareTo(b.ayahNumber.ayahNumberInSurah));
                        
                        if (surahBookmarks.isEmpty) return;

                        // Logic: find first bookmark AFTER currentAyahNum, or wrap to first
                        final nextBookmark = surahBookmarks.firstWhere(
                          (b) => b.ayahNumber.ayahNumberInSurah > currentAyahNum,
                          orElse: () => surahBookmarks.first,
                        );

                        try {
                          final ayah = s.surah.ayahs.firstWhere(
                            (a) => a.number.ayahNumberInSurah == nextBookmark.ayahNumber.ayahNumberInSurah,
                          );
                          context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                        } catch (_) {}
                        scrollController.scrollToAyah(nextBookmark.ayahNumber.ayahNumberInSurah);
                      },
                    ),
                    AudioPlayerBar(
                      currentViewedSurah: surahNumber,
                      onScrollRequest: (s, a) => scrollController.scrollToAyah(a),
                    ),
                  ],
                );
              }
            );
          },
          orElse: () => AudioPlayerBar(
            currentViewedSurah: surahNumber,
            onScrollRequest: (s, a) => scrollController.scrollToAyah(a),
          ),
        );
      },
    );
  }
}
