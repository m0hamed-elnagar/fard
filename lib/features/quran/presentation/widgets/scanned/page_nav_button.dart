import 'package:flutter/material.dart';
import 'package:fard/core/theme/app_colors.dart';

class PageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDarkMode;

  const PageNavButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? context.onSurfaceColor : context.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? context.surfaceContainerHighestColor.withValues(alpha: 0.5)
            : context.surfaceContainerColor.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color.withValues(alpha: 0.7), size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
