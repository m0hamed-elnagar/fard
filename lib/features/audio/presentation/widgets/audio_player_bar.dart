import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:quran/quran.dart' as quran;

class AudioPlayerBar extends StatelessWidget {
  final int? currentViewedSurah;
  final void Function(int surah, int ayah)? onScrollRequest;

  const AudioPlayerBar({
    super.key,
    this.currentViewedSurah,
    this.onScrollRequest,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (!state.isBannerVisible) {
          return const SizedBox.shrink();
        }
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 360;
            final bool isVeryNarrow = constraints.maxWidth < 320;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(isNarrow ? 8 : 12, 10, 8, 4),
                    child: Row(
                      children: [
                        // Reciter avatar - hidden on very narrow screens
                        if (!isVeryNarrow)
                          GestureDetector(
                            onTap: () => _showReciterSelector(context),
                            child: CircleAvatar(
                              radius: isNarrow ? 14 : 16,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                state.currentReciter != null && state.currentReciter!.name.isNotEmpty
                                    ? state.currentReciter!.name.substring(0, 1)
                                    : 'A',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: isNarrow ? 10 : 12,
                                ),
                              ),
                            ),
                          ),
                        
                        if (!isVeryNarrow) SizedBox(width: isNarrow ? 6 : 10),
                        
                        // Info text - flexible
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showReciterSelector(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.currentReciter != null
                                      ? (isArabic ? state.currentReciter!.name : state.currentReciter!.englishName)
                                      : l10n.selectReciter,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isNarrow ? 10 : 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.currentSurah != null && state.currentAyah != null
                                      ? l10n.surahWithAyah(
                                          isArabic ? quran.getSurahNameArabic(state.currentSurah!) : quran.getSurahName(state.currentSurah!),
                                          isArabic ? state.currentAyah!.toArabicIndic() : state.currentAyah!.toString()
                                        )
                                      : l10n.readyToPlay,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: isNarrow ? 8 : 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Audio Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Go to currently playing Ayah button
                            if (state.currentAyah != null && state.currentSurah != null) ...[
                              IconButton(
                                iconSize: isNarrow ? 20 : 22,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: l10n.goToPlayingAyah,
                                icon: const Icon(Icons.my_location_rounded),
                                onPressed: () {
                                  // 1. Check if we can just scroll (already on correct surah)
                                  if (onScrollRequest != null && currentViewedSurah == state.currentSurah) {
                                    onScrollRequest!(state.currentSurah!, state.currentAyah!);
                                    return;
                                  }

                                  // 2. Otherwise navigate
                                  final currentRoute = ModalRoute.of(context);
                                  final bool isAlreadyOnReader = currentRoute?.settings.name == 'QuranReaderPage';

                                  if (isAlreadyOnReader) {
                                    Navigator.pushReplacement(
                                      context,
                                      QuranReaderPage.route(
                                        surahNumber: state.currentSurah!,
                                        ayahNumber: state.currentAyah!,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      QuranReaderPage.route(
                                        surahNumber: state.currentSurah!,
                                        ayahNumber: state.currentAyah!,
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(width: isNarrow ? 4 : 8),
                            ],

                            // Next Button
                            IconButton(
                              iconSize: isNarrow ? 20 : 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.skip_next_rounded),
                              onPressed: () => context.read<AudioBloc>().add(AudioEvent.skipToPrevious()),
                            ),
                            SizedBox(width: isNarrow ? 2 : 4),
                            // Play/Pause
                            Container(
                              width: isNarrow ? 32 : 36,
                              height: isNarrow ? 32 : 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: state.isLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white, 
                                      strokeWidth: isNarrow ? 1.5 : 2,
                                    ),
                                  )
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: isNarrow ? 22 : 24,
                                    color: Colors.white,
                                    icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                    onPressed: () => context.read<AudioBloc>().add(AudioEvent.togglePlayback()),
                                  ),
                            ),
                            SizedBox(width: isNarrow ? 2 : 4),
                            // Previous Button
                            IconButton(
                              iconSize: isNarrow ? 20 : 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.skip_previous_rounded),
                              onPressed: () => context.read<AudioBloc>().add(AudioEvent.skipToNext()),
                            ),
                          ],
                        ),

                        if (!isNarrow) const SizedBox(width: 8),

                        // Close Button
                        IconButton(
                          iconSize: isNarrow ? 18 : 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => context.read<AudioBloc>().add(AudioEvent.hideBanner()),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Progress Slider
                  if (state.duration > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(state.position),
                            style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Theme.of(context).colorScheme.primary,
                                inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                thumbColor: Theme.of(context).colorScheme.primary,
                                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: state.position.inMilliseconds.toDouble().clamp(0.0, state.duration.inMilliseconds.toDouble()),
                                max: state.duration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  context.read<AudioBloc>().add(
                                    AudioEvent.seekTo(Duration(milliseconds: value.toInt())),
                                  );
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(state.duration),
                            style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),

                  if (!state.hasError) const SizedBox(height: 8),
                  
                  // Error Display - very compact at the very bottom
                  if (state.hasError)
                    Container(
                      width: double.infinity,
                      color: Colors.red.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 12),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.lastErrorMessage ?? state.error ?? l10n.errorOccurred,
                              style: const TextStyle(color: Colors.red, fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  void _showReciterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AudioBloc>(),
        child: const Material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ReciterSelector(),
        ),
      ),
    );
  }
}
