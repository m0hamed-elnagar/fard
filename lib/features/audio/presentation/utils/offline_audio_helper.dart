import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/connectivity_service.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/quran/presentation/widgets/download_center_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/repositories/audio_player_service.dart';

class OfflineAudioHelper {
  static Future<void> handlePlayRequest({
    required BuildContext context,
    required int surahNumber,
    required int startAyah,
    bool isDownloaded = false,
    bool forceDirectPlay = false,
  }) async {
    final playerBloc = context.read<AudioPlayerBloc>();
    final managerBloc = context.read<ReciterManagerBloc>();
    final playerState = playerBloc.state;
    final currentReciter = managerBloc.state.currentReciter;

    // Smart play/pause: If this surah is already active, toggle its state
    if (playerState.currentSurah == surahNumber) {
      if (playerState.isPlaying) {
        playerBloc.add(const Pause());
        return;
      } else if (playerState.status == AudioStatus.paused) {
        playerBloc.add(const Resume());
        return;
      }
    }

    // Real-time download check if caller didn't specify or passed false
    bool effectivelyDownloaded = isDownloaded;
    if (!effectivelyDownloaded && currentReciter != null) {
      final status = await getIt<AudioDownloadService>()
          .getSurahStatus(reciterId: currentReciter.identifier, surahNumber: surahNumber);
      effectivelyDownloaded = status.isDownloaded;
    }

    if (effectivelyDownloaded) {
      playerBloc.add(
        PlaySurah(surahNumber: surahNumber, startAyah: startAyah, reciter: currentReciter),
      );
      playerBloc.add(const ShowBanner());
      return;
    }

    // NOT downloaded: Check for network before attempting to stream
    final hasNetwork = await getIt<ConnectivityService>().hasNetwork();

    if (hasNetwork) {
      playerBloc.add(
        PlaySurah(surahNumber: surahNumber, startAyah: startAyah, reciter: currentReciter),
      );
      playerBloc.add(const ShowBanner());
      return;
    }

    // Offline and NOT downloaded: Look for alternatives
    final alternatives = await getIt<AudioDownloadService>()
        .getRecitersWithDownloadedSurah(surahNumber);

    if (alternatives.isNotEmpty) {
      if (context.mounted) {
        showAlternativeReciterDialog(
          context,
          surahNumber,
          startAyah,
          alternatives.first,
        );
      }
    } else {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.manageRecitersDesc),
            action: SnackBarAction(
              label: l10n.downloadCenterBtn,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const DownloadCenterSheet(),
                );
              },
            ),
          ),
        );
      }
    }
  }

  static void showAlternativeReciterDialog(
    BuildContext context,
    int surahNumber,
    int startAyah,
    Reciter alternative,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final playerBloc = context.read<AudioPlayerBloc>();
    final managerBloc = context.read<ReciterManagerBloc>();
    final currentReciter = managerBloc.state.currentReciter;
    final isArabic = l10n.localeName == 'ar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.quranAudio,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? "هذه السورة غير محملة للقارئ ${currentReciter?.name ?? ''}. هل تود الاستماع إليها بصوت ${alternative.name} المتاح بدون إنترنت؟"
              : "This surah is not downloaded for ${currentReciter?.englishName ?? ''}. Would you like to play it with ${alternative.englishName} instead?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              managerBloc.add(SelectReciter(alternative));
              playerBloc.add(ChangeReciter(alternative));
              playerBloc.add(
                PlaySurah(
                  surahNumber: surahNumber,
                  startAyah: startAyah,
                  reciter: alternative,
                ),
              );
              playerBloc.add(const ShowBanner());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: context.onSurfaceColor,
            ),
            child: Text(
              l10n.playSurahBtn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
