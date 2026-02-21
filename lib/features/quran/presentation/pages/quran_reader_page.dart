import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/presentation/widgets/surah_header.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:fard/features/quran/presentation/widgets/reader_settings_sheet.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  double _baseScale = 1.0;
  bool _hasHandledInitialAyah = false;

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
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: BlocBuilder<ReaderBloc, ReaderState>(
                builder: (context, state) {
                  return state.maybeMap(
                    loaded: (s) => Text(s.surah.name, style: GoogleFonts.amiri()),
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
            body: Stack(
              children: [
                Positioned.fill(
                  child: BlocListener<ReaderBloc, ReaderState>(
                    listener: (context, state) {
                      state.mapOrNull(
                        loaded: (s) {
                          if (!_hasHandledInitialAyah && widget.initialAyahNumber != null) {
                            _hasHandledInitialAyah = true;
                            try {
                              final ayah = s.surah.ayahs.firstWhere(
                                (a) => a.number.ayahNumberInSurah == widget.initialAyahNumber
                              );
                              context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                            } catch (_) {}
                          }
                        },
                      );
                    },
                    child: BlocBuilder<ReaderBloc, ReaderState>(
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
                          loaded: (s) {
                            // Update audio bloc with current surah and first ayah for the player bar
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<AudioBloc>().add(
                                AudioEvent.updateCurrentPosition(
                                  surahNumber: s.surah.number.value,
                                  ayahNumber: s.surah.ayahs.isNotEmpty ? s.surah.ayahs.first.number.ayahNumberInSurah : null,
                                ),
                              );
                            });
                            return GestureDetector(
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
                                    
                                    // Bismillah logic
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
                                      
                                    BlocBuilder<AudioBloc, AudioState>(
                                      builder: (context, audioState) {
                                        final isThisSurah = audioState.currentSurah == widget.surahNumber;
                                        final playingAyah = isThisSurah && audioState.isActive 
                                          ? s.surah.ayahs.firstWhere(
                                              (a) => a.number.ayahNumberInSurah == audioState.currentAyah,
                                              orElse: () => s.surah.ayahs.first,
                                            ) 
                                          : null;

                                        return AyahText(
                                          ayahs: s.surah.ayahs,
                                          highlightedAyah: playingAyah ?? s.highlightedAyah ?? s.lastReadAyah,
                                          textScale: s.textScale,
                                          onAyahTap: (ayah) {
                                            context.read<ReaderBloc>().add(ReaderEvent.selectAyah(ayah));
                                          },
                                          onAyahLongPress: (ayah) {
                                            _showAyahDetail(context, ayah);
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AudioPlayerBar(),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAyahDetail(BuildContext context, Ayah ayah) {
    final readerBloc = context.read<ReaderBloc>();
    final readerState = readerBloc.state;
    int? count;
    readerState.maybeMap(
      loaded: (s) => count = s.surah.numberOfAyahs,
      orElse: () => null,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: readerBloc,
        child: AyahDetailSheet(ayah: ayah, surahAyahCount: count),
      ),
    );
  }
}
