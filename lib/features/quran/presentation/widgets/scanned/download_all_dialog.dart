import 'package:flutter/material.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/features/quran/presentation/pages/scanned_mushaf_reader_page.dart';

class DownloadAllDialog extends StatefulWidget {
  final MushafDownloadService downloadService;
  final int currentPage;

  const DownloadAllDialog({
    super.key,
    required this.downloadService,
    required this.currentPage,
  });

  @override
  State<DownloadAllDialog> createState() => _DownloadAllDialogState();
}

class _DownloadAllDialogState extends State<DownloadAllDialog> {
  double _progress = 0;
  bool _isDownloading = false;

  void _startDownload(AppLocalizations l10n) {
    setState(() {
      _isDownloading = true;
    });
    widget.downloadService.downloadAllPages().listen((progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
        if (progress >= 1.0) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pagesDownloadedSuccess)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.downloadMushafPages, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.downloadMushafDesc,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_isDownloading) ...[
            LinearProgressIndicator(
              value: _progress,
              color: const Color(0xFF2D5D40),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 10),
            Text('${(_progress * 100).toStringAsFixed(1)}%'),
          ],
          if (!_isDownloading) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                await widget.downloadService.clearCache();
                if (!context.mounted) return;

                // Refresh the whole page to trigger re-downloads
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  ScannedMushafReaderPage.route(
                    pageNumber: widget.currentPage,
                  ),
                );
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheClearedReloading),
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              label: Text(
                l10n.clearCache,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        if (!_isDownloading)
          ElevatedButton(
            onPressed: () => _startDownload(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5D40),
            ),
            child: Text(
              l10n.startDownload,
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
