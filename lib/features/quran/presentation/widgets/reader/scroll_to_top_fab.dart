import 'package:flutter/material.dart';
import 'package:fard/core/l10n/app_localizations.dart';

class ScrollToTopFAB extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback? onPressed;

  const ScrollToTopFAB({
    super.key,
    required this.scrollController,
    this.onPressed,
  });

  @override
  State<ScrollToTopFAB> createState() => _ScrollToTopFABState();
}

class _ScrollToTopFABState extends State<ScrollToTopFAB> {
  bool _isVisible = false;
  bool _isNearTop = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    
    // Show FAB when scrolled down more than 300px
    final shouldShow = offset > 300;
    final isNearTop = offset < 100;

    if (shouldShow != _isVisible && !isNearTop) {
      setState(() {
        _isVisible = shouldShow;
        _isNearTop = isNearTop;
      });
    } else if (isNearTop != _isNearTop) {
      setState(() {
        _isNearTop = isNearTop;
        _isVisible = false;
      });
    }
  }

  void _scrollToTop() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton.small(
          onPressed: _isVisible ? _scrollToTop : null,
          heroTag: 'scrollToTop',
          tooltip: l10n.scrollToTop,
          child: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
      ),
    );
  }
}
