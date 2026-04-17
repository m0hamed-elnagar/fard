import 'package:flutter/material.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/audio/presentation/screens/offline_audio_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadCenterSheet extends StatefulWidget {
  const DownloadCenterSheet({super.key});

  @override
  State<DownloadCenterSheet> createState() => _DownloadCenterSheetState();
}

class _DownloadCenterSheetState extends State<DownloadCenterSheet> {
  final _mushafService = getIt<MushafDownloadService>();
  final _quranRepository = getIt<QuranRepository>();

  double _mushafProgress = 0;
  bool _isMushafDownloading = false;

  double _textProgress = 0;
  bool _isTextDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialProgress();
  }

  Future<void> _checkInitialProgress() async {
    // Initial check for Mushaf
    int downloadedMushaf = 0;
    for (int i = 1; i <= 604; i++) {
      if (await _mushafService.isPageDownloaded(i)) downloadedMushaf++;
    }

    setState(() {
      _mushafProgress = downloadedMushaf / 604;
    });

    // Initial check for Text
    _checkTextProgress();
  }

  Future<void> _checkTextProgress() async {
    final progress = await _quranRepository.getTextDownloadProgress();
    if (mounted) {
      setState(() {
        _textProgress = progress;
        _errorMessage = null;
      });
    }
  }

  void _confirmMushafDownload() {
    final l10n = AppLocalizations.of(context)!;
    _showConfirmDownloadDialog(
      title: l10n.mushafImagesPNG,
      message: l10n.downloadMushafDesc,
      onConfirm: _startMushafDownload,
    );
  }

  void _confirmTextDownload() {
    final l10n = AppLocalizations.of(context)!;
    _showConfirmDownloadDialog(
      title: l10n.quranText,
      message: l10n.downloadQuranTextConfirm,
      onConfirm: _startTextDownload,
    );
  }

  void _showConfirmDownloadDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceContainerColor,
        title: Text(
          title,
          style: GoogleFonts.amiri(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: context.onSurfaceVariantColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.onSurfaceVariantColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.onSurfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.startDownload,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _startMushafDownload() {
    setState(() {
      _isMushafDownloading = true;
    });
    _mushafService.downloadAllPages().listen((progress) {
      if (mounted) {
        setState(() {
          _mushafProgress = progress;
        });
        if (progress >= 1.0 || _mushafProgress == progress && !_isMushafDownloading) {
          setState(() {
            _isMushafDownloading = false;
          });
        }
      }
    });
  }

  void _cancelMushafDownload() {
    _mushafService.cancelDownload();
    setState(() {
      _isMushafDownloading = false;
    });
  }

  void _startTextDownload() {
    setState(() {
      _isTextDownloading = true;
    });
    _quranRepository.downloadAllSurahs().listen((progress) {
      if (mounted) {
        setState(() {
          _textProgress = progress;
        });
        if (progress >= 1.0) {
          setState(() {
            _isTextDownloading = false;
          });
        }
      }
    });
  }

  void _cancelTextDownload() {
    _quranRepository.cancelTextDownload();
    setState(() {
      _isTextDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.outlineVariantColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.downloadCenter,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.downloadCenterDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.onSurfaceVariantColor),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.errorColor, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 32),

          _DownloadItem(
            title: l10n.mushafImagesPNG,
            subtitle: l10n.mushafImagesDesc,
            progress: _mushafProgress,
            isDownloading: _isMushafDownloading,
            onDownload: _confirmMushafDownload,
            onCancel: _cancelMushafDownload,
          ),

          const Divider(height: 48),

          _DownloadItem(
            title: l10n.quranText,
            subtitle: l10n.quranTextDesc,
            progress: _textProgress,
            isDownloading: _isTextDownloading,
            onDownload: _confirmTextDownload,
            onCancel: _cancelTextDownload,
          ),

          const Divider(height: 48),

          _AudioDownloadItem(
            title: l10n.quranAudio,
            subtitle: l10n.manageRecitersDesc,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OfflineAudioScreen()),
              );
            },
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.close,
              style: TextStyle(
                color: context.onSurfaceColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AudioDownloadItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AudioDownloadItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.onSurfaceVariantColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onCancel;

  const _DownloadItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isDownloading,
    required this.onDownload,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.onSurfaceVariantColor),
                  ),
                ],
              ),
            ),
            if (progress < 1.0 && !isDownloading)
              IconButton(
                icon: Icon(
                  Icons.download_for_offline_rounded,
                  color: context.primaryColor,
                  size: 32,
                ),
                onPressed: onDownload,
              )
            else if (progress >= 1.0)
              Icon(Icons.check_circle, color: context.primaryColor, size: 32)
            else
              IconButton(
                icon: Icon(
                  Icons.stop_circle_rounded,
                  color: context.errorColor,
                  size: 32,
                ),
                onPressed: onCancel,
              ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: context.outlineVariantColor,
            color: progress >= 1.0 ? context.primaryColor : context.primaryColor,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
