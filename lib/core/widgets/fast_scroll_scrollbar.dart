import 'package:flutter/material.dart';

class FastScrollScrollbar extends StatefulWidget {
  final ScrollController scrollController;
  final int itemCount;
  final Widget Function(BuildContext context, int index)? labelBuilder;

  const FastScrollScrollbar({
    super.key,
    required this.scrollController,
    required this.itemCount,
    this.labelBuilder,
  });

  @override
  State<FastScrollScrollbar> createState() => _FastScrollScrollbarState();
}

class _FastScrollScrollbarState extends State<FastScrollScrollbar> {
  bool _isDragging = false;
  double _dragPosition = 0;
  int _currentIndex = 0;
  DateTime _lastScrollUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Add listener with delay to ensure controller is attached
    Future.microtask(() {
      if (mounted && widget.scrollController.hasClients) {
        widget.scrollController.addListener(_onScroll);
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_isDragging && widget.scrollController.hasClients) {
      final now = DateTime.now();
      if (now.difference(_lastScrollUpdate).inMilliseconds < 50) return;
      _lastScrollUpdate = now;

      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final currentScroll = widget.scrollController.offset;
      if (maxScroll > 0) {
        setState(() {
          _dragPosition = currentScroll / maxScroll;
          _currentIndex = (currentScroll / maxScroll * (widget.itemCount - 1))
              .round()
              .clamp(0, widget.itemCount - 1);
        });
      }
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.scrollController.hasClients) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final screenHeight = renderBox.size.height;
    final newDragPosition =
        (_dragPosition + details.delta.dy / screenHeight).clamp(0.0, 1.0);

    setState(() {
      _dragPosition = newDragPosition;
      _currentIndex =
          (newDragPosition * (widget.itemCount - 1)).round().clamp(
                0,
                widget.itemCount - 1,
              );
    });

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    widget.scrollController.jumpTo(newDragPosition * maxScroll);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    // Use more vibrant colors for better visibility
    final trackColor = isLight 
        ? Colors.grey.withValues(alpha: 0.3) 
        : Colors.grey.withValues(alpha: 0.2);
    final thumbColor = _isDragging 
        ? theme.primaryColor 
        : theme.primaryColor.withValues(alpha: 0.85);
    final thumbWidth = _isDragging ? 10.0 : 8.0;

    return Positioned(
      right: 2,
      top: 8,
      bottom: 8,
      width: 20,
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Track background - always visible
            Center(
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Thumb - larger and more vibrant
            Align(
              alignment: Alignment(0, _dragPosition * 2 - 1),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: _isDragging ? 60.0 : 44.0,
                  end: _isDragging ? 60.0 : 44.0,
                ),
                duration: const Duration(milliseconds: 150),
                builder: (context, height, child) {
                  return Container(
                    width: thumbWidth,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: thumbColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(
                            alpha: _isDragging ? 0.5 : 0.3,
                          ),
                          blurRadius: _isDragging ? 12 : 8,
                          spreadRadius: _isDragging ? 2 : 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Label preview
            if (_isDragging && widget.labelBuilder != null)
              Positioned(
                right: 18,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment(0, _dragPosition * 2 - 1),
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surface,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: widget.labelBuilder!(context, _currentIndex),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
