import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG icon widget with theme support
class AppSvgIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.name,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Extension method for convenient icon usage
extension SvgIconExtension on BuildContext {
  /// Usage: context.svgIcon('prayer', size: 24)
  Widget svgIcon(String name, {double size = 24, Color? color}) {
    return AppSvgIcon(
      name: name,
      size: size,
      color: color ?? Theme.of(this).iconTheme.color,
    );
  }
}
