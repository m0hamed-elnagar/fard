import 'package:flutter/material.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/features/quran/presentation/pages/scanned_mushaf_reader_page.dart';

import 'package:fard/core/theme/app_colors.dart';

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.pagesDownloadedSuccess)));
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
          Text(l10n.downloadMushafDesc, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (_isDownloading) ...[
            LinearProgressIndicator(
              value: _progress,
              color: context.primaryColor,
              backgroundColor: context.outlineVariantColor,
            ),
            const SizedBox(height: 10),
            Text('${(_progress * 100).toStringAsFixed(1)}%'),
          ],
          if (!_isDownloading) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.clearCache),
                    content: Text(
                      isArabic
                          ? 'هل أنت متأكد من مسح جميع صفحات المصحف المحملة؟ ستحتاج للاتصال بالإنترنت لقراءتها مرة أخرى.'
                          : 'Are you sure you want to clear all downloaded Mushaf pages? You will need an internet connection to read them again.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l10n.delete,
                          style: TextStyle(color: context.errorColor),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await widget.downloadService.clearCache();
                if (!context.mounted) return;

                // Refresh the whole page to trigger re-downloads
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  ScannedMushafReaderPage.route(pageNumber: widget.currentPage),
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.cacheClearedReloading)),
                );
              },
              icon: Icon(Icons.delete_sweep_rounded, color: context.errorColor),
              label: Text(
                l10n.clearCache,
                style: TextStyle(color: context.errorColor),
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
              backgroundColor: context.primaryColor,
            ),
            child: Text(
              l10n.startDownload,
              style: TextStyle(color: context.onSurfaceColor),
            ),
          ),
      ],
    );
  }
}
