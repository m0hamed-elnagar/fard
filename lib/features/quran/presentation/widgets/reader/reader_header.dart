import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/surah_header.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';

class QuranReaderHeader extends StatelessWidget {
  final int surahNumber;
  final List<Surah> allSurahs;
  final int? currentAyahNumber;
  final VoidCallback? onNextSurah;
  final VoidCallback? onPreviousSurah;
  final VoidCallback? onCompletionDoaa;

  const QuranReaderHeader({
    super.key,
    required this.surahNumber,
    required this.allSurahs,
    this.currentAyahNumber,
    this.onNextSurah,
    this.onPreviousSurah,
    this.onCompletionDoaa,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double expandedHeight = screenHeight < 600 ? 180 : 240;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      snap: true,
      pinned: false,
      toolbarHeight: 0,
      collapsedHeight: 0,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: BlocBuilder<ReaderBloc, ReaderState>(
            builder: (context, state) {
              return state.maybeMap(
                loaded: (s) => SurahHeader(
                  surah: s.surah,
                  allSurahs: allSurahs,
                  currentAyahNumber: currentAyahNumber,
                  onNext: onNextSurah,
                  onPrevious: onPreviousSurah,
                  onCompletionDoaa: surahNumber == 114 ? onCompletionDoaa : null,
                  textScale: s.textScale,
                  fontFamily: s.fontFamily,
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}
