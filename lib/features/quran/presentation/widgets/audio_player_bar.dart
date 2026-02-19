import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/presentation/widgets/reciter_selector.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioStatus.idle && state.error == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                if (state.duration > Duration.zero)
                  Slider(
                    value: state.position.inMilliseconds.toDouble().clamp(0.0, state.duration.inMilliseconds.toDouble()),
                    max: state.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      context.read<AudioBloc>().add(
                        AudioEvent.seekTo(Duration(milliseconds: value.toInt())),
                      );
                    },
                  ),
                
                Row(
                  children: [
                    // Reciter avatar (tap to change)
                    GestureDetector(
                      onTap: () => _showReciterSelector(context),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          state.currentReciter?.name.substring(0, 1) ?? 'A',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Current playing info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentReciter?.name ?? 'Select Reciter',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            state.currentSurah != null && state.currentAyah != null
                                ? 'Ayah ${state.currentAyah}'
                                : 'Ready to play',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Playback controls
                    IconButton(
                      icon: const Icon(Icons.replay_10, size: 20),
                      onPressed: () {
                        final newPos = state.position - const Duration(seconds: 10);
                        context.read<AudioBloc>().add(
                          AudioEvent.seekTo(newPos < Duration.zero ? Duration.zero : newPos),
                        );
                      },
                    ),
                    
                    // Play/Pause with loading state
                    if (state.isLoading)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        iconSize: 40,
                        icon: Icon(state.isPlaying ? Icons.pause_circle : Icons.play_circle),
                        onPressed: () {
                          context.read<AudioBloc>().add(AudioEvent.togglePlayback());
                        },
                      ),
                      
                    IconButton(
                      icon: const Icon(Icons.forward_10, size: 20),
                      onPressed: () {
                        final newPos = state.position + const Duration(seconds: 10);
                        if (newPos < state.duration) {
                          context.read<AudioBloc>().add(AudioEvent.seekTo(newPos));
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        context.read<AudioBloc>().add(AudioEvent.stop());
                      },
                    ),
                  ],
                ),
                
                // Repeat toggle (moved to the main row if possible, but let's keep it here for now but smaller)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      iconSize: 18,
                      icon: Icon(
                        Icons.repeat,
                        color: state.isRepeating 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () {
                        context.read<AudioBloc>().add(AudioEvent.toggleRepeat());
                      },
                    ),
                  ],
                ),
              ],
            ),
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
        child: const ReciterSelector(),
      ),
    );
  }
}
