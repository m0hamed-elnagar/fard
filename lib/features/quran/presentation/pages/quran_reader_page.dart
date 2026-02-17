import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/presentation/widgets/surah_header.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:fard/features/quran/presentation/widgets/reader_settings_sheet.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final surahNumResult = SurahNumber.create(widget.surahNumber);
            return getIt<ReaderBloc>()
              ..add(ReaderEvent.loadSurah(surahNumber: surahNumResult.data!));
          },
        ),
        BlocProvider(
          create: (context) => getIt<AudioBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: BlocBuilder<ReaderBloc, ReaderState>(
                builder: (context, state) {
                  return state.maybeMap(
                    loaded: (s) => Text(s.surah.name),
                    orElse: () => const Text('Quran Reader'),
                  );
                },
              ),
              actions: [
                BlocBuilder<ReaderBloc, ReaderState>(
                  builder: (context, state) {
                    final readerBloc = context.read<ReaderBloc>();
                    return IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: state.maybeMap(
                        loaded: (_) => () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BlocProvider.value(
                              value: readerBloc,
                              child: const ReaderSettingsSheet(),
                            ),
                          );
                        },
                        orElse: () => null,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: BlocBuilder<ReaderBloc, ReaderState>(
              builder: (context, state) {
                return state.map(
                  initial: (_) => const Center(child: CircularProgressIndicator()),
                  loading: (_) => const Center(child: CircularProgressIndicator()),
                  error: (e) => Center(
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
                               final surahNumResult = SurahNumber.create(widget.surahNumber);
                               context.read<ReaderBloc>().add(ReaderEvent.loadSurah(surahNumber: surahNumResult.data!));
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loaded: (s) => GestureDetector(
                    onScaleStart: (details) {
                      _baseScale = s.textScale;
                    },
                    onScaleUpdate: (details) {
                      context.read<ReaderBloc>().add(
                            ReaderEvent.updateScale(_baseScale * details.scale),
                          );
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SurahHeader(surah: s.surah),
                          
                          // Bismillah logic: 
                          // - Not for Surah 9 (At-Tawbah)
                          // - Only if first ayah doesn't already start with it (like Surah 1)
                          if (widget.surahNumber != 9 && 
                              s.surah.ayahs.isNotEmpty && 
                              !s.surah.ayahs.first.uthmaniText.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ'))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32.0),
                              child: Text(
                                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                                style: GoogleFonts.amiri(
                                  fontSize: 32 * s.textScale,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                          AyahText(
                            ayahs: s.surah.ayahs,
                            highlightedAyah: s.highlightedAyah,
                            textScale: s.textScale,
                            onAyahTap: (ayah) {
                              context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                            },
                            onAyahLongPress: (ayah) {
                              _showAyahDetail(context, ayah);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }

  void _showAyahDetail(BuildContext context, Ayah ayah) {
    final audioBloc = context.read<AudioBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: audioBloc,
        child: AyahDetailSheet(ayah: ayah),
      ),
    );
  }
}
