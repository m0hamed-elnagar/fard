import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
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

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (!state.isBannerVisible) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 360;

            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!state.isPlayerExpanded)
                      _buildCollapsedView(context, state, isNarrow, l10n)
                    else
                      _buildExpandedView(context, state, isNarrow, l10n),
                    
                    // Error Display - Ultra compact footer
                    if (state.hasError)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          state.lastErrorMessage ?? state.error ?? l10n.errorOccurred,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollapsedView(
    BuildContext context, 
    AudioPlayerState state, 
    bool isNarrow,
    AppLocalizations l10n,
  ) {
    final isArabic = l10n.localeName == 'ar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin Interactive Progress Line
        _buildProgressBar(context, state),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          child: Row(
            children: [
              // Surah/Ayah Info - Expanded to take space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.currentSurah != null && state.currentAyah != null
                          ? l10n.surahWithAyah(
                              isArabic
                                  ? state.currentAyah!.toArabicIndic()
                                  : state.currentAyah!.toString(),
                              isArabic
                                  ? quran.getSurahNameArabic(state.currentSurah!)
                                  : quran.getSurahName(state.currentSurah!),
                            )
                          : l10n.readyToPlay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isNarrow ? 14 : 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Essential Controls: Location, Play/Pause and Expand
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.currentAyah != null && state.currentSurah != null)
                    _buildActionButton(
                      icon: const Icon(Icons.my_location_rounded),
                      tooltip: l10n.goToPlayingAyah,
                      iconSize: isNarrow ? 18 : 20,
                      onPressed: () => _handleLocationClick(context, state),
                    ),
                  _buildPlayPauseButton(context, state, isNarrow),
                  _buildActionButton(
                    icon: const Icon(Icons.expand_less_rounded),
                    tooltip: "Expand", 
                    onPressed: () => context.read<AudioPlayerBloc>().add(
                      const TogglePlayerExpanded(),
                    ),
                  ),
                  _buildActionButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.close,
                    onPressed: () => context.read<AudioPlayerBloc>().add(
                      const HideBanner(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView(
    BuildContext context, 
    AudioPlayerState state, 
    bool isNarrow,
    AppLocalizations l10n,
  ) {
    final isArabic = l10n.localeName == 'ar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Info Row with Avatar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showReciterSelector(context),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    state.currentReciter != null && state.currentReciter!.name.isNotEmpty
                        ? state.currentReciter!.name.substring(0, 1)
                        : 'A',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.currentSurah != null && state.currentAyah != null
                          ? l10n.surahWithAyah(
                              isArabic
                                  ? state.currentAyah!.toArabicIndic()
                                  : state.currentAyah!.toString(),
                              isArabic
                                  ? quran.getSurahNameArabic(state.currentSurah!)
                                  : quran.getSurahName(state.currentSurah!),
                            )
                          : l10n.readyToPlay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      state.currentReciter != null
                          ? (isArabic ? state.currentReciter!.name : state.currentReciter!.englishName)
                          : l10n.selectReciter,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(
                icon: const Icon(Icons.expand_more_rounded),
                tooltip: "Collapse",
                onPressed: () => context.read<AudioPlayerBloc>().add(
                  const TogglePlayerExpanded(),
                ),
              ),
            ],
          ),
        ),

        // 2. Full Progress Slider with Times
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _formatDuration(state.position),
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Expanded(
                child: _buildProgressBar(context, state),
              ),
              Text(
                state.duration > Duration.zero ? _formatDuration(state.duration) : "--:--",
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),

        // 3. Full Control Cluster
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (state.currentAyah != null && state.currentSurah != null)
                _buildActionButton(
                  icon: const Icon(Icons.my_location_rounded),
                  tooltip: l10n.goToPlayingAyah,
                  onPressed: () => _handleLocationClick(context, state),
                ),
              _buildActionButton(
                icon: Icon(
                  state.isRepeating ? Icons.repeat_one_on_rounded : Icons.repeat_one_rounded,
                  color: state.isRepeating ? Theme.of(context).colorScheme.primary : null,
                ),
                tooltip: l10n.repeatAyah,
                onPressed: () => context.read<AudioPlayerBloc>().add(const ToggleRepeat()),
              ),
              _buildActionButton(
                // NOTE: ICON DIRECTIONS ARE SWAPPED DELIBERATELY TO LOOK CORRECT IN THE UI. DO NOT CHANGE.
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 24,
                onPressed: () => context.read<AudioPlayerBloc>().add(const SkipToPrevious()),
              ),
              _buildPlayPauseButton(context, state, isNarrow, size: 48),
              _buildActionButton(
                // NOTE: ICON DIRECTIONS ARE SWAPPED DELIBERATELY TO LOOK CORRECT IN THE UI. DO NOT CHANGE.
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 24,
                onPressed: () => context.read<AudioPlayerBloc>().add(const SkipToNext()),
              ),
              _buildActionButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.close,
                onPressed: () => context.read<AudioPlayerBloc>().add(const HideBanner()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context, 
    AudioPlayerState state, 
  ) {
    return SizedBox(
      height: 32, // Large hit area for fingers (32dp)
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2, // Thin bar
          thumbShape: state.duration > Duration.zero 
              ? const RoundSliderThumbShape(
                  enabledThumbRadius: 7, // Big circle
                  elevation: 2,
                )
              : SliderComponentShape.noThumb,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          activeTrackColor: Theme.of(context).colorScheme.primary,
          inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          thumbColor: Theme.of(context).colorScheme.primary,
        ),
        child: Slider(
          value: state.duration > Duration.zero
              ? state.position.inMilliseconds.toDouble().clamp(0.0, state.duration.inMilliseconds.toDouble())
              : 0.0,
          max: state.duration > Duration.zero ? state.duration.inMilliseconds.toDouble() : 1.0,
          onChanged: state.duration > Duration.zero
              ? (value) => context.read<AudioPlayerBloc>().add(SeekTo(Duration(milliseconds: value.toInt())))
              : null,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(
    BuildContext context, 
    AudioPlayerState state, 
    bool isNarrow,
    {double size = 42}
  ) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: state.isLoading
          ? Padding(
              padding: EdgeInsets.all(size * 0.25),
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              iconSize: size * 0.6,
              color: Colors.white,
              icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
              onPressed: () => context.read<AudioPlayerBloc>().add(const TogglePlayback()),
            ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required VoidCallback onPressed,
    double iconSize = 20,
    String? tooltip,
  }) {
    return IconButton(
      iconSize: iconSize,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
    );
  }

  void _handleLocationClick(BuildContext context, AudioPlayerState state) {
    if (onScrollRequest != null && currentViewedSurah == state.currentSurah) {
      onScrollRequest!(state.currentSurah!, state.currentAyah!);
      return;
    }
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
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AudioPlayerBloc>()),
          BlocProvider.value(value: context.read<ReciterManagerBloc>()),
        ],
        child: const Material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ReciterSelector(),
        ),
      ),
    );
  }
}
