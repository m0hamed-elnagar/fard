import 'package:flutter/material.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/mushaf_download_service.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
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
    final result = await _quranRepository.getSurahs();
    if (result.isSuccess) {
      final surahs = result.data!;
      int total = surahs.length;
      int cachedCount = 0;
      
      // We don't want to block the UI too long, but let's check basic cache
      // Actually, since we have the repo, we can check just a few or use a stream
      // Let's just set initial based on what we can find quickly
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = result.failure?.message;
        });
      }
    }
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
        if (progress >= 1.0) {
          _isMushafDownloading = false;
        }
      }
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
          _isTextDownloading = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'مركز التحميل (للعمل بدون إنترنت)',
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D5D40),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'حمل محتوى المصحف لتتمكن من القراءة والاستماع دون الحاجة للاتصال بالإنترنت.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 32),
          
          _DownloadItem(
            title: 'المصحف المصور (PNG)',
            subtitle: '604 صفحة عالية الجودة (حوالي 80 ميجابايت)',
            progress: _mushafProgress,
            isDownloading: _isMushafDownloading,
            onDownload: _startMushafDownload,
          ),
          
          const Divider(height: 48),
          
          _DownloadItem(
            title: 'نصوص القرآن الكريم',
            subtitle: 'جميع السور والآيات مع المعلومات الأساسية',
            progress: _textProgress,
            isDownloading: _isTextDownloading,
            onDownload: _startTextDownload,
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5D40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
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

  const _DownloadItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isDownloading,
    required this.onDownload,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (progress < 1.0 && !isDownloading)
              IconButton(
                icon: const Icon(Icons.download_for_offline_rounded, color: Color(0xFF2D5D40), size: 32),
                onPressed: onDownload,
              )
            else if (progress >= 1.0)
              const Icon(Icons.check_circle, color: Colors.green, size: 32)
            else
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF2D5D40)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: progress >= 1.0 ? Colors.green : const Color(0xFF2D5D40),
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
