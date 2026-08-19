import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Thin wrapper around SvgPicture.asset/Image.asset with consistent
/// defaults, used for every brand-migrated icon (logo + service vector
/// icons + small icons). A couple of the source vector icons are SVGs that
/// only wrap an embedded raster `<image>` via a pattern fill — a feature
/// flutter_svg's renderer doesn't support — so those were extracted to
/// plain PNGs; this widget picks the right renderer by file extension so
/// callers don't need to care.
class AppSvgAsset extends StatelessWidget {
  const AppSvgAsset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
      );
    }
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
