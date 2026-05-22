import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/bazaaro_theme.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 120,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BazaaroTheme.app.softSurface,
      highlightColor: BazaaroTheme.app.cardBackground,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: BazaaroTheme.app.cardBackground,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
