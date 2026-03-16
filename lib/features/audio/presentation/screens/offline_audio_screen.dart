import 'dart:math' as math;
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/screens/reciter_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfflineAudioScreen extends StatelessWidget {
  const OfflineAudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineAudio)),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state.availableReciters.isEmpty) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.hasError) {
              return Center(
                child: Text(l10n.errorLoadingReciters(state.error ?? '')),
              );
            }
            // Trigger load if empty and not loading
            context.read<AudioBloc>().add(AudioEvent.loadReciters());
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: state.availableReciters.length,
            itemBuilder: (context, index) {
              final reciter = state.availableReciters[index];
              final progress =
                  state.reciterDownloadProgress[reciter.identifier] ?? 0.0;
              final sizeInBytes =
                  state.reciterDownloadSizes[reciter.identifier] ?? 0;

              String formatSize(int bytes) {
                if (bytes <= 0) return '0 B';
                const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
                var i = (math.log(bytes) / math.log(1024)).floor();
                return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
              }

              return ListTile(
                title: Text(reciter.name),
                subtitle: Text(
                  '${reciter.englishName} • ${formatSize(sizeInBytes)}',
                ),
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      strokeWidth: 3,
                    ),
                    Text(
                      '${(progress * 100).toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReciterDownloadScreen(reciter: reciter),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
