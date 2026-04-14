import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? activeLabel;
  final String? inactiveLabel;
  final double width;
  final double height;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeLabel,
    this.inactiveLabel,
    this.width = 50,
    this.height = 28,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
        );

    _toggleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final color = Color.lerp(
                AppTheme.surfaceLight,
                AppTheme.accent,
                _toggleAnimation.value,
              );
              final borderColor = Color.lerp(
                AppTheme.cardBorder,
                AppTheme.accent,
                _toggleAnimation.value,
              );

              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  color: color,
                  border: Border.all(color: borderColor!, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(
                        alpha: 0.3 * _toggleAnimation.value,
                      ),
                      blurRadius: 8 * _toggleAnimation.value,
                      spreadRadius: 1 * _toggleAnimation.value,
                      offset: Offset(0, 2 * _toggleAnimation.value),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(_toggleAnimation.value * 2 - 1, 0),
                      child: Container(
                        width: widget.height - 6,
                        height: widget.height - 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.textPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cardBorder.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child:
                            (widget.activeLabel != null ||
                                widget.inactiveLabel != null)
                            ? Center(
                                child: Text(
                                  widget.value
                                      ? (widget.activeLabel ?? '')
                                      : (widget.inactiveLabel ?? ''),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color.lerp(
                                      AppTheme.textSecondary,
                                      AppTheme.accent,
                                      _toggleAnimation.value,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
