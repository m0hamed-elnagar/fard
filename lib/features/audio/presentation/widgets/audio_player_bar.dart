import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/theme/app_colors.dart';
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Avatar, Surah/Ayah Info, Close
                  Padding(
                    padding: EdgeInsets.fromLTRB(isNarrow ? 12 : 16, 12, 8, 4),
                    child: Row(
                      children: [
                        // Reciter avatar
                        if (!isVeryNarrow)
                          GestureDetector(
                            onTap: () => _showReciterSelector(context),
                            child: CircleAvatar(
                              radius: isNarrow ? 16 : 18,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Text(
                                state.currentReciter != null &&
                                        state.currentReciter!.name.isNotEmpty
                                    ? state.currentReciter!.name.substring(0, 1)
                                    : 'A',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isNarrow ? 12 : 14,
                                ),
                              ),
                            ),
                          ),

                        if (!isVeryNarrow) SizedBox(width: isNarrow ? 8 : 12),

                        // Info text - flexible
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showReciterSelector(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.currentSurah != null &&
                                          state.currentAyah != null
                                      ? l10n.surahWithAyah(
                                          isArabic
                                              ? state.currentAyah!
                                                    .toArabicIndic()
                                              : state.currentAyah!.toString(),
                                          isArabic
                                              ? quran.getSurahNameArabic(
                                                  state.currentSurah!,
                                                )
                                              : quran.getSurahName(
                                                  state.currentSurah!,
                                                ),
                                        )
                                      : l10n.readyToPlay,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isNarrow ? 14 : 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.currentReciter != null
                                      ? (isArabic
                                            ? state.currentReciter!.name
                                            : state.currentReciter!.englishName)
                                      : l10n.selectReciter,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: isNarrow ? 10 : 11,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Close Button
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => context.read<AudioBloc>().add(
                            AudioEvent.hideBanner(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Row 2: Secondary Controls and Playback
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Go to currently playing Ayah button
                        if (state.currentAyah != null &&
                            state.currentSurah != null)
                          IconButton(
                            iconSize: 22,
                            tooltip: l10n.goToPlayingAyah,
                            icon: const Icon(Icons.my_location_rounded),
                            onPressed: () {
                              if (onScrollRequest != null &&
                                  currentViewedSurah == state.currentSurah) {
                                onScrollRequest!(
                                  state.currentSurah!,
                                  state.currentAyah!,
                                );
                                return;
                              }
                              final currentRoute = ModalRoute.of(context);
                              final bool isAlreadyOnReader =
                                  currentRoute?.settings.name ==
                                  'QuranReaderPage';
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

                        // Previous Button
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () => context.read<AudioBloc>().add(
                            AudioEvent.skipToPrevious(),
                          ),
                        ),

                        // Play/Pause
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: state.isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                    color: context.onSurfaceColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 28,
                                  color: context.onSurfaceColor,
                                  icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                  onPressed: () => context
                                      .read<AudioBloc>()
                                      .add(AudioEvent.togglePlayback()),
                                ),
                        ),

                        // Next Button
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () => context.read<AudioBloc>().add(
                            AudioEvent.skipToNext(),
                          ),
                        ),

                        // Repeat Button
                        IconButton(
                          iconSize: 20,
                          tooltip: l10n.repeatAyah,
                          icon: Icon(
                            Icons.repeat_one_rounded,
                            color: state.isRepeating
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                          ),
                          onPressed: () => context.read<AudioBloc>().add(
                            AudioEvent.toggleRepeat(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Slider Row
                  if (state.duration > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(state.position),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveTrackColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                thumbColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              child: Slider(
                                value: state.position.inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      state.duration.inMilliseconds.toDouble(),
                                    ),
                                max: state.duration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  context.read<AudioBloc>().add(
                                    AudioEvent.seekTo(
                                      Duration(milliseconds: value.toInt()),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(state.duration),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!state.hasError && state.duration == Duration.zero)
                    const SizedBox(height: 12),

                  // Error Display
                  if (state.hasError)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.errorColor.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: context.errorColor,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.lastErrorMessage ??
                                  state.error ??
                                  l10n.errorOccurred,
                              style: TextStyle(
                                color: context.errorColor,
                                fontSize: 10,
                              ),
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
