import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class SurahHeader extends StatelessWidget {
  final Surah surah;

  const SurahHeader({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            surah.englishName ?? '',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.place_outlined,
                label: surah.revelationType,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.format_list_numbered,
                label: '${surah.numberOfAyahs} ${l10n.ayah}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<AudioBloc, AudioState>(
            builder: (context, state) {
              final status = state.maybeMap(
                loaded: (s) => s.status,
                orElse: () => AudioStatus.idle,
              );
              final isPlaying = status == AudioStatus.playing;
              final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);

              return ElevatedButton.icon(
                onPressed: () {
                  if (isPlaying) {
                    context.read<AudioBloc>().add(const AudioEvent.pause());
                  } else if (status == AudioStatus.paused) {
                    context.read<AudioBloc>().add(const AudioEvent.resume());
                  } else {
                    // Play first ayah of surah
                    if (surah.ayahs.isNotEmpty) {
                      context.read<AudioBloc>().add(AudioEvent.play(
                        ayah: surah.ayahs.first.number,
                        reciterId: '7',
                        audioUrl: surah.ayahs.first.audioUrl,
                        mode: AudioPlayMode.surah,
                      ));
                    }
                  }
                },
                icon: isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(isPlaying ? 'Pause Surah' : 'Play Surah'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
