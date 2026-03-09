import 'package:flutter/material.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';

class ReaderScrollController {
  final ScrollController scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  final ValueNotifier<int?> currentVisibleAyah = ValueNotifier<int?>(null);
  DateTime _lastScrollCheck = DateTime.now();
  bool _isDisposed = false;

  ReaderScrollController() {
    scrollController.addListener(_onScroll);
  }

  void dispose() {
    _isDisposed = true;
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    currentVisibleAyah.dispose();
  }

  Map<int, GlobalKey> get ayahKeys => _ayahKeys;

  void registerAyahKey(int ayahNumber, GlobalKey key) {
    _ayahKeys[ayahNumber] = key;
  }

  void generateKeys(List<Ayah> ayahs) {
    if (_ayahKeys.isNotEmpty) return;
    for (final ayah in ayahs) {
      _ayahKeys[ayah.number.ayahNumberInSurah] = GlobalKey();
    }
  }

  void _onScroll() {
    if (_ayahKeys.isEmpty || _isDisposed) return;

    // Throttle checks to every 100ms
    final now = DateTime.now();
    if (now.difference(_lastScrollCheck).inMilliseconds < 100) return;
    _lastScrollCheck = now;

    int? topAyah;
    double minDistance = double.infinity;
    const double topThreshold = 140.0;

    for (final entry in _ayahKeys.entries) {
      final context = entry.value.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final distance = (position - topThreshold).abs();
          if (distance < minDistance) {
            minDistance = distance;
            topAyah = entry.key;
          }
          // If we found something close and now distances are increasing, we can stop
          if (distance > minDistance && minDistance < 500) break;
        }
      }
    }

    if (topAyah != null && topAyah != currentVisibleAyah.value) {
      currentVisibleAyah.value = topAyah;
    }
  }

  void scrollToAyah(int ayahNumber, {int retryCount = 0}) {
    Future.delayed(Duration(milliseconds: retryCount == 0 ? 300 : 200), () {
      if (_isDisposed) return;
      final key = _ayahKeys[ayahNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.1, // Show near top of screen
        );
      } else if (retryCount < 5) {
        scrollToAyah(ayahNumber, retryCount: retryCount + 1);
      }
    });
  }
}
