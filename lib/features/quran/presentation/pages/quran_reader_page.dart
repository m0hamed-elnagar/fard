import 'package:fard/core/di/injection.dart';
import 'package:fard/core/widgets/fast_scroll_scrollbar.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/utils/offline_audio_helper.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/controllers/reader_scroll_controller.dart';
import 'package:fard/features/quran/presentation/widgets/cycle_completion_dialog.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_app_bar.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_body.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_bottom_bar.dart';
import 'package:fard/features/quran/presentation/widgets/reader/reader_header.dart';
import 'package:fard/features/quran/presentation/widgets/reader/scroll_to_top_fab.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;
  final bool playOnLoad;
  final List<Surah>? allSurahs;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
    this.playOnLoad = false,
    this.allSurahs,
  });

  static Route route({
    required int surahNumber,
    int? ayahNumber,
    bool playOnLoad = false,
    List<Surah>? allSurahs,
  }) {
    return MaterialPageRoute(
      builder: (_) => QuranReaderPage(
        surahNumber: surahNumber,
        initialAyahNumber: ayahNumber,
        playOnLoad: playOnLoad,
        allSurahs: allSurahs,
      ),
    );
  }

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> with WidgetsBindingObserver {
  late final ReaderScrollController _scrollController;
  bool _hasHandledPlayOnLoad = false;
  bool _hasShownCycleCompletionDialog = false;

  // Save WerdBloc reference early to use in dispose()
  late final WerdBloc _werdBloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ReaderScrollController();
    WidgetsBinding.instance.addObserver(this);
    // Get WerdBloc reference while context is still valid
    _werdBloc = getIt<WerdBloc>();
  }

  @override
  void didUpdateWidget(QuranReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the flag when navigating to a different surah
    if (oldWidget.surahNumber != widget.surahNumber) {
      _hasShownCycleCompletionDialog = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // End session when app goes to background
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      _werdBloc.add(const WerdEvent.endSession());
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing downloads to prevent background corruption/leaks
    getIt<AudioDownloadService>().cancelAllDownloads();
    // End session when leaving Quran reader (use saved reference)
    _werdBloc.add(const WerdEvent.endSession());
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final surahNumResult = SurahNumber.create(widget.surahNumber);
            return getIt<ReaderBloc>()
              ..add(
                ReaderEvent.loadSurah(
                  surahNumber: surahNumResult.data!,
                  initialAyahNumber: widget.initialAyahNumber,
                ),
              );
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: const QuranReaderAppBar(),
            body: Stack(
              children: [
                Positioned.fill(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<ReaderBloc, ReaderState>(
                        listenWhen: (prev, curr) {
                          final prevAyah = prev.maybeMap(
                            loaded: (s) => s.highlightedAyah,
                            orElse: () => null,
                          );
                          final currAyah = curr.maybeMap(
                            loaded: (s) => s.highlightedAyah,
                            orElse: () => null,
                          );

                          // Trigger when transitioning to loaded or when highlight changes
                          return (prev.maybeMap(
                                    loaded: (_) => false,
                                    orElse: () => true,
                                  ) &&
                                  curr.maybeMap(
                                    loaded: (_) => true,
                                    orElse: () => false,
                                  )) ||
                              (prevAyah != currAyah);
                        },
                        listener: (context, state) {
                          state.mapOrNull(
                            loaded: (s) {
                              // Generate keys for all ayahs if not already done
                              _scrollController.generateKeys(s.surah.ayahs);

                              if (s.highlightedAyah != null) {
                                // Scroll to highlighted ayah (initial or changed)
                                _scrollController.scrollToAyah(
                                  s.highlightedAyah!.number.ayahNumberInSurah,
                                );
                              }

                              // Play on load logic
                              if (!_hasHandledPlayOnLoad && widget.playOnLoad) {
                                _hasHandledPlayOnLoad = true;
                                OfflineAudioHelper.handlePlayRequest(
                                  context: context,
                                  surahNumber: widget.surahNumber,
                                  startAyah: widget.initialAyahNumber ?? 1,
                                );
                              }

                              // Update audio bloc with current surah and first ayah for the player bar
                              context.read<AudioPlayerBloc>().add(
                                UpdateCurrentPosition(
                                  surahNumber: s.surah.number.value,
                                  ayahNumber: s.surah.ayahs.isNotEmpty
                                      ? s
                                            .surah
                                            .ayahs
                                            .first
                                            .number
                                            .ayahNumberInSurah
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // Listen to WerdBloc for cycle completion (ayah 6236)
                      BlocListener<WerdBloc, WerdState>(
                        listenWhen: (prev, curr) {
                          final prevLast = prev.progress?.lastReadAbsolute ?? 0;
                          final currLast = curr.progress?.lastReadAbsolute ?? 0;
                          // Trigger when lastReadAbsolute reaches 6236
                          return currLast == 6236 && prevLast != 6236;
                        },
                        listener: (context, state) async {
                          if (!_hasShownCycleCompletionDialog) {
                            _hasShownCycleCompletionDialog = true;
                            final choice = await CycleCompletionDialog.show(context);

                            if (!context.mounted) return;

                            final werdBloc = context.read<WerdBloc>();
                            if (choice == 'restart') {
                              werdBloc.add(WerdEvent.completeCycleAndRestart());
                              final werdGoalId = werdBloc.state.goal?.id ?? 'default';
                              werdBloc.add(WerdEvent.load(id: werdGoalId));

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  QuranReaderPage.route(
                                    surahNumber: 1,
                                    ayahNumber: 1,
                                    allSurahs: widget.allSurahs,
                                  ),
                                );
                              }
                            } else if (choice == 'stay') {
                              werdBloc.add(WerdEvent.completeCycleStayHere());
                              final werdGoalId = werdBloc.state.goal?.id ?? 'default';
                              werdBloc.add(WerdEvent.load(id: werdGoalId));
                            } else if (choice == 'doaa') {
                              werdBloc.add(const WerdEvent.completeCycle());
                              final werdGoalId = werdBloc.state.goal?.id ?? 'default';
                              werdBloc.add(WerdEvent.load(id: werdGoalId));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AzkarListScreen(
                                    category: 'دعاء ختم القران',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      BlocListener<AudioPlayerBloc, AudioPlayerState>(
                        listenWhen: (prev, curr) {
                          // Only trigger if ayah changed while active in the current surah
                          return curr.currentSurah == widget.surahNumber &&
                              curr.currentAyah != null &&
                              curr.currentAyah != prev.currentAyah &&
                              curr.isActive;
                        },
                        listener: (context, state) {
                          _scrollController.scrollToAyah(state.currentAyah!);
                        },
                      ),
                    ],
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: _scrollController.scrollController,
                          slivers: [
                            const SliverToBoxAdapter(child: SizedBox(height: 16)),
                            QuranReaderHeader(
                              surahNumber: widget.surahNumber,
                              allSurahs: widget.allSurahs ?? [],
                              currentAyahNumber: widget.initialAyahNumber,
                              onNextSurah: widget.surahNumber < 114
                                  ? () => Navigator.pushReplacement(
                                      context,
                                      QuranReaderPage.route(
                                        surahNumber: widget.surahNumber + 1,
                                        allSurahs: widget.allSurahs,
                                      ),
                                    )
                                  : null,
                              onPreviousSurah: widget.surahNumber > 1
                                  ? () => Navigator.pushReplacement(
                                      context,
                                      QuranReaderPage.route(
                                        surahNumber: widget.surahNumber - 1,
                                        allSurahs: widget.allSurahs,
                                      ),
                                    )
                                  : null,
                            ),
                            ValueListenableBuilder<int?>(
                              valueListenable: _scrollController.currentVisibleAyah,
                              builder: (context, visibleAyah, child) {
                                return QuranReaderBody(
                                  scrollController: _scrollController,
                                  currentVisibleAyah: visibleAyah,
                                  onCompletionDoaa: widget.surahNumber == 114
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const AzkarListScreen(
                                                category: 'دعاء ختم القران',
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  surahNumber: widget.surahNumber,
                                );
                              },
                            ),
                          ],
                        ),
                        // Fast scroll scrollbar for reader
                        BlocBuilder<ReaderBloc, ReaderState>(
                          builder: (context, state) {
                            return state.maybeMap(
                              loaded: (s) => FastScrollScrollbar(
                                scrollController: _scrollController.scrollController,
                                itemCount: s.surah.numberOfAyahs,
                                labelBuilder: (context, index) {
                                  final ayahNum = index + 1;
                                  return Text(
                                    'Ayah $ayahNum',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  );
                                },
                              ),
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),
                        // Scroll-to-top FAB
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: ScrollToTopFAB(
                            scrollController: _scrollController.scrollController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: QuranReaderBottomBar(
                    surahNumber: widget.surahNumber,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
