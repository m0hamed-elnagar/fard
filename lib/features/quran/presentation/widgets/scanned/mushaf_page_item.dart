import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/core/theme/app_theme.dart';

class MushafPageItem extends StatefulWidget {
  final int pageNumber;
  final MushafDownloadService downloadService;
  final bool isDarkMode;

  const MushafPageItem({
    super.key,
    required this.pageNumber,
    required this.downloadService,
    required this.isDarkMode,
  });

  @override
  State<MushafPageItem> createState() => _MushafPageItemState();
}

class _MushafPageItemState extends State<MushafPageItem> {
  Future<File?>? _pageFileFuture;

  @override
  void initState() {
    super.initState();
    _checkAndDownload();
  }

  @override
  void didUpdateWidget(MushafPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _checkAndDownload();
    }
  }

  void _checkAndDownload() {
    setState(() {
      _pageFileFuture = _getOrDownloadPage();
    });
  }

  Future<File?> _getOrDownloadPage() async {
    try {
      final file = await widget.downloadService.getLocalFile(widget.pageNumber);
      if (await file.exists()) {
        return file;
      }

      final path = await widget.downloadService.downloadPage(widget.pageNumber);
      if (path != null) {
        final downloadedFile = File(path);
        if (await downloadedFile.exists()) {
          return downloadedFile;
        }
      }
    } catch (e) {
      debugPrint('Error in _getOrDownloadPage: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = widget.isDarkMode
        ? AppTheme.textPrimary
        : const Color(0xFF2D5D40);

    return FutureBuilder<File?>(
      future: _pageFileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text(l10n.loadingPage, style: TextStyle(color: primaryColor)),
              ],
            ),
          );
        }

        final file = snapshot.data;
        if (snapshot.hasError || file == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.pageNotAvailable(widget.pageNumber),
                  style: TextStyle(color: primaryColor),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _checkAndDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text(
                    l10n.retry,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: widget.isDarkMode
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -0.85,
                        0,
                        0,
                        0,
                        235,
                        0,
                        -0.85,
                        0,
                        0,
                        235,
                        0,
                        -0.85,
                        0,
                        0,
                        235,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Image.file(file, fit: BoxFit.contain),
                    )
                  : Image.file(file, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
