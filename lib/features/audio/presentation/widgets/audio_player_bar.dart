import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/reciter_selector.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (!state.isBannerVisible) {
          return const SizedBox.shrink();
        }
        
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
              // Progress Slider - very slim at the top
              if (state.duration > Duration.zero)
                SizedBox(
                  height: 2,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: SliderComponentShape.noThumb,
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
              
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
                child: Row(
                  children: [
                    // Reciter avatar - smaller
                    GestureDetector(
                      onTap: () => _showReciterSelector(context),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          state.currentReciter != null && state.currentReciter!.name.isNotEmpty
                              ? state.currentReciter!.name.substring(0, 1)
                              : 'A',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer, 
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 10),
                    
                    // Info text - flexible
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showReciterSelector(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.currentReciter?.name ?? 'Select Reciter',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.currentSurah != null && state.currentAyah != null
                                  ? 'Surah ${state.currentSurah}, Ayah ${state.currentAyah}'
                                  : 'Ready to play',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Grouped Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () => context.read<AudioBloc>().add(AudioEvent.skipToNext()),
                        ),
                        const SizedBox(width: 4),
                        // Play/Pause
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: state.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 24,
                                color: Colors.white,
                                icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                onPressed: () => context.read<AudioBloc>().add(AudioEvent.togglePlayback()),
                              ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () => context.read<AudioBloc>().add(AudioEvent.skipToPrevious()),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Repeat Button
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        state.isRepeating ? Icons.repeat_one_on_rounded : Icons.repeat_rounded,
                        color: state.isRepeating ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => context.read<AudioBloc>().add(AudioEvent.toggleRepeat()),
                    ),
                    
                    const SizedBox(width: 8),

                    // Close Button
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => context.read<AudioBloc>().add(AudioEvent.hideBanner()),
                    ),
                  ],
                ),
              ),
              
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
                          state.lastErrorMessage ?? state.error ?? "Error",
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
