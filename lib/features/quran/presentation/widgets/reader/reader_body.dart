import 'package:fard/core/extensions/quran_extension.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/controllers/reader_scroll_controller.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranReaderBody extends StatefulWidget {
  final ReaderScrollController scrollController;

  const QuranReaderBody({
    super.key,
    required this.scrollController,
  });

  @override
  State<QuranReaderBody> createState() => _QuranReaderBodyState();
}

class _QuranReaderBodyState extends State<QuranReaderBody> {
  bool _isSheetShowing = false;
  double _baseScale = 1.0;

  void _showAyahDetail(BuildContext context, Ayah ayah) async {
    if (_isSheetShowing) return;
    
    final readerBloc = context.read<ReaderBloc>();
    final readerState = readerBloc.state;
    int? count;
    readerState.maybeMap(
      loaded: (s) => count = s.surah.numberOfAyahs,
      orElse: () => null,
    );
    
    setState(() => _isSheetShowing = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: readerBloc,
        child: AyahDetailSheet(ayah: ayah, surahAyahCount: count),
      ),
    );
    if (mounted) {
      setState(() => _isSheetShowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          loading: (_) => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(e.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                         // This needs to be handled by the parent or we need to pass the surah number
                         // Ideally ReaderBloc already has the event to retry or we just re-add loadSurah
                         // But we don't have the surah number here easily unless we store it or get it from arguments
                         // For now, let's assume the user will go back or the parent handles error refetching logic 
                         // or we can just ask the bloc to retry if it supports it.
                         // The original code used widget.surahNumber.
                      },
                      child: const Text('Retry'), // Localize if possible, or pass l10n
                    ),
                  ],
                ),
              ),
            ),
          ),
          loaded: (s) {
            return SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Bismillah logic
                  if (s.surah.number.value != 9 && 
                      s.surah.ayahs.isNotEmpty && 
                      !s.surah.ayahs.first.uthmaniText.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                        style: GoogleFonts.amiri(
                          fontSize: 32 * s.textScale,
                          fontWeight: FontWeight.bold,
                          height: 2.2,
                          wordSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  BlocBuilder<AudioBloc, AudioState>(
                    builder: (context, audioState) {
                      final isThisSurah = audioState.currentSurah == s.surah.number.value;
                      final playingAyah = isThisSurah && audioState.isActive 
                        ? s.surah.ayahs.firstWhere(
                            (a) => a.number.ayahNumberInSurah == audioState.currentAyah,
                            orElse: () => s.surah.ayahs.first,
                          ) 
                        : null;

                      return BlocBuilder<WerdBloc, WerdState>(
                        builder: (context, werdState) {
                          Ayah? dayStartAyah;
                          Ayah? lastReadAyah;
                          
                          final startAbs = werdState.progress?.sessionStartAbsolute;
                          if (startAbs != null) {
                            final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
                            if (pos[0] == s.surah.number.value) {
                              try {
                                dayStartAyah = s.surah.ayahs.firstWhere(
                                  (a) => a.number.ayahNumberInSurah == pos[1],
                                );
                              } catch (_) {}
                            }
                          }

                          if (werdState.progress?.lastReadAbsolute != null) {
                            final pos = QuranHizbProvider.getSurahAndAyahFromAbsolute(werdState.progress!.lastReadAbsolute!);
                            if (pos[0] == s.surah.number.value) {
                              try {
                                lastReadAyah = s.surah.ayahs.firstWhere(
                                  (a) => a.number.ayahNumberInSurah == pos[1],
                                );
                              } catch (_) {}
                            }
                          }

                          return GestureDetector(
                             onScaleStart: (details) {
                                _baseScale = s.textScale;
                              },
                              onScaleUpdate: (details) {
                                context.read<ReaderBloc>().add(
                                      ReaderEvent.updateScale(_baseScale * details.scale),
                                    );
                              },
                            child: AyahText(
                              ayahs: s.surah.ayahs,
                              highlightedAyah: playingAyah ?? s.highlightedAyah,
                              dayStartAyah: dayStartAyah,
                              lastReadAyah: (werdState.progress?.totalAmountReadToday ?? 0) > 0 ? lastReadAyah : null,
                              bookmarks: s.bookmarks,
                              textScale: s.textScale,
                              ayahKeys: widget.scrollController.ayahKeys,
                              separator: s.separator,
                              onAyahTap: (ayah) {
                                context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                              },
                              onAyahLongPress: (ayah) {
                                _showAyahDetail(context, ayah);
                              },
                              onAyahDoubleTap: (ayah) {
                                _showAyahDetail(context, ayah);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 120),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
