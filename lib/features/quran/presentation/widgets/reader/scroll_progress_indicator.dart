import 'package:flutter/material.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/number_extension.dart';
import 'package:quran/quran.dart' as quran;

import 'package:fard/core/theme/app_colors.dart';

class ScrollProgressIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final int currentAyahNumber;
  final int totalAyahs;
  final int surahNumber;

  const ScrollProgressIndicator({
    super.key,
    required this.scrollController,
    required this.currentAyahNumber,
    required this.totalAyahs,
    required this.surahNumber,
  });

  @override
  State<ScrollProgressIndicator> createState() =>
      _ScrollProgressIndicatorState();
}

class _ScrollProgressIndicatorState extends State<ScrollProgressIndicator> {
  int _visibleAyah = 1;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _visibleAyah = widget.currentAyahNumber;
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAyahNumber != oldWidget.currentAyahNumber) {
      setState(() {
        _visibleAyah = widget.currentAyahNumber;
      });
    }
  }

  void _onScroll() {
    // Throttle updates to 100ms
    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds < 100) return;
    _lastUpdate = now;

    // Calculate approximate ayah based on scroll position
    final offset = widget.scrollController.offset;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    
    if (maxScroll > 0) {
      final progress = offset / maxScroll;
      final estimatedAyah = (progress * widget.totalAyahs).round().clamp(1, widget.totalAyahs);
      
      if (estimatedAyah != _visibleAyah) {
        setState(() {
          _visibleAyah = estimatedAyah;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final juzNumber = quran.getJuzNumber(widget.surahNumber, _visibleAyah);
    final progress = widget.totalAyahs > 0 
        ? _visibleAyah / widget.totalAyahs 
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: context.outlineColor,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.primaryColor,
            ),
            minHeight: 3,
          ),
          const SizedBox(height: 6),
          // Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Juz info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 12,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.juz} $juzNumber',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Ayah position
              Text(
                '${l10n.ayah} ${_visibleAyah.toArabicIndic()} / ${widget.totalAyahs.toArabicIndic()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              // Percentage
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
