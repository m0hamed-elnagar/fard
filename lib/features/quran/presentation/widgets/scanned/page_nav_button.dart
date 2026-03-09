import 'package:flutter/material.dart';
import 'package:fard/core/theme/app_theme.dart';

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
    final color = isDarkMode ? AppTheme.textPrimary : const Color(0xFF2D5D40);
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceLight.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
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
