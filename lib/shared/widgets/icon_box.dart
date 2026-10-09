import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Kotak ikon berwarna lembut dengan sudut membulat.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.size = AppSizes.serviceIconBox,
    this.iconSize = AppSizes.iconMd,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
    this.borderRadius,
    this.boxShadow,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? AppRadius.mdAll,
        boxShadow: boxShadow,
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}
