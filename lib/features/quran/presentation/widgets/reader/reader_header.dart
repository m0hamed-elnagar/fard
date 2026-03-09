import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/surah_header.dart';

class QuranReaderHeader extends StatelessWidget {
  final int surahNumber;
  final VoidCallback? onNextSurah;
  final VoidCallback? onPreviousSurah;

  const QuranReaderHeader({
    super.key,
    required this.surahNumber,
    this.onNextSurah,
    this.onPreviousSurah,
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
                  onNext: onNextSurah,
                  onPrevious: onPreviousSurah,
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
