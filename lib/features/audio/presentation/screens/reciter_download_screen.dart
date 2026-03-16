import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_download/audio_download_cubit.dart';
import 'package:fard/features/audio/presentation/blocs/audio_download/audio_download_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;

class ReciterDownloadScreen extends StatelessWidget {
  final Reciter reciter;

  const ReciterDownloadScreen({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => getIt<AudioDownloadCubit>()..init(reciter),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            context.read<AudioBloc>().add(AudioEvent.refreshReciterStatuses());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(reciter.name), // Use localized name if available
            actions: [
              // Delete All Action
              BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: l10n.deleteAll,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(l10n.deleteAllDownloads),
                          content: Text(l10n.deleteReciterConfirm(reciter.name)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.cancel)),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(c);
                                context.read<AudioDownloadCubit>().deleteReciter(reciter);
                              },
                              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
                  builder: (context, state) {
                    if (state.isLoading && state.surahStatuses.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return ListView.builder(
                      itemCount: 114,
                      itemBuilder: (context, index) {
                        final surahNumber = index + 1;
                        return _buildSurahTile(context, surahNumber, state, l10n);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
      builder: (context, state) {
        final isAnyDownloading = state.surahStatuses.values.any(
          (s) => s.isDownloading,
        );
        final isAnyStopping = state.surahStatuses.values.any(
          (s) => s.isStopping,
        );

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.manageOfflineAudio,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.downloadSurahsDesc,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isAnyStopping)
                ElevatedButton.icon(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  ),
                  icon: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                  label: Text(l10n.stopping),
                )
              else if (isAnyDownloading)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AudioDownloadCubit>().cancelDownload(reciter);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    foregroundColor: Colors.orange[900],
                  ),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l10n.stopAll),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AudioDownloadCubit>().downloadReciter(reciter);
                  },
                  icon: const Icon(Icons.download),
                  label: Text(l10n.downloadAll),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSurahTile(
    BuildContext context,
    int surahNumber,
    AudioDownloadState state,
    AppLocalizations l10n,
  ) {
    final status = state.surahStatuses[surahNumber];
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final surahName = isArabic
        ? quran.getSurahNameArabic(surahNumber)
        : quran.getSurahName(surahNumber);

    // Estimate or real size
    final estimatedSizeMB = (quran.getVerseCount(surahNumber) * 0.25)
        .toStringAsFixed(1);

    String sizeText;
    if (status != null) {
      final actualMB = (status.sizeInBytes / 1024 / 1024).toStringAsFixed(1);
      if (status.isDownloaded) {
        sizeText = '$actualMB MB';
      } else if (status.isStopping) {
        sizeText = l10n.stopping;
      } else if (status.isDownloading && status.downloadedAyahs == 0) {
        sizeText = l10n.starting;
      } else if (status.downloadedAyahs > 0) {
        sizeText =
            '${status.downloadedAyahs}/${status.totalAyahs} ${l10n.ayah} ($actualMB MB)';
      } else {
        sizeText = '${l10n.approx} $estimatedSizeMB MB';
      }
    } else {
      sizeText = '${l10n.approx} $estimatedSizeMB MB';
    }

    final isDownloading = status?.isDownloading ?? false;
    final isDownloaded = status?.isDownloaded ?? false;
    final isStopping = status?.isStopping ?? false;
    final hasPartial = (status?.downloadedAyahs ?? 0) > 0 && !isDownloaded;

    final progress = (state.activeSurahNumber == surahNumber)
        ? state.progress
        : (status != null && status.totalAyahs > 0
            ? status.downloadedAyahs / status.totalAyahs
            : 0.0);

    return ListTile(
      leading: CircleAvatar(child: Text('$surahNumber')),
      title: Text(surahName),
      subtitle: (isDownloading || hasPartial || isStopping)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: isStopping ? null : progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: isStopping 
                    ? const AlwaysStoppedAnimation<Color>(Colors.grey)
                    : null,
                ),
                const SizedBox(height: 2),
                Text(sizeText, style: const TextStyle(fontSize: 10)),
              ],
            )
          : Text(sizeText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDownloaded)
            const Icon(Icons.check_circle, color: Colors.green)
          else if (isStopping)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
            )
          else if (isDownloading)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(progress * 100).toInt()}%'),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<AudioDownloadCubit>().cancelDownload(reciter);
                  },
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(
                hasPartial
                    ? Icons.download_for_offline
                    : Icons.download_outlined,
              ),
              onPressed: () {
                context.read<AudioDownloadCubit>().downloadSurah(
                  reciter,
                  surahNumber,
                );
              },
            ),

          if (isDownloaded || isDownloading || hasPartial || isStopping)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: isStopping ? null : () {
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(l10n.deleteSurahAudio),
                    content: Text(l10n.deleteSurahConfirm(surahName)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(c);
                          context.read<AudioDownloadCubit>().deleteSurah(
                            reciter,
                            surahNumber,
                          );
                        },
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
